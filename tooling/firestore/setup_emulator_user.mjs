import { resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

const PROJECT_ID = 'demo-lumen';
const OWNER_UID = 'lumen-local-owner';
const OWNER_EMAIL = 'thejaynesh@gmail.com';
const DEFAULT_PASSWORD = 'Lumen-local-only-2026!';

function emulatorOrigin(host) {
  // Literal loopback addresses only. Resolve "localhost" to a literal ourselves
  // so host-file/DNS changes cannot turn this helper into a remote request.
  const match = /^(127\.0\.0\.1|localhost|\[::1\]):([0-9]{1,5})$/.exec(host);
  if (!match || Number(match[2]) < 1 || Number(match[2]) > 65535) {
    throw new Error('Auth emulator host must be 127.0.0.1:PORT, localhost:PORT, or [::1]:PORT, without a protocol or path.');
  }
  const address = match[1] === 'localhost' ? '127.0.0.1' : match[1];
  return `http://${address}:${Number(match[2])}`;
}

export function emulatorConfig(env = process.env, args = []) {
  if (args.length) throw new Error('This helper accepts no arguments and only targets demo-lumen.');
  for (const key of [
    'GOOGLE_APPLICATION_CREDENTIALS', 'FIREBASE_SERVICE_ACCOUNT',
    'FIREBASE_SERVICE_ACCOUNT_LUMEN_F2E07', 'FIREBASE_SERVICE_ACCOUNT_STAGING',
    'FIREBASE_TOKEN', 'GOOGLE_OAUTH_ACCESS_TOKEN', 'FIREBASE_CONFIG',
  ]) {
    if (env[key]) throw new Error(`Unset ${key} before local account setup. This helper does not accept cloud credentials or Firebase configuration.`);
  }
  for (const key of ['FIREBASE_PROJECT_ID', 'GCLOUD_PROJECT', 'GOOGLE_CLOUD_PROJECT', 'CLOUDSDK_CORE_PROJECT']) {
    if (env[key] && env[key] !== PROJECT_ID) throw new Error(`${key} must be demo-lumen for local account setup.`);
  }
  if (env.APP_ENV && env.APP_ENV !== 'emulator') throw new Error('APP_ENV must be emulator for local account setup.');
  if (env.NODE_USE_ENV_PROXY === '1') throw new Error('Unset NODE_USE_ENV_PROXY before local account setup. Requests must connect directly to loopback.');
  const origin = emulatorOrigin(env.AUTH_EMULATOR_HOST || env.FIREBASE_AUTH_EMULATOR_HOST || '127.0.0.1:9099');
  if (env.AUTH_EMULATOR_HOST && env.FIREBASE_AUTH_EMULATOR_HOST &&
      origin !== emulatorOrigin(env.FIREBASE_AUTH_EMULATOR_HOST)) {
    throw new Error('AUTH_EMULATOR_HOST and FIREBASE_AUTH_EMULATOR_HOST must identify the same loopback emulator.');
  }
  const password = env.LUMEN_EMULATOR_PASSWORD ?? DEFAULT_PASSWORD;
  if (password.length < 6 || password.length > 128) throw new Error('LUMEN_EMULATOR_PASSWORD must contain 6–128 characters.');
  return { origin, projectId: PROJECT_ID, password };
}

export async function setupEmulatorUser({ env = process.env, args = [], request = fetch } = {}) {
  const config = emulatorConfig(env, args);
  const endpoint = `${config.origin}/identitytoolkit.googleapis.com/v1/projects/${PROJECT_ID}/accounts`;
  async function call(suffix, body) {
    const response = await request(`${endpoint}${suffix}`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json', Authorization: 'Bearer owner' },
      body: JSON.stringify(body),
      redirect: 'error',
      signal: AbortSignal.timeout(10000),
    });
    const data = await response.json();
    if (!response.ok) {
      const code = /^[A-Z_]+/.exec(data.error?.message ?? '')?.[0] ?? 'REQUEST_FAILED';
      throw new Error(`Auth emulator rejected local account setup (${response.status}, ${code}).`);
    }
    return data;
  }

  // The project-scoped endpoints and the "owner" token are supplied by the
  // Firebase Auth emulator. No SDK credential discovery or cloud URL is used.
  const lookup = await call(':lookup', { localId: [OWNER_UID], email: [OWNER_EMAIL] });
  const users = lookup.users ?? [];
  if (!Array.isArray(users) || users.some((user) => user.localId !== OWNER_UID || user.email !== OWNER_EMAIL)) {
    throw new Error('The local owner UID or email is already assigned to another emulator account. Resolve that local conflict in the Emulator UI before retrying.');
  }
  const created = users.length === 0;
  const owner = {
    localId: OWNER_UID,
    email: OWNER_EMAIL,
    emailVerified: true,
    displayName: 'Local portfolio owner',
    password: config.password,
  };
  await call(created ? '' : ':update', { ...owner, ...(created ? { disabled: false } : { disableUser: false }) });
  const verified = await call(':lookup', { localId: [OWNER_UID] });
  const user = verified.users?.find((item) => item.localId === OWNER_UID);
  if (user?.email !== OWNER_EMAIL || user.emailVerified !== true || user.disabled === true) {
    throw new Error('The emulator account did not verify correctly. Inspect the local Auth emulator before signing in.');
  }
  return { projectId: PROJECT_ID, origin: config.origin, email: OWNER_EMAIL, uid: OWNER_UID, created };
}

if (process.argv[1] && fileURLToPath(import.meta.url) === resolve(process.argv[1])) {
  try {
    const result = await setupEmulatorUser({ args: process.argv.slice(2) });
    console.log(`${result.created ? 'Created' : 'Updated'} verified local owner ${result.email} (${result.uid}).`);
    console.log(`Target: ${result.projectId} Auth emulator at ${result.origin}.`);
    console.log('Sign in at /login with the documented disposable password or your LUMEN_EMULATOR_PASSWORD override.');
  } catch (error) {
    console.error(`Local account setup failed: ${error.message}`);
    console.error('Start the demo-lumen Auth emulator first. No production account changes are supported.');
    process.exitCode = 1;
  }
}
