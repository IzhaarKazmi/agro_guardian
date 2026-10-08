import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'Web Firebase is not configured. Run flutterfire configure.',
      );
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'Apple platform Firebase is not configured. Run flutterfire configure.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not configured for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCGO0ze_SJWMaM0UFHYD-PxFzPYQxvnN68',
    appId: '1:616903689266:android:5b59f16146030c55e0282b',
    messagingSenderId: '616903689266',
    projectId: 'agro-63cb6',
    storageBucket: 'agro-63cb6.firebasestorage.app',
  );
}
