import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary (Duolingo-style green)
  static const Color primary = Color(0xFF58CC02);
  static const Color primaryLight = Color(0xFF72E118);
  static const Color primaryDark = Color(0xFF46A302);
  static const Color primaryGlow = Color(0x6658CC02);

  // Secondary / Accent
  static const Color secondary = Color(0xFF46A302);
  static const Color accentPink = Color(0xFFFF4B4B);
  static const Color accentCyan = Color(0xFF1CB0F6);

  // Backgrounds (dark theme)
  static const Color scaffoldBg = Color(0xFF0B1114);
  static const Color cardBg = Color(0x08FFFFFF);    // rgba(255,255,255,0.03)
  static const Color cardBorder = Color(0x14FFFFFF); // rgba(255,255,255,0.08)
  static const Color navBg = Color(0xD90B1114);     // rgba(11,17,20,0.85)
  static const Color darkBg = Color(0xFF060A0D);
  static const Color darkCard = Color(0xFF111820);
  static const Color darkCardAlt = Color(0xFF1A2028);

  // Text
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF8A9CA8);
  static const Color textHint = Color(0xFF5A6A72);
  static const Color textOnDark = Color(0xFFE8E8ED);
  static const Color textOnDarkSecondary = Color(0xFF8A9CA8);

  // Status
  static const Color success = Color(0xFF58CC02);
  static const Color error = Color(0xFFFF4B4B);
  static const Color errorDark = Color(0xFFEA2B2B);
  static const Color warning = Color(0xFFFFC800);
  static const Color info = Color(0xFF1CB0F6);

  // Difficulty badges
  static const Color easy = Color(0xFF58CC02);
  static const Color medium = Color(0xFFFFC800);
  static const Color hard = Color(0xFFFF4B4B);

  // Accent badges
  static const Color xpYellow = Color(0xFFFFC800);
  static const Color streakOrange = Color(0xFFFF6B00);

  // Tint backgrounds
  static const Color primaryTintBg = Color(0x1458CC02); // rgba(88,204,2,0.08)
  static const Color errorTintBg = Color(0x14FF4B4B);   // rgba(255,75,75,0.08)

  // Borders / Dividers
  static const Color border = Color(0x14FFFFFF);    // rgba(255,255,255,0.08)
  static const Color divider = Color(0x0AFFFFFF);   // rgba(255,255,255,0.04)
  static const Color darkBorder = Color(0x26FFFFFF); // rgba(255,255,255,0.15)

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFF58CC02), Color(0xFF46A302)],
  );

  static const LinearGradient darkGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0B1114), Color(0xFF111820)],
  );

  static const LinearGradient successGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFF58CC02), Color(0xFF46A302)],
  );
}
