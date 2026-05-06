import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

/// Light theme matching the SmartExit HTML design tokens
class LightThemeData {
  static ThemeData get theme {
    final base = ThemeData.light(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.lBackground,
      colorScheme: const ColorScheme.light(
        primary: AppColors.lPrimary,
        onPrimary: AppColors.lOnPrimary,
        primaryContainer: AppColors.lPrimaryContainer,
        onPrimaryContainer: AppColors.lOnPrimaryContainer,
        secondary: AppColors.lSecondary,
        onSecondary: AppColors.lOnSecondary,
        secondaryContainer: AppColors.lSecondaryContainer,
        onSecondaryContainer: AppColors.lOnSecondaryContainer,
        surface: AppColors.lSurface,
        onSurface: AppColors.lOnSurface,
        onSurfaceVariant: AppColors.lOnSurfaceVariant,
        outline: AppColors.lOutline,
        outlineVariant: AppColors.lOutlineVariant,
        error: AppColors.lError,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        iconTheme: const IconThemeData(color: AppColors.lPrimary),
        titleTextStyle: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: AppColors.lPrimary,
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.lOutlineVariant),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.lPrimary,
          foregroundColor: AppColors.lOnPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.inter(
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.lPrimary,
        unselectedItemColor: AppColors.lOnSurfaceVariant,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        showUnselectedLabels: true,
      ),
      textTheme: GoogleFonts.interTextTheme(base.textTheme).apply(
        bodyColor: AppColors.lOnSurface,
        displayColor: AppColors.lOnSurface,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.lOutlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.lOutlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.lPrimary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.lError),
        ),
        hintStyle: GoogleFonts.inter(
          color: AppColors.lOnSurfaceVariant,
          fontSize: 15,
        ),
        labelStyle: GoogleFonts.inter(
          color: AppColors.lOnSurfaceVariant,
          fontWeight: FontWeight.w500,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.lOutlineVariant,
        thickness: 1,
        space: 1,
      ),
    );
  }
}
