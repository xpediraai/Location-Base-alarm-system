import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

/// Smooth animated page indicator matching the Destination Alert design system.
///
/// The active page expands into an elongated pill, while inactive pages
/// appear as subtle circular dots.
class AppPageIndicator extends StatelessWidget {
  /// Total number of pages.
  final int count;

  /// Currently active page index (0-indexed).
  final int currentIndex;

  /// Active dot color (defaults to [AppColors.primaryBlue]).
  final Color activeColor;

  /// Inactive dot color (defaults to light gray).
  final Color inactiveColor;

  /// Dot spacing (defaults to 6.0).
  final double spacing;

  const AppPageIndicator({
    super.key,
    required this.count,
    required this.currentIndex,
    this.activeColor = AppColors.primaryBlue,
    this.inactiveColor = const Color(0xFFCBD5E1),
    this.spacing = 6.0,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        final bool isActive = index == currentIndex;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          margin: EdgeInsets.symmetric(horizontal: spacing / 2),
          width: isActive ? 24.0 : 8.0,
          height: 8.0,
          decoration: BoxDecoration(
            color: isActive ? activeColor : inactiveColor,
            borderRadius: BorderRadius.circular(4.0),
          ),
        );
      }),
    );
  }
}
