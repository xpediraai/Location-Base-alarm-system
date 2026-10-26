import 'package:flutter/material.dart';

import '../core/constants/app_constants.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';

/// Root application widget for Destination Alert.
class DestinationAlertApp extends StatelessWidget {
  const DestinationAlertApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: AppRouter.splash,
      onGenerateRoute: AppRouter.onGenerateRoute,
    );
  }
}
