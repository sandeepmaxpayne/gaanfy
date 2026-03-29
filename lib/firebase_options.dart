import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not configured for android. '
          'Android uses android/app/google-services.json during native setup.',
        );
      case TargetPlatform.iOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not configured for ios.',
        );
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not configured for macos.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not configured for windows.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not configured for linux.',
        );
      case TargetPlatform.fuchsia:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not configured for fuchsia.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyB5cveZbpDrwKJhgRamfQmvg1YqOHGFyM8',
    appId: '1:974409267703:web:994a2331149455188f56f2',
    messagingSenderId: '974409267703',
    projectId: 'gannfy-5dba2',
    authDomain: 'gannfy-5dba2.firebaseapp.com',
    storageBucket: 'gannfy-5dba2.firebasestorage.app',
    databaseURL: 'https://gannfy-5dba2-default-rtdb.firebaseio.com',
    measurementId: 'G-VJNVJPCT6L',
  );
}
