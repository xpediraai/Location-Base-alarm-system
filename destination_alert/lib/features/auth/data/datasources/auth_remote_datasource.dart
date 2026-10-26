import '../../../../core/errors/app_exception.dart';
import '../models/user_model.dart';

/// Contract for remote authentication data sources (Firebase, REST API, etc.).
abstract class AuthRemoteDataSource {
  Future<UserModel> login({
    required String email,
    required String password,
  });

  Future<UserModel> signUp({
    required String name,
    required String email,
    required String password,
    String? phoneNumber,
  });

  Future<void> sendPasswordResetEmail({
    required String email,
  });

  Future<void> logout();

  UserModel? get currentUser;

  bool get isConfigured;
}

/// Default implementation when backend or Firebase authentication has not yet been connected.
///
/// Ensures production-safe execution: does not invent fake success tokens or hardcoded
/// credentials, and honestly reports missing backend configuration.
class UnconfiguredAuthRemoteDataSource implements AuthRemoteDataSource {
  const UnconfiguredAuthRemoteDataSource();

  @override
  bool get isConfigured => false;

  @override
  UserModel? get currentUser => null;

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    // Simulate brief network latency for realistic UX verification
    await Future.delayed(const Duration(milliseconds: 600));
    throw const AuthConfigurationException(
      'Authentication backend is not yet configured. Please connect Firebase Authentication or configure REST endpoints in AppEndpoints.',
    );
  }

  @override
  Future<UserModel> signUp({
    required String name,
    required String email,
    required String password,
    String? phoneNumber,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));
    throw const AuthConfigurationException(
      'Registration backend is not yet configured. Please connect Firebase Authentication or configure REST endpoints in AppEndpoints.',
    );
  }

  @override
  Future<void> sendPasswordResetEmail({required String email}) async {
    await Future.delayed(const Duration(milliseconds: 500));
    throw const AuthConfigurationException(
      'Password reset service is not yet configured. Please connect Firebase Authentication or an email service.',
    );
  }

  @override
  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 200));
  }
}
