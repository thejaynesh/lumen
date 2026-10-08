import 'package:firebase_core/firebase_core.dart';
import '../firebase_options.dart';

class AppEnvironment {
  final String name;
  final String emulatorHost;
  final int firestorePort;
  final int authPort;
  final FirebaseOptions firebaseOptions;
  const AppEnvironment({
    required this.name,
    required this.firebaseOptions,
    this.emulatorHost = '127.0.0.1',
    this.firestorePort = 8080,
    this.authPort = 9099,
  });
  bool get usesEmulators => name == 'emulator';
  bool get isProduction => name == 'production';
  String get label => usesEmulators ? 'Local emulator' : name;

  factory AppEnvironment.fromDefines() => AppEnvironment.fromValues(
    name: const String.fromEnvironment('APP_ENV', defaultValue: 'emulator'),
    projectId: const String.fromEnvironment('FIREBASE_PROJECT_ID'),
    apiKey: const String.fromEnvironment('FIREBASE_API_KEY'),
    appId: const String.fromEnvironment('FIREBASE_APP_ID'),
    senderId: const String.fromEnvironment('FIREBASE_MESSAGING_SENDER_ID'),
    authDomain: const String.fromEnvironment('FIREBASE_AUTH_DOMAIN'),
    measurementId: const String.fromEnvironment('FIREBASE_MEASUREMENT_ID'),
    emulatorHost: const String.fromEnvironment(
      'FIREBASE_EMULATOR_HOST',
      defaultValue: '127.0.0.1',
    ),
    firestorePort: const int.fromEnvironment(
      'FIRESTORE_EMULATOR_PORT',
      defaultValue: 8080,
    ),
    authPort: const int.fromEnvironment(
      'AUTH_EMULATOR_PORT',
      defaultValue: 9099,
    ),
  );

  factory AppEnvironment.fromValues({
    String name = 'emulator',
    String projectId = '',
    String apiKey = '',
    String appId = '',
    String senderId = '',
    String authDomain = '',
    String measurementId = '',
    String emulatorHost = '127.0.0.1',
    int firestorePort = 8080,
    int authPort = 9099,
  }) {
    if (!{'emulator', 'staging', 'production'}.contains(name)) {
      throw ArgumentError('APP_ENV must be emulator, staging, or production.');
    }
    if (name == 'emulator') {
      if (!{'127.0.0.1', 'localhost', '::1'}.contains(emulatorHost) ||
          firestorePort < 1 ||
          firestorePort > 65535 ||
          authPort < 1 ||
          authPort > 65535) {
        throw ArgumentError(
          'Use a loopback emulator host and valid local ports.',
        );
      }
      if (projectId.isNotEmpty && !projectId.startsWith('demo-')) {
        throw ArgumentError('Emulators require a demo- project ID.');
      }
      return AppEnvironment(
        name: name,
        emulatorHost: emulatorHost,
        firestorePort: firestorePort,
        authPort: authPort,
        firebaseOptions: FirebaseOptions(
          apiKey: 'demo-api-key',
          appId: '1:123456789:web:demo-lumen',
          messagingSenderId: '123456789',
          projectId: projectId.isEmpty ? 'demo-lumen' : projectId,
          authDomain: 'localhost',
        ),
      );
    }
    if (name == 'production') {
      if (projectId.isNotEmpty &&
          projectId != DefaultFirebaseOptions.web.projectId) {
        throw ArgumentError(
          'Production project does not match the configured app.',
        );
      }
      return AppEnvironment(
        name: name,
        firebaseOptions: DefaultFirebaseOptions.web,
      );
    }
    if ([
      projectId,
      apiKey,
      appId,
      senderId,
      authDomain,
    ].any((v) => v.isEmpty)) {
      throw ArgumentError(
        'Staging requires its own complete Firebase web configuration.',
      );
    }
    if (projectId == DefaultFirebaseOptions.web.projectId ||
        projectId.startsWith('demo-')) {
      throw ArgumentError(
        'Staging must use a separate, real Firebase project.',
      );
    }
    return AppEnvironment(
      name: name,
      firebaseOptions: FirebaseOptions(
        apiKey: apiKey,
        appId: appId,
        messagingSenderId: senderId,
        projectId: projectId,
        authDomain: authDomain,
        measurementId: measurementId.isEmpty ? null : measurementId,
      ),
    );
  }
}
