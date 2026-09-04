import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../repositories/auth_repository.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepository;

  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  AuthProvider({AuthRepository? authRepository})
      : _authRepository = authRepository ?? AuthRepository() {
    _init();
  }

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _authRepository.currentUser != null;

  void _init() {
    _authRepository.authStateChanges.listen((User? firebaseUser) {
      if (firebaseUser != null) {
        debugPrint('[AuthProvider] authStateChanges emitted non-null user: ${firebaseUser.email} (uid: ${firebaseUser.uid})');
        _currentUser = UserModel(
          id: firebaseUser.uid,
          name: firebaseUser.displayName ?? firebaseUser.email?.split('@').first ?? 'User',
          email: firebaseUser.email ?? '',
          photoUrl: firebaseUser.photoURL,
          createdAt: DateTime.now(),
        );
      } else {
        debugPrint('[AuthProvider] authStateChanges emitted null user');
        _currentUser = null;
      }
      notifyListeners();
    });
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _setError(null);
    try {
      debugPrint('[AuthProvider] Starting login for email: $email');
      final user = await _authRepository.login(email, password);
      _currentUser = user;
      _setLoading(false);
      debugPrint('[AuthProvider] Login completed SUCCESSFUL for user: ${user?.email}');
      return true;
    } on FirebaseException catch (e) {
      debugPrint('[AuthProvider] Login FirebaseException: [${e.plugin}/${e.code}] ${e.message}');
      _setError(_getReadableAuthError(e.code, e.message));
      _setLoading(false);
      return false;
    } catch (e, stack) {
      debugPrint('[AuthProvider] Login unexpected error: $e\n$stack');
      _setError('Login error: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> register(String name, String email, String password) async {
    _setLoading(true);
    _setError(null);
    try {
      debugPrint('[AuthProvider] Starting registration for email: $email');
      final user = await _authRepository.register(name, email, password);
      _currentUser = user;
      _setLoading(false);
      debugPrint('[AuthProvider] Registration completed SUCCESSFUL for user: ${user?.email}');
      return true;
    } on FirebaseException catch (e) {
      debugPrint('[AuthProvider] Registration FirebaseException: [${e.plugin}/${e.code}] ${e.message}');
      _setError(_getReadableAuthError(e.code, e.message));
      _setLoading(false);
      return false;
    } catch (e, stack) {
      debugPrint('[AuthProvider] Registration unexpected error: $e\n$stack');
      _setError('Registration failed: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  Future<void> logout() async {
    _setLoading(true);
    try {
      await _authRepository.logout();
    } catch (e) {
      debugPrint('[AuthProvider] Logout error: $e');
    }
    _currentUser = null;
    _setLoading(false);
  }

  Future<bool> resetPassword(String email) async {
    _setLoading(true);
    _setError(null);
    try {
      await _authRepository.resetPassword(email);
      _setLoading(false);
      return true;
    } on FirebaseException catch (e) {
      debugPrint('[AuthProvider] ResetPassword FirebaseException: [${e.plugin}/${e.code}] ${e.message}');
      _setError(_getReadableAuthError(e.code, e.message));
      _setLoading(false);
      return false;
    } catch (e) {
      debugPrint('[AuthProvider] ResetPassword error: $e');
      _setError('Failed to send password reset email.');
      _setLoading(false);
      return false;
    }
  }

  String _getReadableAuthError(String code, [String? rawMessage]) {
    switch (code) {
      case 'user-not-found':
        return 'No user account found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'email-already-in-use':
        return 'An account already exists with this email address.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'weak-password':
        return 'Password is too weak. Choose a stronger password.';
      case 'invalid-credential':
        return 'Invalid email or password.';
      case 'network-request-failed':
      case 'unavailable':
        return 'Network error. Please check your internet connection.';
      case 'permission-denied':
        return 'Firestore permission denied. Please verify security rules for users collection.';
      default:
        if (rawMessage != null && rawMessage.trim().isNotEmpty) {
          return rawMessage;
        }
        return 'Authentication failed ($code).';
    }
  }
}
