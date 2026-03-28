import 'package:firebase_core/firebase_core.dart';

class FirebaseBootstrapService {
  FirebaseBootstrapService._();

  static final FirebaseBootstrapService instance = FirebaseBootstrapService._();

  bool _isReady = false;
  bool _hasAttempted = false;
  String? _errorMessage;

  bool get isReady => _isReady;
  String? get errorMessage => _errorMessage;

  Future<void> initialize() async {
    if (_hasAttempted) {
      return;
    }
    _hasAttempted = true;

    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp();
      }
      _isReady = true;
    } catch (error) {
      _isReady = false;
      _errorMessage = error.toString();
    }
  }
}
