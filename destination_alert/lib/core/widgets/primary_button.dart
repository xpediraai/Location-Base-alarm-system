import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

/// Reusable primary and styled action button for Destination Alert.
class PrimaryButton extends StatelessWidget {
  /// Button display text.
  final String text;

  /// Callback when pressed. Set to null to disable.
  final VoidCallback? onPressed;

  /// Whether the button is currently in a loading state.
  final bool isLoading;

  /// Optional leading icon or widget.
  final Widget? icon;

  /// Button height (defaults to 52).
  final double height;

  /// Button width (defaults to double.infinity).
  final double? width;

  /// Corner radius (defaults to 14).
  final double borderRadius;

  /// Solid background color (defaults to [AppColors.primaryBlue]).
  final Color? backgroundColor;

  /// Custom text color.
  final Color? textColor;

  /// Whether to render as an outline button.
  final bool isOutlined;

  /// Border color for outlined button.
  final Color? borderColor;

  const PrimaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.height = 52.0,
    this.width,
    this.borderRadius = 14.0,
    this.backgroundColor,
    this.textColor,
    this.isOutlined = false,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = onPressed == null || isLoading;
    final effectiveBgColor = backgroundColor ?? AppColors.primaryBlue;

    if (isOutlined) {
      return SizedBox(
        width: width ?? double.infinity,
        height: height,
        child: OutlinedButton(
          onPressed: isDisabled ? null : onPressed,
          style: OutlinedButton.styleFrom(
            side: BorderSide(
              color: borderColor ?? AppColors.inputBorder,
              width: 1.2,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            backgroundColor: Colors.transparent,
          ),
          child: isLoading
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      textColor ?? AppColors.textPrimary,
                    ),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (icon != null) ...[icon!, const SizedBox(width: 8)],
                    Text(
                      text,
                      style: TextStyle(
                        color: textColor ?? AppColors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
        ),
      );
    }

    return Container(
      width: width ?? double.infinity,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        color: isDisabled ? AppColors.inputBorder : effectiveBgColor,
        boxShadow: isDisabled
            ? null
            : [
                BoxShadow(
                  color: effectiveBgColor.withValues(alpha: 0.28),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
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
                      if (icon != null) ...[icon!, const SizedBox(width: 8)],
                      Text(
                        text,
                        style: TextStyle(
                          color: isDisabled
                              ? AppColors.textMuted
                              : (textColor ?? Colors.white),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.2,
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

/// Convenience aliases for component naming consistency.
typedef AppButton = PrimaryButton;
typedef AppPrimaryButton = PrimaryButton;
