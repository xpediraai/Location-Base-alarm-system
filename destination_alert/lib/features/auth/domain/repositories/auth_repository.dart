import '../entities/app_user.dart';

/// Authentication repository interface defining authentication contracts.
abstract class AuthRepository {
  /// Signs in a user with email and password.
  Future<AppUser> login({required String email, required String password});

  /// Registers a new user account.
  Future<AppUser> signUp({
    required String name,
    required String email,
    required String password,
    String? phoneNumber,
  });

  /// Sends a password reset email to the specified address.
  Future<void> sendPasswordResetEmail({required String email});

  /// Signs out the currently authenticated user.
  Future<void> logout();

  /// Returns the currently authenticated user, or null if unauthenticated.
  AppUser? get currentUser;

  /// Stream of authentication state changes.
  Stream<AppUser?> get authStateChanges;
}
