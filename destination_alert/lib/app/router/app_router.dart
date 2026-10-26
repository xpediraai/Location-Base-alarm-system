import 'package:flutter/material.dart';

import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/splash/presentation/screens/splash_screen.dart';

/// Application route names and route generator.
class AppRouter {
  AppRouter._();

  static const String splash = '/';
  static const String home = '/home';
  static const String onboarding = '/onboarding';

  /// Generates routes for the application.
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute<dynamic>(
          builder: (_) => const SplashScreen(),
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
