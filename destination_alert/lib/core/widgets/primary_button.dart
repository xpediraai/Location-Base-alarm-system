import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

/// Reusable primary action button with Destination Alert gradient and loading state.
class PrimaryButton extends StatelessWidget {
  /// Button display text.
  final String text;

  /// Callback when pressed. Set to null to disable.
  final VoidCallback? onPressed;

  /// Whether the button is currently in a loading state.
  final bool isLoading;

  /// Optional leading icon.
  final IconData? icon;

  /// Button height (defaults to 52).
  final double height;

  /// Button width (defaults to double.infinity).
  final double? width;

  /// Corner radius (defaults to 14).
  final double borderRadius;

  const PrimaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.height = 52.0,
    this.width,
    this.borderRadius = 14.0,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = onPressed == null || isLoading;

    return Container(
      width: width ?? double.infinity,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        gradient: isDisabled
            ? null
            : const LinearGradient(
                colors: [AppColors.primaryBlue, AppColors.royalBlue],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        color: isDisabled ? AppColors.inputBorder : null,
        boxShadow: isDisabled
            ? null
            : [
                BoxShadow(
                  color: AppColors.primaryBlue.withValues(alpha: 0.32),
                  blurRadius: 14,
                  offset: const Offset(0, 5),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isDisabled ? null : onPressed,
          borderRadius: BorderRadius.circular(borderRadius),
          splashColor: Colors.white.withValues(alpha: 0.2),
          highlightColor: Colors.white.withValues(alpha: 0.1),
          child: Center(
            child: isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (icon != null) ...[
                        Icon(icon, color: Colors.white, size: 20),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        text,
                        style: TextStyle(
                          color: isDisabled
                              ? AppColors.textMuted
                              : Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
