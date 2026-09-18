import 'package:flutter/material.dart';

class NexiiColors {
  // Brand & Accents
  static const Color primary = Color(0xFF2563EB);
  static const Color primaryGradientEnd = Color(0xFF1D4ED8);
  static const Color aiAccent = Color(0xFF8B5CF6);
  static const Color cyanGlow = Color(0xFF06B6D4);

  // Status Colors
  static const Color error = Color(0xFFEF4444);
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);

  // Backgrounds - Nexii Deep (Dark Mode)
  static const Color deepBackground = Color(0xFF0B1120);
  static const Color deepElevated = Color(0xFF0F172A);
  static const Color deepSurfacePrimary = Color(0xFF1E293B);
  static const Color deepSurfaceSecondary = Color(0xFF334155);

  // Backgrounds - Nexii Light (Light Mode)
  static const Color lightBackground = Color(0xFFF8FAFC);
  static const Color lightElevated = Color(0xFFFFFFFF);
  static const Color lightSurfacePrimary = Color(0xFFFFFFFF);
  static const Color lightSurfaceSecondary = Color(0xFFF1F5F9);

  // Borders
  static const Color deepBorder = Color(0xFF334155);
  static const Color lightBorder = Color(0xFFE2E8F0);

  // Text Tokens
  static const Color deepTextPrimary = Color(0xFFF8FAFC);
  static const Color deepTextSecondary = Color(0xFF94A3B8);
  static const Color lightTextPrimary = Color(0xFF0F172A);
  static const Color lightTextSecondary = Color(0xFF64748B);
}

class NexiiSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double xxxl = 32.0;
  static const double huge = 48.0;
}

class NexiiRadii {
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double pill = 999.0;
}

class NexiiMotion {
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 250);
  static const Duration slow = Duration(milliseconds: 400);
  static const Duration auraBreathing = Duration(milliseconds: 3000);
}
