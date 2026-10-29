import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';

/// Modern styled text field for authentication and input forms.
class AuthTextField extends StatelessWidget {
  /// Label text displayed above the input field.
  final String? label;

  /// Whether this field is marked as required (adds a brand red asterisk).
  final bool isRequired;

  /// Hint text inside the input field.
  final String hintText;

  /// Text editing controller.
  final TextEditingController? controller;

  /// Leading prefix icon.
  final IconData? prefixIcon;

  /// Optional leading prefix widget (e.g. country code).
  final Widget? prefixWidget;

  /// Trailing suffix widget (e.g., password visibility toggle).
  final Widget? suffixIcon;

  /// Whether to obscure text for passwords.
  final bool obscureText;

  /// Keyboard type (e.g. emailAddress, text, phone).
  final TextInputType keyboardType;

  /// Keyboard action (e.g. next, done).
  final TextInputAction? textInputAction;

  /// Validation function.
  final String? Function(String?)? validator;

  /// Focus node for controlling focus flow.
  final FocusNode? focusNode;

  /// Callback when submitted from keyboard.
  final ValueChanged<String>? onFieldSubmitted;

  /// Whether the field is enabled.
  final bool enabled;

  /// Auto-validation mode.
  final AutovalidateMode autovalidateMode;

  const AuthTextField({
    super.key,
    this.label,
    this.isRequired = false,
    required this.hintText,
    this.controller,
    this.prefixIcon,
    this.prefixWidget,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.textInputAction,
    this.validator,
    this.focusNode,
    this.onFieldSubmitted,
    this.enabled = true,
    this.autovalidateMode = AutovalidateMode.onUserInteraction,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          RichText(
            text: TextSpan(
              text: label!,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.1,
              ),
              children: [
                if (isRequired)
                  const TextSpan(
                    text: ' *',
                    style: TextStyle(
                      color: AppColors.brandRed,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            boxShadow: const [
              BoxShadow(
                color: AppColors.shadowColor,
                blurRadius: 10,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: TextFormField(
            controller: controller,
            focusNode: focusNode,
            obscureText: obscureText,
            keyboardType: keyboardType,
            textInputAction: textInputAction,
            validator: validator,
            onFieldSubmitted: onFieldSubmitted,
            enabled: enabled,
            autovalidateMode: autovalidateMode,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: hintText,
              prefixIcon:
                  prefixWidget ??
                  (prefixIcon != null
                      ? Icon(
                          prefixIcon,
                          color: AppColors.textSecondary,
                          size: 20,
                        )
                      : null),
              suffixIcon: suffixIcon,
            ),
          ),
        ),
      ],
    );
  }
}

/// Convenience aliases for component naming consistency.
typedef AppTextField = AuthTextField;
typedef PasswordVisibilityField = AuthTextField;
