import 'package:flutter/material.dart';

import '../../../../app/router/app_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/asset_constants.dart';
import '../../../../core/widgets/app_splash_screen.dart';

/// Splash screen for the Destination Alert application.
///
/// Displays the full-bleed background and centered responsive logo,
/// and navigates to the home destination once initialization / duration completes.
class SplashScreen extends StatelessWidget {
  /// Custom logo asset path if needed (defaults to [AppAssets.splashLogo]).
  final String logoImage;

  /// Custom background asset path if needed (defaults to [AppAssets.splashBackground]).
  final String backgroundImage;

  /// Total duration before navigating to the next screen.
  final Duration duration;

  /// Optional route to navigate to after splash (defaults to [AppRouter.home]).
  final String nextRoute;

  /// Whether to display the sound wave loader.
  final bool showLoader;

  const SplashScreen({
    super.key,
    this.logoImage = AppAssets.splashLogo,
    this.backgroundImage = AppAssets.splashBackground,
    this.duration = AppConstants.splashDuration,
    this.nextRoute = AppRouter.home,
    this.showLoader = true,
  });

  void _onSplashFinished(BuildContext context) {
    Navigator.of(context).pushReplacementNamed(nextRoute);
  }

  @override
  Widget build(BuildContext context) {
    return AppSplashScreen(
      backgroundImage: backgroundImage,
      logoImage: logoImage,
      duration: duration,
      showLoader: showLoader,
      onFinished: () => _onSplashFinished(context),
    );
  }
}
