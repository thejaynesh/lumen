import 'app_environment.dart';
import 'firebase_emulator_defaults_stub.dart'
    if (dart.library.js_interop) 'firebase_emulator_defaults_web.dart'
    as platform;

Map<String, String>? firebaseEmulatorHosts(AppEnvironment environment) {
  if (!environment.usesEmulators) {
    return null;
  }
  final host = environment.emulatorHost.contains(':')
      ? '[${environment.emulatorHost}]'
      : environment.emulatorHost;
  return {
    'auth': '$host:${environment.authPort}',
    'firestore': '$host:${environment.firestorePort}',
  };
}

Future<void> configureFirebaseEmulatorDefaults(
  AppEnvironment environment,
) async {
  final hosts = firebaseEmulatorHosts(environment);
  if (hosts != null) {
    await platform.configureEmulatorHosts(hosts, environment.firebaseOptions);
  }
}
