import 'package:flutter/material.dart';

/// Application color palette reflecting the Destination Alert branding.
class AppColors {
  AppColors._();

  // Master Brand Colors
  static const Color primaryBlue = Color(0xFF2563EB); // Royal/Electric Blue
  static const Color secondaryBlue = Color(
    0xFF38BDF8,
  ); // Cyan / Sky Blue accent
  static const Color brandRed = Color(
    0xFFFF4757,
  ); // Destination Alert Pin/Alarm Red
  static const Color primaryRed = Color(0xFFFF4757); // Compatibility alias
  static const Color cyanAccent = Color(0xFF38BDF8); // Compatibility alias
  static const Color royalBlue = Color(0xFF1D4ED8); // Deep Blue gradient tone
  static const Color secondaryGreen = Color(0xFF16A34A); // Success green
  static const Color accentAmber = Color(0xFFFB8C00);

  // Background and neutral tones
  static const Color backgroundLight = Color(0xFFF7F9FC); // Primary background
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF111827); // Dark primary text
  static const Color textSecondary = Color(0xFF64748B); // Slate secondary text
  static const Color textMuted = Color(0xFF94A3B8);

  // Form input and component colors
  static const Color inputBorder = Color(0xFFE2E8F0);
  static const Color inputBorderFocused = Color(0xFF2563EB);
  static const Color inputFill = Color(0xFFFFFFFF);
  static const Color shadowColor = Color(0x0A0F172A);

  // Semantic feedback colors
  static const Color error = Color(0xFFFF4757);
  static const Color success = Color(0xFF16A34A);

  // Convenience aliases and modern design tokens
  static const Color primary = primaryBlue;
  static const Color textPrimaryLight = textPrimary;
  static const Color textSecondaryLight = textSecondary;
  static const Color textPrimaryDark = Color(0xFFF8FAFC);
  static const Color textSecondaryDark = Color(0xFF94A3B8);
  static const Color backgroundDark = Color(0xFF0F172A);
  static const Color surfaceDark = Color(0xFF1E293B);
  static const Color accentBlueSoft = Color(0xFFEFF6FF);
  static const Color errorSoft = Color(0xFFFEF2F2);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryBlue, secondaryBlue],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
