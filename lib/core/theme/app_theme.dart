import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  // Primary Palette
  static const Color primaryBlue = Color(0xFF2563EB);
  static const Color primaryBlueDark = Color(0xFF1D4ED8);
  static const Color primaryBlueShadow = Color(0xFF1E40AF);
  static const Color primaryBlueLight = Color(0xFFEFF6FF);

  // Duolingo Gamification Accents
  static const Color emeraldGreen = Color(0xFF10B981);
  static const Color emeraldDark = Color(0xFF059669);
  static const Color emeraldBg = Color(0xFFECFDF5);

  static const Color amberGold = Color(0xFFF59E0B);
  static const Color amberDark = Color(0xFFD97706);
  static const Color amberBg = Color(0xFFFFFBEB);

  static const Color coralRed = Color(0xFFEF4444);
  static const Color coralDark = Color(0xFFDC2626);
  static const Color coralBg = Color(0xFFFEF2F2);

  static const Color purpleAccent = Color(0xFF8B5CF6);
  static const Color slateBg = Color(0xFFF8FAFC);
  static const Color borderSubtle = Color(0xFFE2E8F0);
  static const Color textMain = Color(0xFF0F172A);
  static const Color textMuted = Color(0xFF64748B);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: slateBg,
      primaryColor: primaryBlue,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryBlue,
        primary: primaryBlue,
        secondary: emeraldGreen,
        surface: Colors.white,
        error: coralRed,
      ),
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: textMain,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: textMain,
          fontSize: 18,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.3,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: primaryBlue,
        unselectedItemColor: textMuted,
        elevation: 12,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: TextStyle(fontWeight: FontWeight.w800, fontSize: 11),
        unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 11),
      ),
    );
  }
}
