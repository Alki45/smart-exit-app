import 'package:flutter/material.dart';

/// App color constants based on the SmartExit UI design
class AppColors {
  // Primary Colors
  static const Color primaryDark = Color(0xFF0A1628);
  static const Color cardBackground = Color(0xFF1A2332);
  static const Color cardBackgroundLight = Color(0xFF1E2A3A);
  
  // Accent Colors
  static const Color cyan = Color(0xFF00D9FF);
  static const Color cyanGlow = Color(0xFF00F0FF);
  static const Color purple = Color(0xFF6366F1);
  static const Color purpleLight = Color(0xFF8B5CF6);
  
  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [purple, purpleLight],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
  
  static const LinearGradient cyanGradient = LinearGradient(
    colors: [cyan, cyanGlow],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // Text Colors
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textTertiary = Color(0xFF64748B);
  
  // Status Colors
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);
  
  // Score Badge Colors
  static const Color scoreBadge = Color(0xFFFFB3BA);
  static const Color scoreBadgeText = Color(0xFFFF6B7A);
  
  // Border Colors
  static const Color borderColor = Color(0xFF2D3748);
  static const Color borderColorLight = Color(0xFF374151);
  
  // Overlay Colors
  static const Color overlay = Color(0x80000000);
  static const Color shimmer = Color(0x33FFFFFF);
}
