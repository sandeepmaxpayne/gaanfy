import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'firebase_bootstrap_service.dart';

class AuthService {
  AuthService() : _bootstrap = FirebaseBootstrapService.instance;

  static const _pendingEmailKey = 'pending_email_link_email';
  static const _pendingNameKey = 'pending_email_link_name';
  static const _emailLinkUrl =
      'https://gannfy-5dba2.firebaseapp.com/finishSignIn';

  final FirebaseBootstrapService _bootstrap;

  bool get isFirebaseReady => _bootstrap.isReady;

  String? get bootstrapError => _bootstrap.errorMessage;

  Stream<User?> authStateChanges() {
    if (!isFirebaseReady) {
      return Stream<User?>.value(null);
    }
    return FirebaseAuth.instance.authStateChanges();
  }

  User? get currentUser =>
      isFirebaseReady ? FirebaseAuth.instance.currentUser : null;

  Future<void> sendSignInLink({required String email, String? name}) async {
    _ensureReady();

    final actionCodeSettings = ActionCodeSettings(
      url: _emailLinkUrl,
      handleCodeInApp: true,
      androidPackageName: 'com.appruloft.gannfy',
      androidInstallApp: true,
      androidMinimumVersion: '23',
      iOSBundleId: 'com.appruloft.gaanfy.gaanfy',
    );

    await FirebaseAuth.instance.sendSignInLinkToEmail(
      email: email,
      actionCodeSettings: actionCodeSettings,
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_pendingEmailKey, email);
    if (name != null && name.trim().isNotEmpty) {
      await prefs.setString(_pendingNameKey, name.trim());
    }
  }

  Future<UserCredential?> completeSignInWithEmailLink(String emailLink) async {
    _ensureReady();

    if (!FirebaseAuth.instance.isSignInWithEmailLink(emailLink)) {
      return null;
    }

    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString(_pendingEmailKey);
    if (email == null || email.isEmpty) {
      throw StateError(
        'Open the sign-in link on the same device you requested it from, or request a new email link.',
      );
    }

    final userCredential = await FirebaseAuth.instance.signInWithEmailLink(
      email: email,
      emailLink: emailLink,
    );

    final pendingName = prefs.getString(_pendingNameKey);
    if (pendingName != null && pendingName.isNotEmpty) {
      await userCredential.user?.updateDisplayName(pendingName);
    }

    await _saveProfile(
      uid: userCredential.user?.uid ?? '',
      name: pendingName ?? userCredential.user?.displayName ?? '',
      email: userCredential.user?.email ?? email,
    );

    await prefs.remove(_pendingEmailKey);
    await prefs.remove(_pendingNameKey);

    return userCredential;
  }

  Future<UserCredential> signInWithApple() async {
    _ensureReady();

    final appleProvider = AppleAuthProvider()
      ..addScope('email')
      ..addScope('name');

    final userCredential = kIsWeb
        ? await FirebaseAuth.instance.signInWithPopup(appleProvider)
        : await FirebaseAuth.instance.signInWithProvider(appleProvider);

    await _saveProfile(
      uid: userCredential.user?.uid ?? '',
      name: userCredential.user?.displayName ?? '',
      email: userCredential.user?.email ?? '',
    );

    return userCredential;
  }

  Future<UserCredential> signInWithGoogle() async {
    _ensureReady();

    if (kIsWeb) {
      final googleProvider = GoogleAuthProvider();
      final userCredential = await FirebaseAuth.instance.signInWithPopup(
        googleProvider,
      );
      await _saveProfile(
        uid: userCredential.user?.uid ?? '',
        name: userCredential.user?.displayName ?? '',
        email: userCredential.user?.email ?? '',
      );
      return userCredential;
    }

    final googleSignIn = GoogleSignIn.instance;
    await googleSignIn.initialize();
    final account = await googleSignIn.authenticate();
    final authentication = account.authentication;
    final idToken = authentication.idToken;
    if (idToken == null || idToken.isEmpty) {
      throw StateError(
        'Google Sign-In completed, but no ID token was returned. Check the Google/Firebase app configuration for this platform.',
      );
    }

    final credential = GoogleAuthProvider.credential(idToken: idToken);

    final userCredential = await FirebaseAuth.instance.signInWithCredential(
      credential,
    );

    await _saveProfile(
      uid: userCredential.user?.uid ?? '',
      name: userCredential.user?.displayName ?? '',
      email: userCredential.user?.email ?? '',
    );

    return userCredential;
  }

  Future<UserCredential> signInAnonymously() async {
    _ensureReady();
    final userCredential = await FirebaseAuth.instance.signInAnonymously();
    await _saveProfile(
      uid: userCredential.user?.uid ?? '',
      name: 'Guest Listener',
      email: '',
    );
    return userCredential;
  }

  Future<void> signOut() async {
    if (!isFirebaseReady) {
      return;
    }
    if (!kIsWeb) {
      try {
        await GoogleSignIn.instance.disconnect();
      } catch (_) {
        // Ignore when there is no active Google session.
      }
    }
    await FirebaseAuth.instance.signOut();
  }

  Future<String?> getPendingEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_pendingEmailKey);
  }

  Future<void> _saveProfile({
    required String uid,
    required String name,
    required String email,
  }) async {
    if (!isFirebaseReady || uid.isEmpty) {
      return;
    }

    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'name': name,
      'email': email,
      'createdAt': FieldValue.serverTimestamp(),
      'plan': 'free',
      'authMethod': _authMethodForCurrentUser(),
      'scalingNote':
          'At 50M+ users, move profile/session metadata to a dedicated NoSQL edge store such as Cassandra while keeping Firebase Auth as the identity broker.',
    }, SetOptions(merge: true));
  }

  String _authMethodForCurrentUser() {
    final user = currentUser;
    if (user == null) {
      return 'unknown';
    }
    if (user.isAnonymous) {
      return 'anonymous';
    }
    if (user.providerData.any(
      (provider) => provider.providerId == 'apple.com',
    )) {
      return 'apple';
    }
    if (user.providerData.any(
      (provider) => provider.providerId == 'google.com',
    )) {
      return 'google';
    }
    return 'email_link';
  }

  void _ensureReady() {
    if (!isFirebaseReady) {
      throw StateError(
        _bootstrap.errorMessage ??
            'Firebase is not configured yet. Add the platform Firebase app files and restart the app.',
      );
    }
  }
}
