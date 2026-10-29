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
import 'package:destination_alert/features/auth/presentation/screens/forgot_password_screen.dart';
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
    return UserModel(id: 'test-user-123', email: email, name: 'Test Commuter');
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
    testWidgets(
      'Renders logo, title, email field, password field, and buttons',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          createTestableWidget(child: const LoginScreen()),
        );

        expect(find.text('Welcome Back'), findsOneWidget);
        expect(
          find.text('Sign in to continue to Destination Alert'),
          findsOneWidget,
        );
        expect(
          find.textContaining('Email address', findRichText: true),
          findsOneWidget,
        );
        expect(
          find.textContaining('Password *', findRichText: true),
          findsOneWidget,
        );
        expect(find.text('Forgot Password?'), findsOneWidget);
        expect(find.widgetWithText(PrimaryButton, 'Sign In'), findsOneWidget);
        expect(find.text('or continue with'), findsOneWidget);
        expect(find.text('Sign Up'), findsOneWidget);

        final logoFinder = find.byWidgetPredicate(
          (w) =>
              w is Image &&
              w.image is AssetImage &&
              (w.image as AssetImage).assetName == AppAssets.appLogo,
        );
        expect(logoFinder, findsOneWidget);
      },
    );

    testWidgets(
      'Triggers validation errors when logging in with empty inputs',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          createTestableWidget(child: const LoginScreen()),
        );

        await tester.tap(find.widgetWithText(PrimaryButton, 'Sign In'));
        await tester.pumpAndSettle();

        expect(find.text('Email address is required'), findsOneWidget);
        expect(find.text('Password is required'), findsOneWidget);
      },
    );

    testWidgets('Validates invalid email format', (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget(child: const LoginScreen()));

      final emailField = find.widgetWithText(TextFormField, 'Enter your email');
      await tester.enterText(emailField, 'not-an-email');

      await tester.tap(find.widgetWithText(PrimaryButton, 'Sign In'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter a valid email address'), findsOneWidget);
    });

    testWidgets('Toggles password visibility on LoginScreen', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestableWidget(child: const LoginScreen()));

      expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);
      expect(find.byIcon(Icons.visibility_outlined), findsNothing);

      await tester.tap(find.byIcon(Icons.visibility_off_outlined));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);
      expect(find.byIcon(Icons.visibility_off_outlined), findsNothing);
    });

    testWidgets('Tapping Forgot Password navigates to ForgotPasswordScreen', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          initialRoute: AppRouter.login,
          onGenerateRoute: AppRouter.onGenerateRoute,
        ),
      );

      expect(find.byType(LoginScreen), findsOneWidget);
      await tester.ensureVisible(find.text('Forgot Password?'));
      await tester.tap(find.text('Forgot Password?'));
      await tester.pumpAndSettle();

      expect(find.byType(ForgotPasswordScreen), findsOneWidget);
    });

    testWidgets(
      'Navigates from LoginScreen to SignUpScreen when tapping Sign Up',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(400, 900);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.lightTheme,
            initialRoute: AppRouter.login,
            onGenerateRoute: AppRouter.onGenerateRoute,
          ),
        );

        expect(find.byType(LoginScreen), findsOneWidget);
        await tester.ensureVisible(find.text('Sign Up'));
        await tester.tap(find.text('Sign Up'));
        await tester.pumpAndSettle();

        expect(find.byType(SignUpScreen), findsOneWidget);
      },
    );

    testWidgets('Tapping social buttons shows informative feedback', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createTestableWidget(child: const LoginScreen()));

      final googleFinder = find.byTooltip('Sign in with Google');
      expect(googleFinder, findsOneWidget);
      await tester.ensureVisible(googleFinder);
      await tester.tap(googleFinder);
      await tester.pump();

      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('Successful login navigates to HomeScreen', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(400, 900);
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

      final emailField = find.widgetWithText(TextFormField, 'Enter your email');
      final passField = find.widgetWithText(
        TextFormField,
        'Enter your password',
      );

      await tester.enterText(emailField, 'commuter@example.com');
      await tester.enterText(passField, 'securePass123');

      await tester.ensureVisible(find.widgetWithText(PrimaryButton, 'Sign In'));
      await tester.tap(find.widgetWithText(PrimaryButton, 'Sign In'));
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
    testWidgets('Renders all registration fields, terms, and back button', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(400, 950);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        createTestableWidget(child: const SignUpScreen()),
      );

      expect(find.text('Create Account'), findsOneWidget);
      expect(
        find.text('Start your journey with Destination Alert'),
        findsOneWidget,
      );
      expect(
        find.textContaining('Full Name', findRichText: true),
        findsOneWidget,
      );
      expect(
        find.textContaining('Email address', findRichText: true),
        findsOneWidget,
      );
      expect(
        find.textContaining('Phone Number', findRichText: true),
        findsOneWidget,
      );
      expect(
        find.textContaining('Password', findRichText: true),
        findsWidgets, // Password & Confirm Password
      );
      expect(
        find.byWidgetPredicate(
          (w) =>
              w is RichText &&
              w.text.toPlainText().contains('Terms & Conditions'),
        ),
        findsOneWidget,
      );
      expect(find.widgetWithText(PrimaryButton, 'Sign Up'), findsOneWidget);
      expect(find.text('Sign In'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back_ios_new_rounded), findsOneWidget);
    });

    testWidgets('Enforces required validations on empty registration', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(400, 950);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        createTestableWidget(child: const SignUpScreen()),
      );

      await tester.ensureVisible(find.widgetWithText(PrimaryButton, 'Sign Up'));
      await tester.tap(find.widgetWithText(PrimaryButton, 'Sign Up'));
      await tester.pumpAndSettle();

      expect(find.text('Full name is required'), findsOneWidget);
      expect(find.text('Email address is required'), findsOneWidget);
      expect(find.text('Password is required'), findsOneWidget);
    });

    testWidgets('Enforces password matching validation', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(400, 950);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        createTestableWidget(child: const SignUpScreen()),
      );

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Enter your name'),
        'John Doe',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Enter your email'),
        'john@example.com',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Create a password'),
        'password123',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Re-enter your password'),
        'differentPassword',
      );

      // Check terms checkbox
      await tester.ensureVisible(find.byType(Checkbox));
      await tester.tap(find.byType(Checkbox));
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.widgetWithText(PrimaryButton, 'Sign Up'));
      await tester.tap(find.widgetWithText(PrimaryButton, 'Sign Up'));
      await tester.pumpAndSettle();

      expect(find.text('Passwords do not match'), findsOneWidget);
    });

    testWidgets('Enforces Terms & Conditions acceptance', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(400, 950);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        createTestableWidget(child: const SignUpScreen()),
      );

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Enter your name'),
        'John Doe',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Enter your email'),
        'john@example.com',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Create a password'),
        'password123',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Re-enter your password'),
        'password123',
      );

      // Do NOT check terms checkbox
      await tester.ensureVisible(find.widgetWithText(PrimaryButton, 'Sign Up'));
      await tester.tap(find.widgetWithText(PrimaryButton, 'Sign Up'));
      await tester.pumpAndSettle();

      expect(
        find.text('You must accept the Terms & Conditions to continue.'),
        findsOneWidget,
      );
    });

    testWidgets('Opens Terms & Conditions dialog upon tapping link', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(400, 950);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        createTestableWidget(child: const SignUpScreen()),
      );

      final termsRichText = find.byWidgetPredicate(
        (w) =>
            w is RichText &&
            w.text.toPlainText().contains('Terms & Conditions'),
      );
      await tester.ensureVisible(termsRichText);
      await tester.tap(termsRichText);
      await tester.pumpAndSettle();

      expect(find.text('Terms & Privacy'), findsOneWidget); // dialog title
      expect(find.text('Destination Alert Privacy Commitment'), findsOneWidget);
      expect(find.text('Understood'), findsOneWidget);

      await tester.tap(find.text('Understood'));
      await tester.pumpAndSettle();
      expect(find.text('Destination Alert Privacy Commitment'), findsNothing);
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

      final nameField = find.widgetWithText(TextFormField, 'Enter your name');
      await tester.ensureVisible(nameField);
      await tester.enterText(nameField, 'Jane Doe');

      final emailField = find.widgetWithText(TextFormField, 'Enter your email');
      await tester.ensureVisible(emailField);
      await tester.enterText(emailField, 'jane@example.com');

      final phoneField = find.widgetWithText(
        TextFormField,
        'Enter phone number',
      );
      await tester.ensureVisible(phoneField);
      await tester.enterText(phoneField, '9876543210');

      final passField = find.widgetWithText(TextFormField, 'Create a password');
      await tester.ensureVisible(passField);
      await tester.enterText(passField, 'password123');

      final confirmField = find.widgetWithText(
        TextFormField,
        'Re-enter your password',
      );
      await tester.ensureVisible(confirmField);
      await tester.enterText(confirmField, 'password123');

      // Check terms checkbox
      final checkbox = find.byType(Checkbox);
      await tester.ensureVisible(checkbox);
      await tester.tap(checkbox);
      await tester.pumpAndSettle();

      final signUpBtn = find.widgetWithText(PrimaryButton, 'Sign Up');
      await tester.ensureVisible(signUpBtn);
      await tester.tap(signUpBtn);
      await tester.pumpAndSettle();

      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets(
      'SignUpScreen adapts responsively to small screen without overflow',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(320, 568);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          createTestableWidget(child: const SignUpScreen()),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      },
    );
  });

  group('ForgotPasswordScreen Widget Tests', () {
    testWidgets('Renders logo, title, email input, and submit button', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createTestableWidget(child: const ForgotPasswordScreen()),
      );

      expect(find.text('Forgot Password?'), findsOneWidget);
      expect(
        find.text(
          'Enter your email address and we will send you instructions to reset your password.',
        ),
        findsOneWidget,
      );
      expect(
        find.textContaining('Email address', findRichText: true),
        findsOneWidget,
      );
      expect(
        find.widgetWithText(PrimaryButton, 'Send Reset Link'),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.arrow_back_ios_new_rounded), findsOneWidget);
    });

    testWidgets('Enforces required email validation', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createTestableWidget(child: const ForgotPasswordScreen()),
      );

      await tester.tap(find.widgetWithText(PrimaryButton, 'Send Reset Link'));
      await tester.pumpAndSettle();

      expect(find.text('Email address is required'), findsOneWidget);
    });

    testWidgets('Validates invalid email format', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestableWidget(child: const ForgotPasswordScreen()),
      );

      final emailField = find.widgetWithText(TextFormField, 'Enter your email');
      await tester.enterText(emailField, 'invalid-email');

      await tester.tap(find.widgetWithText(PrimaryButton, 'Send Reset Link'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter a valid email address'), findsOneWidget);
    });

    testWidgets(
      'Successfully submits reset email and shows confirmation card',
      (WidgetTester tester) async {
        final mockSource = MockSuccessfulAuthDataSource();
        final authProvider = AuthProvider(
          repository: AuthRepositoryImpl(remoteDataSource: mockSource),
        );

        await tester.pumpWidget(
          createTestableWidget(
            child: ForgotPasswordScreen(authProvider: authProvider),
          ),
        );

        final emailField = find.widgetWithText(
          TextFormField,
          'Enter your email',
        );
        await tester.enterText(emailField, 'recovery@example.com');

        await tester.tap(find.widgetWithText(PrimaryButton, 'Send Reset Link'));
        await tester.pumpAndSettle();

        // Verify success card is rendered
        expect(find.text('Check Your Inbox'), findsOneWidget);
        expect(find.textContaining('recovery@example.com'), findsOneWidget);
        expect(find.text('Back to Login'), findsOneWidget);
      },
    );
  });
}
