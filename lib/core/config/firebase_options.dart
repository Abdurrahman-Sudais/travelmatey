
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Firebase config — must match the project used by travelmate-api backend.
///
/// Set via `--dart-define` or replace defaults after `flutterfire configure`:
///   FIREBASE_API_KEY, FIREBASE_APP_ID, FIREBASE_MESSAGING_SENDER_ID,
///   FIREBASE_PROJECT_ID, FIREBASE_AUTH_DOMAIN (web), FIREBASE_STORAGE_BUCKET
class DefaultFirebaseOptions {
  DefaultFirebaseOptions._();

  static const String apiKey = String.fromEnvironment(
    'FIREBASE_API_KEY',
    defaultValue: 'AIzaSyDTBNjwi4zutSIOS8c7jzrTG9bfwlF95Vw',
  );
  static const String appId = String.fromEnvironment(
    'FIREBASE_APP_ID',
    defaultValue: '1:1859524642:android:9ca3cd72d9ea5009ae127b',
  );
  static const String messagingSenderId = String.fromEnvironment(
    'FIREBASE_MESSAGING_SENDER_ID',
    defaultValue: '1859524642',
  );
  static const String projectId = String.fromEnvironment(
    'FIREBASE_PROJECT_ID',
    defaultValue: 'travelmate-fcb6',
  );
  static const String authDomain = String.fromEnvironment(
    'FIREBASE_AUTH_DOMAIN',
    defaultValue: 'travelmate-fcb6.firebaseapp.com',
  );
  static const String storageBucket = String.fromEnvironment(
    'FIREBASE_STORAGE_BUCKET',
    defaultValue: 'travelmate-fcb6.firebasestorage.app',
  );

  static bool get isConfigured =>
      apiKey.isNotEmpty &&
      appId.isNotEmpty &&
      messagingSenderId.isNotEmpty &&
      projectId.isNotEmpty;

  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return const FirebaseOptions(
        apiKey: apiKey,
        appId: appId,
        messagingSenderId: messagingSenderId,
        projectId: projectId,
        authDomain: authDomain,
        storageBucket: storageBucket,
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return const FirebaseOptions(
          apiKey: apiKey,
          appId: appId,
          messagingSenderId: messagingSenderId,
          projectId: projectId,
          storageBucket: storageBucket,
        );
      case TargetPlatform.iOS:
        return const FirebaseOptions(
          apiKey: apiKey,
          appId: appId,
          messagingSenderId: messagingSenderId,
          projectId: projectId,
          storageBucket: storageBucket,
          iosBundleId: 'com.example.travelmateeee',
        );
      default:
        return const FirebaseOptions(
          apiKey: apiKey,
          appId: appId,
          messagingSenderId: messagingSenderId,
          projectId: projectId,
        );
    }
  }
}
