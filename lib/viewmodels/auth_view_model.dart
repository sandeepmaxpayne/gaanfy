import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../services/auth_service.dart';

class AuthViewModel extends ChangeNotifier {
  AuthViewModel(this._authService);

  final AuthService _authService;
  StreamSubscription<User?>? _authSubscription;

  User? _user;
  bool _isBusy = false;
  bool _guestMode = false;
  String? _error;

  User? get user => _user;
  bool get isBusy => _isBusy;
  bool get isGuestMode => _guestMode;
  bool get isFirebaseReady => _authService.isFirebaseReady;
  String? get error => _error ?? _authService.bootstrapError;
  bool get isAuthenticated => _guestMode || _user != null;
  String get displayName => _guestMode
      ? 'Guest Listener'
      : (_user?.displayName ?? _user?.email ?? 'Music Fan');

  void initialize() {
    _user = _authService.currentUser;
    _authSubscription = _authService.authStateChanges().listen((user) {
      _user = user;
      notifyListeners();
    });
  }

  Future<bool> signIn({required String email, required String password}) async {
    return _run(() async {
      _guestMode = false;
      await _authService.signInWithEmail(email: email, password: password);
      return true;
    });
  }

  Future<bool> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    return _run(() async {
      _guestMode = false;
      await _authService.signUpWithEmail(
        name: name,
        email: email,
        password: password,
      );
      return true;
    });
  }

  Future<void> continueAsGuest() async {
    _error = null;
    _guestMode = true;
    notifyListeners();
  }

  Future<void> signOut() async {
    _guestMode = false;
    _error = null;
    await _authService.signOut();
    notifyListeners();
  }

  Future<void> showUnavailableProviderMessage(String provider) async {
    _error =
        '$provider login is ready in the UI, but the Firebase provider flow still needs native configuration.';
    notifyListeners();
  }

  Future<bool> _run(Future<bool> Function() action) async {
    _isBusy = true;
    _error = null;
    notifyListeners();

    try {
      return await action();
    } catch (error) {
      _error = error.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _isBusy = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
