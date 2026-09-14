import 'package:flutter/material.dart';

class AppTheme {
  // Brand Color Palette
  static const Color primaryTerracotta = Color(0xFF8D4925);
  static const Color primaryOchre = Color(0xFFD97736);
  static const Color sageAccent = Color(0xFF5C7A58);
  static const Color parchmentBackground = Color(0xFFFAF7F2);
  static const Color cardSurface = Colors.white;
  static const Color textPrimary = Color(0xFF2C221E);
  static const Color textSecondary = Color(0xFF6E6259);
  static const Color borderLight = Color(0xFFE8E2D9);
  static const Color badgeVerified = Color(0xFF2E7D32);
  static const Color badgePending = Color(0xFFE65100);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: parchmentBackground,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryTerracotta,
        primary: primaryTerracotta,
        secondary: primaryOchre,
        tertiary: sageAccent,
        surface: cardSurface,
        onSurface: textPrimary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: parchmentBackground,
        foregroundColor: textPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.3,
        ),
      ),
      cardTheme: CardTheme(
        color: cardSurface,
        elevation: 1.5,
        shadowColor: Colors.black.withOpacity(0.06),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: borderLight, width: 0.8),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: borderLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: borderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: primaryTerracotta, width: 1.8),
        ),
        labelStyle: const TextStyle(color: textSecondary),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryTerracotta,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryTerracotta,
          side: const BorderSide(color: primaryTerracotta, width: 1.2),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: Colors.white,
        selectedColor: primaryTerracotta.withOpacity(0.15),
        labelStyle: const TextStyle(color: textPrimary, fontSize: 12),
        side: const BorderSide(color: borderLight),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }
}
