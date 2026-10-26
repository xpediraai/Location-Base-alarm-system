import 'package:flutter/material.dart';

import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/signup_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/splash/presentation/screens/splash_screen.dart';

/// Application route names and route generator.
class AppRouter {
  AppRouter._();

  static const String splash = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String home = '/home';
  static const String onboarding = '/onboarding';

  /// Generates routes for the application.
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute<dynamic>(
          builder: (_) => const SplashScreen(nextRoute: AppRouter.login),
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
      case home:
        return MaterialPageRoute<dynamic>(
          builder: (_) => const HomeScreen(),
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

