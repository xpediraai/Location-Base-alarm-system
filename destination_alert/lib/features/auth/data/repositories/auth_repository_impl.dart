import 'dart:async';

import '../../../../core/errors/app_exception.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

/// Implementation of [AuthRepository] mediating between remote datasources and the app domain.
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final StreamController<AppUser?> _authStateController =
      StreamController<AppUser?>.broadcast();

  AppUser? _currentUser;

  AuthRepositoryImpl({
    AuthRemoteDataSource? remoteDataSource,
  }) : _remoteDataSource =
            remoteDataSource ?? const UnconfiguredAuthRemoteDataSource() {
    _currentUser = _remoteDataSource.currentUser;
  }

  @override
  AppUser? get currentUser => _currentUser;

  @override
  Stream<AppUser?> get authStateChanges => _authStateController.stream;

  @override
  Future<AppUser> login({
    required String email,
    required String password,
  }) async {
    try {
      final userModel = await _remoteDataSource.login(
        email: email,
        password: password,
      );
      _currentUser = userModel;
      _authStateController.add(_currentUser);
      return userModel;
    } on AppException {
      rethrow;
    } catch (e) {
      throw AuthException('An unexpected error occurred during login: $e');
    }
  }

  @override
  Future<AppUser> signUp({
    required String name,
    required String email,
    required String password,
    String? phoneNumber,
  }) async {
    try {
      final userModel = await _remoteDataSource.signUp(
        name: name,
        email: email,
        password: password,
        phoneNumber: phoneNumber,
      );
      _currentUser = userModel;
      _authStateController.add(_currentUser);
      return userModel;
    } on AppException {
      rethrow;
    } catch (e) {
      throw AuthException('An unexpected error occurred during registration: $e');
    }
  }

  @override
  Future<void> sendPasswordResetEmail({required String email}) async {
    try {
      await _remoteDataSource.sendPasswordResetEmail(email: email);
    } on AppException {
      rethrow;
    } catch (e) {
      throw AuthException(
        'An unexpected error occurred sending password reset email: $e',
      );
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _remoteDataSource.logout();
      _currentUser = null;
      _authStateController.add(null);
    } on AppException {
      rethrow;
    } catch (e) {
      throw AuthException('An unexpected error occurred during logout: $e');
    }
  }

  void dispose() {
    _authStateController.close();
  }
}
