import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../models/user_model.dart';

class AuthRepository {
  final AuthService _authService;
  final FirestoreService _firestoreService;

  AuthRepository({
    AuthService? authService,
    FirestoreService? firestoreService,
  })  : _authService = authService ?? AuthService(),
        _firestoreService = firestoreService ?? FirestoreService();

  User? get currentUser => _authService.currentUser;
  Stream<User?> get authStateChanges => _authService.authStateChanges;

  Future<UserModel?> login(String email, String password) async {
    final credential = await _authService.login(email: email, password: password);
    if (credential.user != null) {
      final uid = credential.user!.uid;
      UserModel? profile = await _firestoreService.getUserProfile(uid);

      // Self-healing: If Firestore profile document is missing (e.g. from prior partial registration), create it now
      if (profile == null) {
        debugPrint('User profile missing in Firestore for $uid. Auto-creating profile...');
        profile = UserModel(
          id: uid,
          name: credential.user!.displayName ?? email.split('@').first,
          email: email,
          photoUrl: credential.user!.photoURL,
          createdAt: DateTime.now(),
        );
        try {
          await _firestoreService.createUserProfile(profile);
        } catch (e) {
          debugPrint('Warning: Could not auto-create missing user profile on login: $e');
        }
      }

      return profile;
    }
    return null;
  }

  Future<UserModel?> register(String name, String email, String password) async {
    final credential = await _authService.register(
      email: email,
      password: password,
      name: name,
    );

    if (credential.user != null) {
      final user = UserModel(
        id: credential.user!.uid,
        name: name,
        email: email,
        photoUrl: null,
        createdAt: DateTime.now(),
      );

      try {
        await _firestoreService.createUserProfile(user);
        return user;
      } catch (e) {
        debugPrint('Error creating Firestore user profile during registration: $e');
        // Clean up Auth state on profile creation failure to prevent partial state
        await _authService.logout();
        rethrow;
      }
    }
    return null;
  }

  Future<void> logout() async {
    await _authService.logout();
  }

  Future<void> resetPassword(String email) async {
    await _authService.resetPassword(email: email);
  }
}
