// Called only by an APP_ENV=emulator build, before FlutterFire initializes.
globalThis.lumenConfigureFirebaseEmulators = async function (
  supportedVersion, options, authHost, firestoreHost
) {
  if (!options.projectId.startsWith('demo-')) {
    throw new Error('Emulator initialization requires a demo Firebase project.');
  }
  const version = globalThis.flutterfire_web_sdk_version || supportedVersion;
  const moduleBase = `https://www.gstatic.com/firebasejs/${version}`;
  // Load app first, matching FlutterFire's ordering for Safari compatibility.
  const appSdk = await import(`${moduleBase}/firebase-app.js`);
  const authSdk = await import(`${moduleBase}/firebase-auth.js`);
  const defaults = globalThis.__FIREBASE_DEFAULTS__ || {};
  defaults.emulatorHosts = {
    ...defaults.emulatorHosts,
    auth: authHost,
    firestore: firestoreHost,
  };
  globalThis.__FIREBASE_DEFAULTS__ = defaults;

  const app = appSdk.initializeApp(options);
  // Match firebase_auth_web 6.3.0 getAuthInstance exactly. Calling getAuth here
  // would initialize with different dependencies and fail FlutterFire's check.
  const auth = authSdk.initializeAuth(app, {
    errorMap: authSdk.debugErrorMap,
    persistence: [
      authSdk.indexedDBLocalPersistence,
      authSdk.browserLocalPersistence,
      authSdk.browserSessionPersistence,
    ],
    popupRedirectResolver: authSdk.browserPopupRedirectResolver,
  });
  // This must be synchronous after initializeAuth, before restoration can run.
  const existing = auth.emulatorConfig;
  if (existing) {
    const expected = new URL(`http://${authHost}`);
    const unbracket = (host) => host.replace(/^\[|\]$/g, '');
    if (existing.protocol !== 'http' ||
        unbracket(existing.host) !== unbracket(expected.hostname) ||
        existing.port !== Number(expected.port || 80)) {
      throw new Error('Auth is already connected to a different emulator. Reload with the configured environment.');
    }
  } else {
    authSdk.connectAuthEmulator(auth, `http://${authHost}`);
  }
  // Do not set FlutterFire's firebase_core global: its regular initializer must
  // still load its other service modules. ES module caching shares these apps.
};
