import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:destination_alert/app/router/app_router.dart';
import 'package:destination_alert/app/theme/app_theme.dart';
import 'package:destination_alert/core/constants/asset_constants.dart';
import 'package:destination_alert/core/widgets/primary_button.dart';
import 'package:destination_alert/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:destination_alert/features/auth/data/models/user_model.dart';
import 'package:destination_alert/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:destination_alert/features/auth/presentation/providers/auth_provider.dart';
import 'package:destination_alert/features/auth/presentation/screens/login_screen.dart';
import 'package:destination_alert/features/auth/presentation/screens/signup_screen.dart';
import 'package:destination_alert/features/home/presentation/screens/home_screen.dart';

/// Test remote datasource that returns a mock user for testing happy paths.
class MockSuccessfulAuthDataSource implements AuthRemoteDataSource {
  @override
  bool get isConfigured => true;

  @override
  UserModel? get currentUser => null;

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    return UserModel(
      id: 'test-user-123',
      email: email,
      name: 'Test Commuter',
    );
  }

  @override
  Future<UserModel> signUp({
    required String name,
    required String email,
    required String password,
    String? phoneNumber,
  }) async {
    return UserModel(
      id: 'test-user-456',
      email: email,
      name: name,
      phoneNumber: phoneNumber,
    );
  }

  @override
  Future<void> sendPasswordResetEmail({required String email}) async {}

  @override
  Future<void> logout() async {}
}

Widget createTestableWidget({required Widget child, AuthProvider? provider}) {
  return MaterialApp(
    theme: AppTheme.lightTheme,
    home: child,
    onGenerateRoute: AppRouter.onGenerateRoute,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LoginScreen Widget Tests', () {
    testWidgets('Renders logo, title, email field, password field, and buttons', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestableWidget(child: const LoginScreen()));

      expect(find.text('Welcome Back'), findsOneWidget);
      expect(find.text('Sign in to never miss your stop again'), findsOneWidget);
      expect(find.text('Email Address'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Forgot Password?'), findsOneWidget);
      expect(find.widgetWithText(PrimaryButton, 'Log In'), findsOneWidget);
      expect(find.text('Sign Up'), findsOneWidget);

      final logoFinder = find.byWidgetPredicate(
        (w) =>
            w is Image &&
            w.image is AssetImage &&
            (w.image as AssetImage).assetName == AppAssets.appLogo,
      );
      expect(logoFinder, findsOneWidget);
    });

    testWidgets('Triggers validation errors when logging in with empty inputs', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestableWidget(child: const LoginScreen()));

      await tester.tap(find.widgetWithText(PrimaryButton, 'Log In'));
      await tester.pumpAndSettle();

      expect(find.text('Email address is required'), findsOneWidget);
      expect(find.text('Password is required'), findsOneWidget);
    });

    testWidgets('Validates invalid email format', (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget(child: const LoginScreen()));

      final emailField = find.widgetWithText(TextFormField, 'name@example.com');
      await tester.enterText(emailField, 'not-an-email');

      await tester.tap(find.widgetWithText(PrimaryButton, 'Log In'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter a valid email address'), findsOneWidget);
    });

    testWidgets('Toggles password visibility on LoginScreen', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestableWidget(child: const LoginScreen()));

      // Initially password is obscured and icon is visibility_off
      expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);
      expect(find.byIcon(Icons.visibility_outlined), findsNothing);

      // Tap toggle button
      await tester.tap(find.byIcon(Icons.visibility_off_outlined));
      await tester.pumpAndSettle();

      // Now password is revealed and icon switches to visibility
      expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);
      expect(find.byIcon(Icons.visibility_off_outlined), findsNothing);
    });

    testWidgets('Opens Forgot Password modal sheet and sends reset request', (
      WidgetTester tester,
    ) async {
      final mockSource = MockSuccessfulAuthDataSource();
      final authProvider = AuthProvider(
        repository: AuthRepositoryImpl(remoteDataSource: mockSource),
      );

      await tester.pumpWidget(
        createTestableWidget(
          child: LoginScreen(authProvider: authProvider),
        ),
      );

      await tester.tap(find.text('Forgot Password?'));
      await tester.pumpAndSettle();

      expect(find.text('Reset Password'), findsOneWidget);
      expect(find.widgetWithText(PrimaryButton, 'Send Reset Link'), findsOneWidget);

      // Submit empty reset
      await tester.tap(find.widgetWithText(PrimaryButton, 'Send Reset Link'));
      await tester.pumpAndSettle();
      expect(find.text('Email address is required'), findsOneWidget);

      // Enter valid email and submit
      final resetEmailFinder = find.descendant(
        of: find.byType(BottomSheet),
        matching: find.byType(TextFormField),
      );
      await tester.enterText(resetEmailFinder, 'reset@example.com');

      await tester.tap(find.widgetWithText(PrimaryButton, 'Send Reset Link'));
      await tester.pumpAndSettle();

      // Sheet dismissed and snackbar shown
      expect(find.text('Reset Password'), findsNothing);
      expect(find.textContaining('Password reset instructions sent'), findsOneWidget);
    });

    testWidgets('Navigates from LoginScreen to SignUpScreen when tapping Sign Up', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          initialRoute: AppRouter.login,
          onGenerateRoute: AppRouter.onGenerateRoute,
        ),
      );

      expect(find.byType(LoginScreen), findsOneWidget);
      await tester.tap(find.text('Sign Up'));
      await tester.pumpAndSettle();

      expect(find.byType(SignUpScreen), findsOneWidget);
    });

    testWidgets('Successful login navigates to HomeScreen', (
      WidgetTester tester,
    ) async {
      final mockSource = MockSuccessfulAuthDataSource();
      final authProvider = AuthProvider(
        repository: AuthRepositoryImpl(remoteDataSource: mockSource),
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          initialRoute: AppRouter.login,
          onGenerateRoute: (settings) {
            if (settings.name == AppRouter.login) {
              return MaterialPageRoute<dynamic>(
                builder: (_) => LoginScreen(authProvider: authProvider),
              );
            }
            return AppRouter.onGenerateRoute(settings);
          },
        ),
      );

      final emailField = find.widgetWithText(TextFormField, 'name@example.com');
      final passField = find.widgetWithText(TextFormField, 'Enter your password');

      await tester.enterText(emailField, 'commuter@example.com');
      await tester.enterText(passField, 'securePass123');

      await tester.tap(find.widgetWithText(PrimaryButton, 'Log In'));
      await tester.pumpAndSettle();

      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('Adapts responsively to small screen without overflow', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createTestableWidget(child: const LoginScreen()));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  });

  group('SignUpScreen Widget Tests', () {
    testWidgets('Renders all registration fields and back button', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createTestableWidget(child: const SignUpScreen()));

      expect(find.text('Create Account'), findsNWidgets(2)); // Screen title and button
      expect(find.text('Full Name'), findsOneWidget);
      expect(find.text('Email Address'), findsOneWidget);
      expect(find.text('Phone Number (Optional)'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Confirm Password'), findsOneWidget);
      expect(find.widgetWithText(PrimaryButton, 'Create Account'), findsOneWidget);
      expect(find.text('Log In'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back_ios_new_rounded), findsOneWidget);
    });

    testWidgets('Enforces required validations on empty registration', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createTestableWidget(child: const SignUpScreen()));

      await tester.ensureVisible(find.widgetWithText(PrimaryButton, 'Create Account'));
      await tester.tap(find.widgetWithText(PrimaryButton, 'Create Account'));
      await tester.pumpAndSettle();

      expect(find.text('Full name is required'), findsOneWidget);
      expect(find.text('Email address is required'), findsOneWidget);
      expect(find.text('Password is required'), findsOneWidget);
    });

    testWidgets('Enforces password matching validation', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createTestableWidget(child: const SignUpScreen()));

      await tester.enterText(
        find.widgetWithText(TextFormField, 'John Doe'),
        'John Doe',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'name@example.com'),
        'john@example.com',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'At least 6 characters'),
        'password123',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Re-enter your password'),
        'differentPassword',
      );

      await tester.ensureVisible(find.widgetWithText(PrimaryButton, 'Create Account'));
      await tester.tap(find.widgetWithText(PrimaryButton, 'Create Account'));
      await tester.pumpAndSettle();

      expect(find.text('Passwords do not match'), findsOneWidget);
    });

    testWidgets('Opens Terms & Privacy dialog upon tapping link', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createTestableWidget(child: const SignUpScreen()));

      final termsFinder = find.textContaining('Terms & Privacy Policy', findRichText: true);
      await tester.ensureVisible(termsFinder);
      await tester.tap(termsFinder);
      await tester.pumpAndSettle();

      expect(find.text('Terms & Privacy'), findsOneWidget);
      expect(find.text('Destination Alert Privacy Commitment'), findsOneWidget);
      expect(find.text('Understood'), findsOneWidget);

      await tester.tap(find.text('Understood'));
      await tester.pumpAndSettle();
      expect(find.text('Terms & Privacy'), findsNothing);
    });

    testWidgets('Successful registration navigates to HomeScreen', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(400, 950);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final mockSource = MockSuccessfulAuthDataSource();
      final authProvider = AuthProvider(
        repository: AuthRepositoryImpl(remoteDataSource: mockSource),
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          initialRoute: AppRouter.signup,
          onGenerateRoute: (settings) {
            if (settings.name == AppRouter.signup) {
              return MaterialPageRoute<dynamic>(
                builder: (_) => SignUpScreen(authProvider: authProvider),
              );
            }
            return AppRouter.onGenerateRoute(settings);
          },
        ),
      );

      await tester.enterText(
        find.widgetWithText(TextFormField, 'John Doe'),
        'Jane Doe',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'name@example.com'),
        'jane@example.com',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, '+1 555 123 4567'),
        '+1 555 987 6543',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'At least 6 characters'),
        'password123',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Re-enter your password'),
        'password123',
      );

      await tester.ensureVisible(find.widgetWithText(PrimaryButton, 'Create Account'));
      await tester.tap(find.widgetWithText(PrimaryButton, 'Create Account'));
      await tester.pumpAndSettle();

      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('SignUpScreen adapts responsively to small screen without overflow', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createTestableWidget(child: const SignUpScreen()));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  });
}
