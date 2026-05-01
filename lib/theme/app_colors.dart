import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary
  static const Color primary = Color(0xFF4A6CF7);
  static const Color primaryLight = Color(0xFF6B8AFF);
  static const Color primaryDark = Color(0xFF3451D1);

  // Secondary / Accent
  static const Color secondary = Color(0xFF7B61FF);
  static const Color accentPink = Color(0xFFFF2E88);
  static const Color accentCyan = Color(0xFF7DF9FF);

  // Backgrounds
  static const Color scaffoldBg = Color(0xFFF8F9FC);
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color darkBg = Color(0xFF0A0A10);
  static const Color darkCard = Color(0xFF16161E);
  static const Color darkCardAlt = Color(0xFF1E1E2A);

  // Text
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textHint = Color(0xFF9CA3AF);
  static const Color textOnDark = Color(0xFFE8E8ED);
  static const Color textOnDarkSecondary = Color(0xFF9899A6);

  // Status
  static const Color success = Color(0xFF22C55E);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);

  // Difficulty badges
  static const Color easy = Color(0xFF22C55E);
  static const Color medium = Color(0xFFF59E0B);
  static const Color hard = Color(0xFFEF4444);

  // Borders / Dividers
  static const Color border = Color(0xFFE5E7EB);
  static const Color divider = Color(0xFFF3F4F6);
  static const Color darkBorder = Color(0xFF2A2A38);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF4A6CF7), Color(0xFF7B61FF)],
  );

  static const LinearGradient darkGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
  );

  static const LinearGradient successGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF22C55E), Color(0xFF16A34A)],
  );
}
