import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get web {
    const apiKey = String.fromEnvironment('FIREBASE_WEB_API_KEY');
    const appId = String.fromEnvironment('FIREBASE_WEB_APP_ID');
    const messagingSenderId = String.fromEnvironment(
      'FIREBASE_WEB_MESSAGING_SENDER_ID',
    );
    const projectId = String.fromEnvironment('FIREBASE_WEB_PROJECT_ID');
    const authDomain = String.fromEnvironment('FIREBASE_WEB_AUTH_DOMAIN');
    const storageBucket = String.fromEnvironment('FIREBASE_WEB_STORAGE_BUCKET');
    const databaseUrl = String.fromEnvironment('FIREBASE_WEB_DATABASE_URL');
    const measurementId = String.fromEnvironment('FIREBASE_WEB_MEASUREMENT_ID');

    if (apiKey.isEmpty ||
        appId.isEmpty ||
        messagingSenderId.isEmpty ||
        projectId.isEmpty ||
        authDomain.isEmpty) {
      throw UnsupportedError(
        'Web Firebase is not configured. Provide FIREBASE_WEB_API_KEY, '
        'FIREBASE_WEB_APP_ID, FIREBASE_WEB_MESSAGING_SENDER_ID, '
        'FIREBASE_WEB_PROJECT_ID, and FIREBASE_WEB_AUTH_DOMAIN via '
        '--dart-define.',
      );
    }

    return FirebaseOptions(
      apiKey: apiKey,
      appId: appId,
      messagingSenderId: messagingSenderId,
      projectId: projectId,
      authDomain: authDomain,
      storageBucket: storageBucket.isEmpty ? null : storageBucket,
      databaseURL: databaseUrl.isEmpty ? null : databaseUrl,
      measurementId: measurementId.isEmpty ? null : measurementId,
    );
  }

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

}
