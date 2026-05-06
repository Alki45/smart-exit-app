import 'package:flutter/material.dart';

/// App color constants — dark theme (legacy) + light theme (SmartExit design)
class AppColors {
  // ── Dark Theme ─────────────────────────────────────────────────────────────
  static const Color primaryDark = Color(0xFF0A1628);
  static const Color cardBackground = Color(0xFF1A2332);
  static const Color cardBackgroundLight = Color(0xFF1E2A3A);
  static const Color cyan = Color(0xFF00D9FF);
  static const Color cyanGlow = Color(0xFF00F0FF);
  static const Color purple = Color(0xFF6366F1);
  static const Color purpleLight = Color(0xFF8B5CF6);
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
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textTertiary = Color(0xFF64748B);
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);
  static const Color scoreBadge = Color(0xFFFFB3BA);
  static const Color scoreBadgeText = Color(0xFFFF6B7A);
  static const Color borderColor = Color(0xFF2D3748);
  static const Color borderColorLight = Color(0xFF374151);
  static const Color overlay = Color(0x80000000);
  static const Color shimmer = Color(0x33FFFFFF);

  // ── Light Theme (SmartExit Material3 tokens) ───────────────────────────────
  static const Color lPrimary = Color(0xFF002045);
  static const Color lOnPrimary = Color(0xFFFFFFFF);
  static const Color lPrimaryContainer = Color(0xFF1A365D);
  static const Color lOnPrimaryContainer = Color(0xFF86A0CD);
  static const Color lPrimaryFixed = Color(0xFFD6E3FF);
  static const Color lOnPrimaryFixed = Color(0xFF001B3C);
  static const Color lSecondary = Color(0xFF2C694E);
  static const Color lOnSecondary = Color(0xFFFFFFFF);
  static const Color lSecondaryContainer = Color(0xFFAEEECB);
  static const Color lOnSecondaryContainer = Color(0xFF316E52);
  static const Color lSecondaryFixed = Color(0xFFB1F0CE);
  static const Color lBackground = Color(0xFFF8F9FF);
  static const Color lSurface = Color(0xFFF8F9FF);
  static const Color lOnSurface = Color(0xFF0B1C30);
  static const Color lOnSurfaceVariant = Color(0xFF43474E);
  static const Color lSurfaceContainer = Color(0xFFE5EEFF);
  static const Color lSurfaceContainerLow = Color(0xFFEFF4FF);
  static const Color lSurfaceContainerHigh = Color(0xFFDCE9FF);
  static const Color lSurfaceContainerHighest = Color(0xFFD3E4FE);
  static const Color lOutline = Color(0xFF74777F);
  static const Color lOutlineVariant = Color(0xFFC4C6CF);
  static const Color lError = Color(0xFFBA1A1A);
  static const Color lTertiaryFixed = Color(0xFFE0E3E5);
  static const Color lOnTertiaryFixedVariant = Color(0xFF444749);
  static const Color lTertiary = Color(0xFF5C5F5E);
  static const Color lPrimaryFixedDim = Color(0xFFA9C7FF);
}
