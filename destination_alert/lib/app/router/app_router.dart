import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import '../../core/services/local_storage_service.dart';
import '../../features/alarm/presentation/screens/set_destination_alarm_screen.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/signup_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/splash/presentation/screens/splash_screen.dart';

/// Application route names and route generator.
class AppRouter {
  AppRouter._();

  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String forgotPassword = '/forgot-password';
  static const String home = '/home';
  static const String setAlarm = '/set-alarm';

  /// Resolves the destination route after splash based on session and onboarding status.
  static String resolveInitialRoute() {
    try {
      if (Firebase.apps.isNotEmpty &&
          FirebaseAuth.instance.currentUser != null) {
        return AppRouter.home;
      }
    } catch (_) {}

    return LocalStorageService.instance.isOnboardingCompleted
        ? AppRouter.login
        : AppRouter.onboarding;
  }

  /// Generates routes for the application.
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute<dynamic>(
          builder: (_) => SplashScreen(nextRoute: resolveInitialRoute()),
          settings: settings,
        );
      case onboarding:
        return MaterialPageRoute<dynamic>(
          builder: (_) => const OnboardingScreen(),
          settings: settings,
        );
      case login:
        return MaterialPageRoute<dynamic>(
          builder: (_) => const LoginScreen(),
          settings: settings,
        );
      case signup:
        return MaterialPageRoute<dynamic>(
          builder: (_) => const SignUpScreen(),
          settings: settings,
        );
      case forgotPassword:
        return MaterialPageRoute<dynamic>(
          builder: (_) => const ForgotPasswordScreen(),
          settings: settings,
        );
      case home:
        // Protected route: redirect unauthenticated users to Login
        bool isUnauthenticated = false;
        try {
          if (Firebase.apps.isNotEmpty &&
              FirebaseAuth.instance.currentUser == null) {
            isUnauthenticated = true;
          }
        } catch (_) {}

        if (isUnauthenticated) {
          return MaterialPageRoute<dynamic>(
            builder: (_) => const LoginScreen(),
            settings: const RouteSettings(name: login),
          );
        }

        return MaterialPageRoute<dynamic>(
          builder: (_) => const HomeScreen(),
          settings: settings,
        );
      case setAlarm:
        return MaterialPageRoute<dynamic>(
          builder: (_) => const SetDestinationAlarmScreen(),
          settings: settings,
        );
      default:
        return MaterialPageRoute<dynamic>(
          builder: (_) =>
              const Scaffold(body: Center(child: Text('Page not found'))),
          settings: settings,
        );
    }
  }
}
