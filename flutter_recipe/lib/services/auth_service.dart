import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  User? get currentUser => _firebaseAuth.currentUser;

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  Future<UserCredential> login({
    required String email,
    required String password,
  }) async {
    try {
      debugPrint('[AuthService] Attempting signInWithEmailAndPassword for: $email');
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      debugPrint('[AuthService] signInWithEmailAndPassword SUCCESS for uid: ${credential.user?.uid}');
      return credential;
    } on FirebaseAuthException catch (e) {
      debugPrint('[AuthService] FirebaseAuthException: [${e.code}] ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('[AuthService] Unexpected error during login: $e');
      rethrow;
    }
  }

  Future<UserCredential> register({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      debugPrint('[AuthService] Attempting createUserWithEmailAndPassword for: $email');
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      if (credential.user != null) {
        debugPrint('[AuthService] Updating displayName to: $name');
        await credential.user!.updateDisplayName(name.trim());
      }

      debugPrint('[AuthService] createUserWithEmailAndPassword SUCCESS for uid: ${credential.user?.uid}');
      return credential;
    } on FirebaseAuthException catch (e) {
      debugPrint('[AuthService] register FirebaseAuthException: [${e.code}] ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('[AuthService] register unexpected error: $e');
      rethrow;
    }
  }

  Future<void> logout() async {
    debugPrint('[AuthService] Signing out...');
    await _firebaseAuth.signOut();
  }

  Future<void> resetPassword({required String email}) async {
    debugPrint('[AuthService] Sending password reset email to: $email');
    await _firebaseAuth.sendPasswordResetEmail(email: email.trim());
  }
}
