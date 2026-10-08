import assert from 'node:assert/strict';
import { readFile } from 'node:fs/promises';
import test from 'node:test';
import vm from 'node:vm';

const source = await readFile(
  new URL('../web/firebase_emulator_bootstrap.js', import.meta.url), 'utf8',
);

function harness({ failImport = false, emulatorConfig } = {}) {
  const events = [];
  const imports = [];
  const app = {};
  const auth = { emulatorConfig };
  let configured = !!emulatorConfig;
  let receivedDependencies;
  const authSdk = {
    debugErrorMap: {},
    indexedDBLocalPersistence: {},
    browserLocalPersistence: {},
    browserSessionPersistence: {},
    browserPopupRedirectResolver: {},
    initializeAuth(receivedApp, dependencies) {
      assert.equal(receivedApp, app);
      receivedDependencies = dependencies;
      events.push('initializeAuth');
      queueMicrotask(() => {
        events.push(configured ? 'restore-emulator' : 'restore-cloud');
      });
      return auth;
    },
    connectAuthEmulator(receivedAuth, url) {
      assert.equal(receivedAuth, auth);
      assert.equal(url, 'http://127.0.0.1:9099');
      configured = true;
      auth.emulatorConfig = { protocol: 'http', host: '127.0.0.1', port: 9099 };
      events.push('connect-emulator');
    },
  };
  const appSdk = {
    initializeApp(options) {
      assert.equal(options.projectId, 'demo-lumen');
      events.push('initializeApp');
      return app;
    },
  };
  const context = vm.createContext({
    URL,
    __FIREBASE_DEFAULTS__: {
      config: { retained: true }, emulatorHosts: { storage: 'localhost:9199' },
    },
  });
  new vm.Script(source, {
    importModuleDynamically: async (specifier) => {
      imports.push(specifier);
      if (failImport) throw new Error('Module unavailable');
      const exports = specifier.endsWith('/firebase-app.js') ? appSdk : authSdk;
      const module = new vm.SyntheticModule(Object.keys(exports), function () {
        for (const [name, value] of Object.entries(exports)) {
          this.setExport(name, value);
        }
      }, { context });
      await module.link(() => {});
      await module.evaluate();
      return module;
    },
  }).runInContext(context);
  return {
    context, events, imports, authSdk,
    dependencies: () => receivedDependencies,
    initialize: (projectId = 'demo-lumen') =>
      context.lumenConfigureFirebaseEmulators(
        '12.19.0', { projectId }, '127.0.0.1:9099', '127.0.0.1:8080',
      ),
  };
}

test('connects before auth restoration with matching FlutterFire dependencies', async () => {
  const run = harness();
  assert.deepEqual(run.events, []);
  await run.initialize();
  assert.deepEqual(run.imports, [
    'https://www.gstatic.com/firebasejs/12.19.0/firebase-app.js',
    'https://www.gstatic.com/firebasejs/12.19.0/firebase-auth.js',
  ]);
  assert.deepEqual(run.events, [
    'initializeApp', 'initializeAuth', 'connect-emulator', 'restore-emulator',
  ]);
  const dependencies = run.dependencies();
  assert.equal(dependencies.errorMap, run.authSdk.debugErrorMap);
  assert.equal(dependencies.popupRedirectResolver, run.authSdk.browserPopupRedirectResolver);
  assert.deepEqual(Array.from(dependencies.persistence), [
    run.authSdk.indexedDBLocalPersistence,
    run.authSdk.browserLocalPersistence,
    run.authSdk.browserSessionPersistence,
  ]);
  assert.equal(run.context.firebase_core, undefined);
  const defaults = run.context.__FIREBASE_DEFAULTS__;
  assert.equal(defaults.config.retained, true);
  assert.equal(defaults.emulatorHosts.storage, 'localhost:9199');
  assert.equal(defaults.emulatorHosts.auth, '127.0.0.1:9099');
  assert.equal(defaults.emulatorHosts.firestore, '127.0.0.1:8080');
});

test('rejects real projects before importing Firebase', async () => {
  const run = harness();
  await assert.rejects(run.initialize('lumen-f2e07'), /demo Firebase project/);
  assert.deepEqual(run.imports, []);
  assert.deepEqual(run.events, []);
});

test('a module load failure cannot start auth against a cloud endpoint', async () => {
  const run = harness({ failImport: true });
  await assert.rejects(run.initialize(), /Module unavailable/);
  assert.deepEqual(run.events, []);
});

test('retry reuses an existing connection to the configured emulator', async () => {
  const run = harness();
  await run.initialize();
  await run.initialize();
  assert.equal(run.events.filter((event) => event === 'connect-emulator').length, 1);
});

test('an existing connection to another emulator fails explicitly', async () => {
  const run = harness({
    emulatorConfig: { protocol: 'http', host: '127.0.0.1', port: 9199 },
  });
  await assert.rejects(run.initialize(), /different emulator/);
  assert.equal(run.events.includes('connect-emulator'), false);
});
