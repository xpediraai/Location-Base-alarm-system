import 'package:flutter_test/flutter_test.dart';
import 'package:destination_alert/app/router/app_router.dart';
import 'package:destination_alert/core/errors/app_exception.dart';
import 'package:destination_alert/core/services/local_storage_service.dart';
import 'package:destination_alert/core/utils/validators.dart';
import 'package:destination_alert/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:destination_alert/features/auth/data/models/user_model.dart';
import 'package:destination_alert/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:destination_alert/features/auth/presentation/providers/auth_provider.dart';

/// Test mock implementation for controlled authentication acceptance checks.
class MockControlledAuthRemoteDataSource implements AuthRemoteDataSource {
  final Map<String, String> _userPasswords = {};
  final Map<String, UserModel> _users = {};
  UserModel? _activeUser;

  @override
  bool get isConfigured => true;

  @override
  UserModel? get currentUser => _activeUser;

  @override
  Future<UserModel> signUp({
    required String name,
    required String email,
    required String password,
    String? phoneNumber,
  }) async {
    if (_userPasswords.containsKey(email)) {
      throw const EmailAlreadyInUseException();
    }
    if (password.length < 6) {
      throw const AuthException(
        'The password is too weak. Please use at least 6 characters.',
      );
    }

    final uid = 'test-uid-${email.hashCode.abs()}';
    final user = UserModel(
      id: uid,
      email: email,
      name: name,
      phoneNumber: phoneNumber,
      createdAt: DateTime.now(),
    );
    _userPasswords[email] = password;
    _users[email] = user;
    _activeUser = user;
    return user;
  }

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    if (!_userPasswords.containsKey(email)) {
      throw const UserNotFoundException();
    }
    if (_userPasswords[email] != password) {
      throw const InvalidCredentialsException();
    }
    final user = _users[email]!;
    _activeUser = user;
    return user;
  }

  @override
  Future<void> sendPasswordResetEmail({required String email}) async {
    if (!_userPasswords.containsKey(email)) {
      throw const UserNotFoundException();
    }
  }

  @override
  Future<void> logout() async {
    _activeUser = null;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockControlledAuthRemoteDataSource mockDataSource;
  late AuthRepositoryImpl authRepository;
  late AuthProvider authProvider;

  setUp(() {
    mockDataSource = MockControlledAuthRemoteDataSource();
    authRepository = AuthRepositoryImpl(remoteDataSource: mockDataSource);
    authProvider = AuthProvider(repository: authRepository);
  });

  group('Phase 1 — Authentication Acceptance Tests', () {
    // 1. Empty registration form validation
    test('1. Empty registration form validation rejects missing fields', () {
      expect(Validators.validateName(''), 'Full name is required');
      expect(Validators.validateEmail(''), 'Email address is required');
      expect(Validators.validatePassword(''), 'Password is required');
      expect(
        Validators.validateConfirmPassword('', ''),
        'Please confirm your password',
      );
    });

    // 2. Invalid email format
    test('2. Invalid email format is rejected by client validation', () {
      expect(
        Validators.validateEmail('not-an-email'),
        'Please enter a valid email address',
      );
      expect(
        Validators.validateEmail('commuter@'),
        'Please enter a valid email address',
      );
      expect(
        Validators.validateEmail('@destination.com'),
        'Please enter a valid email address',
      );
      expect(
        Validators.validateEmail('valid.commuter@destination.app'),
        isNull,
      );
    });

    // 3. Password below configured minimum
    test('3. Password below 6 characters is rejected', () {
      expect(
        Validators.validatePassword('12345'),
        'Password must be at least 6 characters',
      );
      expect(Validators.validatePassword('123456'), isNull);
      expect(Validators.validatePassword('secureP@ss123'), isNull);
    });

    // 4. Mismatched confirmation password
    test('4. Mismatched confirmation password is rejected', () {
      expect(
        Validators.validateConfirmPassword('passOne', 'passTwo'),
        'Passwords do not match',
      );
      expect(
        Validators.validateConfirmPassword('passMatch123', 'passMatch123'),
        isNull,
      );
    });

    // 5. Successful registration using controlled test account
    test('5. Successful registration registers user and establishes active session', () async {
      final success = await authProvider.signUp(
        name: 'Alex Commuter',
        email: 'alex.commuter@example.com',
        password: 'securePass123',
        phoneNumber: '+1987654321',
      );

      expect(success, isTrue);
      expect(authProvider.isAuthenticated, isTrue);
      expect(authProvider.currentUser?.email, 'alex.commuter@example.com');
      expect(authProvider.currentUser?.name, 'Alex Commuter');
      expect(authProvider.currentUser?.id, startsWith('test-uid-'));
      expect(authProvider.errorMessage, isNull);
    });

    // 6. Attempted duplicate registration
    test(
      '6. Attempted duplicate registration is rejected with appropriate error',
      () async {
        await authProvider.signUp(
          name: 'First Register',
          email: 'duplicate@example.com',
          password: 'password123',
        );

        final duplicateSuccess = await authProvider.signUp(
          name: 'Second Register',
          email: 'duplicate@example.com',
          password: 'password123',
        );

        expect(duplicateSuccess, isFalse);
        expect(
          authProvider.errorMessage,
          'An account with this email already exists.',
        );
      },
    );

    // 7. Successful login using controlled test account
    test('7. Successful login authenticates valid user', () async {
      await authProvider.signUp(
        name: 'Login User',
        email: 'login.commuter@example.com',
        password: 'password123',
      );

      // Sign out
      await authProvider.logout();
      expect(authProvider.isAuthenticated, isFalse);

      // Login again
      final loginSuccess = await authProvider.login(
        email: 'login.commuter@example.com',
        password: 'password123',
      );

      expect(loginSuccess, isTrue);
      expect(authProvider.isAuthenticated, isTrue);
      expect(authProvider.currentUser?.name, 'Login User');
    });

    // 8. Incorrect password handling
    test(
      '8. Incorrect password triggers InvalidCredentialsException',
      () async {
        await authProvider.signUp(
          name: 'Secret User',
          email: 'secret@example.com',
          password: 'correctPassword',
        );

        final failedLogin = await authProvider.login(
          email: 'secret@example.com',
          password: 'wrongPassword',
        );

        expect(failedLogin, isFalse);
        expect(
          authProvider.errorMessage,
          'Invalid email or password. Please try again.',
        );
      },
    );

    // 9. Login persistence & initial route resolution
    test(
      '9. AppRouter.resolveInitialRoute honors onboarding and session states',
      () async {
        final storage = LocalStorageService.instance;

        // Case A: First launch (no onboarding)
        await storage.setOnboardingCompleted(false);
        expect(AppRouter.resolveInitialRoute(), AppRouter.onboarding);

        // Case B: Onboarding completed, unauthenticated
        await storage.setOnboardingCompleted(true);
        expect(AppRouter.resolveInitialRoute(), AppRouter.login);
      },
    );

    // 10. Logout and protected route behavior
    test('10. Logout revokes session and clears current user', () async {
      await authProvider.signUp(
        name: 'Logout Tester',
        email: 'logout@example.com',
        password: 'password123',
      );
      expect(authProvider.isAuthenticated, isTrue);

      await authProvider.logout();
      expect(authProvider.isAuthenticated, isFalse);
      expect(authProvider.currentUser, isNull);
    });

    // 11. Firestore user profile creation and UID consistency
    test('11. User profile data structure matches Firestore schema with UID consistency', () {
      final now = DateTime.now();
      final user = UserModel(
        id: 'firebase-uid-abc-777',
        email: 'verified@destination.app',
        name: 'Verified Commuter',
        phoneNumber: '+1000000000',
        createdAt: now,
      );

      final firestoreDoc = user.toJson();

      // Check required schema fields
      expect(firestoreDoc['uid'], 'firebase-uid-abc-777');
      expect(firestoreDoc['id'], 'firebase-uid-abc-777');
      expect(firestoreDoc['fullName'], 'Verified Commuter');
      expect(firestoreDoc['name'], 'Verified Commuter');
      expect(firestoreDoc['email'], 'verified@destination.app');
      expect(firestoreDoc['phoneNumber'], '+1000000000');
      expect(firestoreDoc['createdAt'], isNotNull);
      expect(firestoreDoc['updatedAt'], isNotNull);

      // Deserialization back to UserModel
      final deserialized = UserModel.fromJson(firestoreDoc);
      expect(deserialized.id, 'firebase-uid-abc-777');
      expect(deserialized.name, 'Verified Commuter');
      expect(deserialized.email, 'verified@destination.app');
    });
  });
}
