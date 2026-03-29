import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import '../firebase_options.dart';

class FirebaseBootstrapService {
  FirebaseBootstrapService._();

  static final FirebaseBootstrapService instance = FirebaseBootstrapService._();

  bool _isReady = false;
  bool _hasAttempted = false;
  String? _errorMessage;
  String? _rawErrorMessage;

  bool get isReady => _isReady;
  String? get errorMessage => _errorMessage;
  String? get rawErrorMessage => _rawErrorMessage;

  Future<void> initialize() async {
    if (_hasAttempted) {
      return;
    }
    _hasAttempted = true;

    try {
      if (Firebase.apps.isEmpty) {
        if (kIsWeb) {
          await Firebase.initializeApp(
            options: DefaultFirebaseOptions.currentPlatform,
          );
        } else {
          await Firebase.initializeApp();
        }
      }
      _isReady = true;
    } catch (error) {
      _isReady = false;
      _rawErrorMessage = error.toString();
      _errorMessage = _friendlyMessage(error);
      debugPrint('Firebase bootstrap failed: $_rawErrorMessage');
    }
  }

  String _friendlyMessage(Object error) {
    final raw = error.toString();

    if (kIsWeb) {
      return 'Firebase web services are not configured. This project is missing the web Firebase app configuration, so Google popup sign-in cannot start. Run flutterfire configure for web and initialize Firebase with the generated options.\n\nDetails: $raw';
    }

    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return 'Firebase iOS services are not configured. Add GoogleService-Info.plist for the Runner bundle and make sure its bundle ID matches the app.\n\nDetails: $raw';
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'Firebase Android initialization failed. Make sure android/app/google-services.json exists, its package_name matches the app applicationId, and then reinstall the app so the updated Firebase resources are bundled.\n\nDetails: $raw';
    }

    return raw;
  }
}
