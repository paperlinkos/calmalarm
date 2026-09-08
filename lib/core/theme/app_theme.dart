import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData lightLinenTheme(BuildContext context) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.linenBackground,
      colorScheme: const ColorScheme.light(
        surface: AppColors.linenSurface,
        primary: AppColors.terracotta,
        secondary: AppColors.sageGreen,
        onSurface: AppColors.linenTextPrimary,
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.outfit(
          color: AppColors.linenTextPrimary,
          fontSize: 64,
          fontWeight: FontWeight.w700,
          letterSpacing: -1.5,
        ),
        displayMedium: GoogleFonts.outfit(
          color: AppColors.linenTextPrimary,
          fontSize: 42,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.5,
        ),
        headlineMedium: GoogleFonts.playfairDisplay(
          color: AppColors.linenTextPrimary,
          fontSize: 28,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: GoogleFonts.outfit(
          color: AppColors.linenTextPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: GoogleFonts.inter(
          color: AppColors.linenTextPrimary,
          fontSize: 16,
        ),
        bodyMedium: GoogleFonts.inter(
          color: AppColors.linenTextSecondary,
          fontSize: 14,
        ),
        labelLarge: GoogleFonts.outfit(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.linenSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.linenSurfaceBorder, width: 1),
        ),
      ),
    );
  }

  static ThemeData darkMidnightTheme(BuildContext context) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.midnightBackground,
      colorScheme: const ColorScheme.dark(
        surface: AppColors.midnightSurface,
        primary: AppColors.softAmber,
        secondary: AppColors.sageGreen,
        onSurface: AppColors.midnightTextPrimary,
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.outfit(
          color: AppColors.midnightTextPrimary,
          fontSize: 64,
          fontWeight: FontWeight.w700,
          letterSpacing: -1.5,
        ),
        displayMedium: GoogleFonts.outfit(
          color: AppColors.midnightTextPrimary,
          fontSize: 42,
          fontWeight: FontWeight.w600,
        ),
        headlineMedium: GoogleFonts.playfairDisplay(
          color: AppColors.midnightTextPrimary,
          fontSize: 28,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: GoogleFonts.outfit(
          color: AppColors.midnightTextPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: GoogleFonts.inter(
          color: AppColors.midnightTextPrimary,
          fontSize: 16,
        ),
        bodyMedium: GoogleFonts.inter(
          color: AppColors.midnightTextSecondary,
          fontSize: 14,
        ),
        labelLarge: GoogleFonts.outfit(
          color: Colors.black,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.midnightSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.midnightSurfaceBorder, width: 1),
        ),
      ),
    );
  }
}
