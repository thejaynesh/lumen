import 'package:flutter_test/flutter_test.dart';
import 'package:lumen/config/app_environment.dart';
import 'package:lumen/config/firebase_emulator_defaults.dart';

void main() {
  test('web emulator defaults use the configured local service ports', () {
    expect(firebaseEmulatorHosts(AppEnvironment.fromValues()), {
      'auth': '127.0.0.1:9099',
      'firestore': '127.0.0.1:8080',
    });
    expect(
      firebaseEmulatorHosts(
        AppEnvironment.fromValues(
          emulatorHost: 'localhost',
          authPort: 9199,
          firestorePort: 8180,
        ),
      ),
      {'auth': 'localhost:9199', 'firestore': 'localhost:8180'},
    );
  });

  test('IPv6 defaults bracket the host before appending ports', () {
    expect(
      firebaseEmulatorHosts(AppEnvironment.fromValues(emulatorHost: '::1')),
      {'auth': '[::1]:9099', 'firestore': '[::1]:8080'},
    );
  });

  test('production and staging do not inject emulator defaults', () {
    expect(
      firebaseEmulatorHosts(AppEnvironment.fromValues(name: 'production')),
      isNull,
    );
    expect(
      firebaseEmulatorHosts(
        AppEnvironment.fromValues(
          name: 'staging',
          projectId: 'lumen-staging',
          apiKey: 'staging-key',
          appId: 'staging-app',
          senderId: '123',
          authDomain: 'lumen-staging.firebaseapp.com',
        ),
      ),
      isNull,
    );
  });
}
