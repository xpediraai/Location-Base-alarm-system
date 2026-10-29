/// Base application exception.
class AppException implements Exception {
  final String message;
  final String? code;

  const AppException(this.message, {this.code});

  @override
  String toString() => message;
}

/// Authentication related exception.
class AuthException extends AppException {
  const AuthException(super.message, {super.code});
}

/// Invalid credentials (wrong password or user).
class InvalidCredentialsException extends AuthException {
  const InvalidCredentialsException([
    super.message = 'Invalid email or password. Please try again.',
  ]) : super(code: 'invalid-credentials');
}

/// User does not exist.
class UserNotFoundException extends AuthException {
  const UserNotFoundException([
    super.message = 'No account found with this email address.',
  ]) : super(code: 'user-not-found');
}

/// Email is already registered.
class EmailAlreadyInUseException extends AuthException {
  const EmailAlreadyInUseException([
    super.message = 'An account with this email already exists.',
  ]) : super(code: 'email-already-in-use');
}

/// Backend or auth service not yet configured.
class AuthConfigurationException extends AuthException {
  const AuthConfigurationException([
    super.message = 'Authentication service is not configured. Please connect a backend API or Firebase Authentication.',
  ]) : super(code: 'auth-not-configured');
}

/// Network or internet connectivity exception.
class NetworkException extends AppException {
  const NetworkException([
    super.message = 'Network error. Please check your internet connection.',
  ]) : super(code: 'network-error');
}
