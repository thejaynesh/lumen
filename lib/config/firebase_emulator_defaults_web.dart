import 'dart:js_interop';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_web/firebase_core_web.dart';

@JS('globalThis.lumenConfigureFirebaseEmulators')
external JSPromise<JSAny?> _configureFirebaseEmulators(
  JSString sdkVersion,
  JSAny options,
  JSString authHost,
  JSString firestoreHost,
);

Future<void> configureEmulatorHosts(
  Map<String, String> hosts,
  FirebaseOptions options,
) async {
  await _configureFirebaseEmulators(
    supportedFirebaseJsSdkVersion.toJS,
    {
      'apiKey': options.apiKey,
      'appId': options.appId,
      'messagingSenderId': options.messagingSenderId,
      'projectId': options.projectId,
      'authDomain': options.authDomain,
      'databaseURL': options.databaseURL,
      'storageBucket': options.storageBucket,
      'measurementId': options.measurementId,
    }.jsify()!,
    hosts['auth']!.toJS,
    hosts['firestore']!.toJS,
  ).toDart;
}
