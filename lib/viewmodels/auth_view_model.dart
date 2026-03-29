import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../services/auth_service.dart';

class AuthViewModel extends ChangeNotifier {
  AuthViewModel(this._authService) : _appLinks = AppLinks();

  final AuthService _authService;
  final AppLinks _appLinks;
  StreamSubscription<User?>? _authSubscription;
  StreamSubscription<Uri>? _linkSubscription;

  User? _user;
  bool _isBusy = false;
  String? _error;
  String? _infoMessage;

  User? get user => _user;
  bool get isBusy => _isBusy;
  bool get isGuestMode => _user?.isAnonymous ?? false;
  bool get isFirebaseReady => _authService.isFirebaseReady;
  String? get error => _error ?? _authService.bootstrapError;
  String? get infoMessage => _infoMessage;
  bool get isAuthenticated => _user != null;
  String get displayName => isGuestMode
      ? 'Guest Listener'
      : (_user?.displayName ?? _user?.email ?? 'Music Fan');

  Future<void> initialize() async {
    _user = _authService.currentUser;
    _authSubscription = _authService.authStateChanges().listen((user) {
      _user = user;
      notifyListeners();
    });

    await _handleInitialLink();
    _linkSubscription = _appLinks.uriLinkStream.listen(
      (uri) => unawaited(_completeEmailLink(uri)),
      onError: (Object error) {
        _error = error.toString();
        notifyListeners();
      },
    );
  }

  Future<bool> sendLoginLink({required String email}) async {
    return _run(() async {
      await _authService.sendSignInLink(email: email);
      _infoMessage =
          'Magic sign-in link sent to $email. Open it on this device to finish login.';
      return true;
    });
  }

  Future<bool> sendSignupLink({
    required String name,
    required String email,
  }) async {
    return _run(() async {
      await _authService.sendSignInLink(email: email, name: name);
      _infoMessage =
          'Sign-up link sent to $email. Open it on this device to create your account.';
      return true;
    });
  }

  Future<bool> signInWithApple() async {
    return _run(() async {
      await _authService.signInWithApple();
      _infoMessage = 'Signed in with Apple successfully.';
      return true;
    });
  }

  Future<bool> signInWithGoogle() async {
    return _run(() async {
      await _authService.signInWithGoogle();
      _infoMessage = 'Signed in with Google successfully.';
      return true;
    });
  }

  Future<void> continueAsGuest() async {
    _isBusy = true;
    _error = null;
    _infoMessage = null;
    notifyListeners();

    try {
      await _authService.signInAnonymously();
      _infoMessage = 'Signed in anonymously with Firebase.';
    } catch (error) {
      _error = error.toString().replaceFirst('Exception: ', '');
    } finally {
      _isBusy = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    _error = null;
    _infoMessage = null;
    await _authService.signOut();
    notifyListeners();
  }

  Future<void> showUnavailableProviderMessage(String provider) async {
    _error =
        '$provider login is ready in the UI, but the Firebase provider flow still needs native configuration.';
    notifyListeners();
  }

  Future<void> clearMessages() async {
    _error = null;
    _infoMessage = null;
    notifyListeners();
  }

  Future<void> _handleInitialLink() async {
    final initialUri = await _appLinks.getInitialLink();
    if (initialUri != null) {
      await _completeEmailLink(initialUri);
    }
  }

  Future<void> _completeEmailLink(Uri uri) async {
    final link = uri.toString();
    if (!_authService.isFirebaseReady) {
      return;
    }

    if (!FirebaseAuth.instance.isSignInWithEmailLink(link)) {
      return;
    }

    _isBusy = true;
    _error = null;
    _infoMessage = 'Completing sign-in from your email link...';
    notifyListeners();

    try {
      await _authService.completeSignInWithEmailLink(link);
      _infoMessage = 'Email link verified. You are now signed in.';
    } catch (error) {
      _error = error.toString().replaceFirst('Exception: ', '');
    } finally {
      _isBusy = false;
      notifyListeners();
    }
  }

  Future<bool> _run(Future<bool> Function() action) async {
    _isBusy = true;
    _error = null;
    _infoMessage = null;
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
    _linkSubscription?.cancel();
    super.dispose();
  }
}
