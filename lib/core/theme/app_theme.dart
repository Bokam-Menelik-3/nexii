import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryColor = Color(0xff2563eb);
  static const Color backgroundColorLight = Color(0xfff8fafc);
  static const Color backgroundColorDark = Color(0xff0f172a);
  static const Color successColor = Color(0xff22c55e);
  static const Color warningColor = Color(0xffef4444);
  static const Color aiAccentColor = Color(0xff8b5cf6);
  static const Color borderColorLight = Color(0xffe2e8f0);
  static const Color borderColorDark = Color(0xff334155);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColorLight,
      cardColor: Colors.white,
      dividerColor: borderColorLight,
      textTheme: GoogleFonts.interTextTheme(ThemeData.light().textTheme).copyWith(
        titleLarge: GoogleFonts.poppins(
          fontWeight: FontWeight.bold,
          fontSize: 22,
          color: const Color(0xff0f172a),
        ),
        titleMedium: GoogleFonts.poppins(
          fontWeight: FontWeight.w600,
          fontSize: 18,
          color: const Color(0xff0f172a),
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14,
          color: const Color(0xff475569),
        ),
      ),
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        secondary: aiAccentColor,
        surface: backgroundColorLight,
        onPrimary: Colors.white,
        onError: Colors.white,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: primaryColor,
        unselectedItemColor: Color(0xff94a3b8),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColorDark,
      cardColor: const Color(0xff1e293b),
      dividerColor: borderColorDark,
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).copyWith(
        titleLarge: GoogleFonts.poppins(
          fontWeight: FontWeight.bold,
          fontSize: 22,
          color: Colors.white,
        ),
        titleMedium: GoogleFonts.poppins(
          fontWeight: FontWeight.w600,
          fontSize: 18,
          color: Colors.white,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14,
          color: const Color(0xff94a3b8),
        ),
      ),
      colorScheme: const ColorScheme.dark(
        primary: primaryColor,
        secondary: aiAccentColor,
        surface: backgroundColorDark,
        onPrimary: Colors.white,
        onError: Colors.white,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xff0f172a),
        selectedItemColor: Colors.white,
        unselectedItemColor: Color(0xff475569),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }
}