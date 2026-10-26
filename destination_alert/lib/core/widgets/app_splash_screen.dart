import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../constants/app_constants.dart';
import '../constants/asset_constants.dart';
import 'sound_wave_loader.dart';

/// A reusable, responsive splash screen widget for the Destination Alert application.
///
/// Features:
/// - Displays the full-screen background image edge-to-edge without unwanted gaps.
/// - Positions the brand logo at the exact optical/visual center of the display.
/// - Dynamically computes responsive logo constraints based on available screen width
///   and height to guarantee the logo never overflows, stretches, or gets cropped.
/// - Supports an optional subtle fade-in animation with proper controller disposal.
/// - Displays an aesthetic animated Sound Wave Loader in the lower display area.
/// - Dispatches an [onAnimationComplete] or [onFinished] callback for seamless routing.
class AppSplashScreen extends StatefulWidget {
  /// Asset path for the full-bleed background image.
  final String backgroundImage;

  /// Asset path for the centered logo.
  final String logoImage;

  /// Width percentage of available screen width to allocate to the logo (0.0 to 1.0).
  /// Defaults to 0.52 for brand logos with text, or 0.32 for icon-only assets.
  final double? logoWidthFactor;

  /// Minimum allowable width for the logo in logical pixels.
  final double minLogoWidth;

  /// Maximum allowable width for the logo in logical pixels.
  final double maxLogoWidth;

  /// Maximum height fraction of available screen height (prevents overflow on landscape).
  final double maxLogoHeightFactor;

  /// Whether to play a smooth fade-in animation on launch.
  final bool animate;

  /// Whether to display the sound wave loader.
  final bool showLoader;

  /// Custom loader widget override if needed (defaults to [SoundWaveLoader]).
  final Widget? loaderWidget;

  /// Duration for the fade-in animation.
  final Duration animationDuration;

  /// Total duration the splash screen stays active before invoking [onFinished].
  /// If null, does not automatically trigger [onFinished].
  final Duration? duration;

  /// Callback executed when the splash duration expires.
  final VoidCallback? onFinished;

  const AppSplashScreen({
    super.key,
    this.backgroundImage = AppAssets.splashBackground,
    this.logoImage = AppAssets.splashLogo,
    this.logoWidthFactor,
    this.minLogoWidth = 120.0,
    this.maxLogoWidth = 260.0,
    this.maxLogoHeightFactor = 0.32,
    this.animate = true,
    this.showLoader = true,
    this.loaderWidget,
    this.animationDuration = AppConstants.splashFadeDuration,
    this.duration = AppConstants.splashDuration,
    this.onFinished,
  });

  @override
  State<AppSplashScreen> createState() => _AppSplashScreenState();
}

class _AppSplashScreenState extends State<AppSplashScreen>
    with SingleTickerProviderStateMixin {
  AnimationController? _animationController;
  Animation<double>? _fadeAnimation;
  Animation<double>? _scaleAnimation;
  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();

    if (widget.animate) {
      _animationController = AnimationController(
        vsync: this,
        duration: widget.animationDuration,
      );

      _fadeAnimation = CurvedAnimation(
        parent: _animationController!,
        curve: Curves.easeOut,
      );

      _scaleAnimation = Tween<double>(begin: 0.94, end: 1.0).animate(
        CurvedAnimation(
          parent: _animationController!,
          curve: Curves.easeOutBack,
        ),
      );

      _animationController!.forward();
    }

    if (widget.duration != null && widget.onFinished != null) {
      _navigationTimer = Timer(widget.duration!, () {
        if (mounted) {
          widget.onFinished!();
        }
      });
    }
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    _animationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
        systemNavigationBarDividerColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SizedBox.expand(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final screenWidth = constraints.maxWidth;
              final screenHeight = constraints.maxHeight;

              // Responsive logo sizing logic
              final effectiveFactor =
                  widget.logoWidthFactor ??
                  (widget.logoImage == AppAssets.appLogo ? 0.32 : 0.52);

              final rawWidth = screenWidth * effectiveFactor;
              final calculatedLogoWidth = rawWidth.clamp(
                widget.minLogoWidth,
                widget.maxLogoWidth,
              );
              final maxAllowedHeight =
                  screenHeight * widget.maxLogoHeightFactor;

              Widget logoWidget = ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: calculatedLogoWidth,
                  maxHeight: maxAllowedHeight,
                ),
                child: Image.asset(
                  widget.logoImage,
                  fit: BoxFit.contain,
                  alignment: Alignment.center,
                  filterQuality: FilterQuality.high,
                  errorBuilder: (context, error, stackTrace) {
                    return const SizedBox.shrink();
                  },
                ),
              );

              if (widget.animate &&
                  _fadeAnimation != null &&
                  _scaleAnimation != null) {
                logoWidget = FadeTransition(
                  opacity: _fadeAnimation!,
                  child: ScaleTransition(
                    scale: _scaleAnimation!,
                    child: logoWidget,
                  ),
                );
              }

              return Stack(
                fit: StackFit.expand,
                alignment: Alignment.center,
                children: [
                  // Full-screen background image covering all available display area
                  Image.asset(
                    widget.backgroundImage,
                    fit: BoxFit.cover,
                    alignment: Alignment.center,
                    filterQuality: FilterQuality.high,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(color: Colors.white);
                    },
                  ),

                  // Logo positioned at true visual center
                  Center(child: logoWidget),

                  // Sound Wave Loader positioned in the lower area
                  if (widget.showLoader)
                    Positioned(
                      bottom: screenHeight > 450
                          ? math.max(screenHeight * 0.10, 48.0)
                          : 16.0,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: widget.animate && _fadeAnimation != null
                            ? FadeTransition(
                                opacity: _fadeAnimation!,
                                child:
                                    widget.loaderWidget ??
                                    const SoundWaveLoader(),
                              )
                            : (widget.loaderWidget ?? const SoundWaveLoader()),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
