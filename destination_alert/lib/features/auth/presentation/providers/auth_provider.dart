import 'package:flutter/foundation.dart';

import '../../../../core/errors/app_exception.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';

/// Authentication state provider managing authentication lifecycle,
/// loading indicators, error feedback, and current user session.
class AuthProvider extends ChangeNotifier {
  final AuthRepository _repository;

  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;
  AppUser? _currentUser;

  AuthProvider({AuthRepository? repository})
    : _repository = repository ?? AuthRepositoryImpl() {
    _currentUser = _repository.currentUser;
  }

  /// Whether an authentication request is currently pending.
  bool get isLoading => _isLoading;

  /// Human-readable error message from the most recent operation.
  String? get errorMessage => _errorMessage;

  /// Informational success message from the most recent operation.
  String? get successMessage => _successMessage;

  /// The currently authenticated user, or null if unauthenticated.
  AppUser? get currentUser => _currentUser;

  /// Whether a user is currently signed in.
  bool get isAuthenticated => _currentUser != null;

  /// Clears any transient error or success banners.
  void clearMessages() {
    if (_errorMessage != null || _successMessage != null) {
      _errorMessage = null;
      _successMessage = null;
      notifyListeners();
    }
  }

  /// Logs in with email and password. Returns `true` if successful.
  Future<bool> login({required String email, required String password}) async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final user = await _repository.login(
        email: email.trim(),
        password: password,
      );
      _currentUser = user;
      _isLoading = false;
      _successMessage = 'Login successful!';
      notifyListeners();
      return true;
    } on AppException catch (e) {
      _isLoading = false;
      _errorMessage = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'An unexpected error occurred. Please try again.';
      notifyListeners();
      return false;
    }
  }

  /// Registers a new user account. Returns `true` if successful.
  Future<bool> signUp({
    required String name,
    required String email,
    required String password,
    String? phoneNumber,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final user = await _repository.signUp(
        name: name.trim(),
        email: email.trim(),
        password: password,
        phoneNumber: phoneNumber?.trim(),
      );
      _currentUser = user;
      _isLoading = false;
      _successMessage = 'Account created successfully!';
      notifyListeners();
      return true;
    } on AppException catch (e) {
      _isLoading = false;
      _errorMessage = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'An unexpected error occurred. Please try again.';
      notifyListeners();
      return false;
    }
  }

  /// Sends a password reset email. Returns `true` if successful.
  Future<bool> sendPasswordResetEmail({required String email}) async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      await _repository.sendPasswordResetEmail(email: email.trim());
      _isLoading = false;
      _successMessage = 'Password reset instructions sent to ${email.trim()}';
      notifyListeners();
      return true;
    } on AppException catch (e) {
      _isLoading = false;
      _errorMessage = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to send password reset email. Please try again.';
      notifyListeners();
      return false;
    }
  }

  /// Signs out the current user.
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _repository.logout();
      _currentUser = null;
      _errorMessage = null;
      _successMessage = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
