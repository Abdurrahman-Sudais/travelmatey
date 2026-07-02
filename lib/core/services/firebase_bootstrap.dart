import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:travelmateeee/core/config/firebase_options.dart';

class FirebaseBootstrap {
  FirebaseBootstrap._();

  static bool _initialized = false;

  static bool get isReady => _initialized;

  static Future<bool> init() async {
    if (_initialized) return true;
    if (!DefaultFirebaseOptions.isConfigured) {
      debugPrint(
        'Firebase not configured. Pass --dart-define=FIREBASE_API_KEY=... etc. '
        'or run flutterfire configure.',
      );
      return false;
    }
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      _initialized = true;
      return true;
    } catch (e) {
      debugPrint('Firebase.initializeApp failed: $e');
      return false;
    }
  }
}
