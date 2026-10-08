import assert from 'node:assert/strict';
import { test } from 'node:test';
import { emulatorConfig, setupEmulatorUser } from './setup_emulator_user.mjs';

test('local owner setup only permits demo-lumen and literal loopback targets', () => {
  assert.equal(emulatorConfig({}).origin, 'http://127.0.0.1:9099');
  assert.equal(emulatorConfig({ AUTH_EMULATOR_HOST: 'localhost:9098' }).origin, 'http://127.0.0.1:9098');
  assert.equal(emulatorConfig({ AUTH_EMULATOR_HOST: '[::1]:9099' }).origin, 'http://[::1]:9099');
  for (const host of ['example.com:9099', '127.0.0.1.example.com:9099', 'http://127.0.0.1:9099', '127.0.0.1:9099/path', '127.0.0.1:0', '127.0.0.1:65536', 'user@127.0.0.1:9099']) {
    assert.throws(() => emulatorConfig({ AUTH_EMULATOR_HOST: host }));
  }
  for (const key of ['FIREBASE_PROJECT_ID', 'GCLOUD_PROJECT', 'GOOGLE_CLOUD_PROJECT', 'CLOUDSDK_CORE_PROJECT']) {
    assert.throws(() => emulatorConfig({ [key]: 'lumen-f2e07' }));
  }
  assert.throws(() => emulatorConfig({}, ['--project', 'lumen-f2e07']));
  assert.throws(() => emulatorConfig({ APP_ENV: 'production' }));
  assert.throws(() => emulatorConfig({ AUTH_EMULATOR_HOST: '127.0.0.1:9099', FIREBASE_AUTH_EMULATOR_HOST: 'example.com:9099' }));
});

test('local owner setup refuses credentials and never prints or returns passwords', async () => {
  for (const key of ['GOOGLE_APPLICATION_CREDENTIALS', 'FIREBASE_SERVICE_ACCOUNT', 'FIREBASE_SERVICE_ACCOUNT_LUMEN_F2E07', 'FIREBASE_TOKEN', 'GOOGLE_OAUTH_ACCESS_TOKEN', 'FIREBASE_CONFIG']) {
    assert.throws(() => emulatorConfig({ [key]: 'sensitive-value' }), (error) => !error.message.includes('sensitive-value'));
  }
  assert.throws(() => emulatorConfig({ NODE_USE_ENV_PROXY: '1' }));
  assert.throws(() => emulatorConfig({ LUMEN_EMULATOR_PASSWORD: 'short' }));
  let called = false;
  await assert.rejects(setupEmulatorUser({ env: { FIREBASE_PROJECT_ID: 'production' }, request: async () => { called = true; } }));
  assert.equal(called, false);
});

test('local owner setup creates then updates the same verified emulator identity', async () => {
  let user;
  const requests = [];
  const request = async (url, options) => {
    assert.ok(url.startsWith('http://127.0.0.1:9099/identitytoolkit.googleapis.com/v1/projects/demo-lumen/accounts'));
    assert.equal(options.redirect, 'error');
    assert.equal(options.headers.Authorization, 'Bearer owner');
    const data = JSON.parse(options.body);
    requests.push({ url, data });
    if (url.endsWith(':lookup')) return Response.json(user ? { users: [user] } : {});
    user = { localId: data.localId, email: data.email, emailVerified: data.emailVerified, disabled: false };
    return Response.json({ localId: user.localId });
  };
  const first = await setupEmulatorUser({ env: {}, request });
  assert.equal(first.created, true);
  assert.equal(first.uid, 'lumen-local-owner');
  assert.equal(user.email, 'thejaynesh@gmail.com');
  assert.equal(user.emailVerified, true);
  assert.equal('password' in first, false);
  const second = await setupEmulatorUser({ env: { LUMEN_EMULATOR_PASSWORD: 'another-local-password' }, request });
  assert.equal(second.created, false);
  assert.equal(second.uid, first.uid);
  assert.equal(requests[4].url.endsWith(':update'), true);
  assert.equal(requests[4].data.password, 'another-local-password');
});

test('local owner setup refuses identity collisions without changing accounts', async () => {
  let calls = 0;
  await assert.rejects(setupEmulatorUser({ env: {}, request: async () => {
    calls++;
    return Response.json({ users: [{ localId: 'unrelated-user', email: 'thejaynesh@gmail.com' }] });
  } }), /already assigned/);
  assert.equal(calls, 1);
});
