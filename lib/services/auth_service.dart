import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'firebase_bootstrap_service.dart';

class AuthService {
  AuthService() : _bootstrap = FirebaseBootstrapService.instance;

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

  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    _ensureReady();
    return FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<UserCredential> signUpWithEmail({
    required String name,
    required String email,
    required String password,
  }) async {
    _ensureReady();
    final credential = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: email, password: password);
    await credential.user?.updateDisplayName(name);
    await _saveProfile(
      uid: credential.user?.uid ?? '',
      name: name,
      email: email,
    );
    return credential;
  }

  Future<void> signOut() async {
    if (!isFirebaseReady) {
      return;
    }
    await FirebaseAuth.instance.signOut();
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
      'scalingNote':
          'At 50M+ users, move profile/session metadata to a dedicated NoSQL edge store such as Cassandra while keeping Firebase Auth as the identity broker.',
    }, SetOptions(merge: true));
  }

  void _ensureReady() {
    if (!isFirebaseReady) {
      throw StateError(
        'Firebase is not configured yet. Add google-services.json and GoogleService-Info.plist, then restart the app.',
      );
    }
  }
}
