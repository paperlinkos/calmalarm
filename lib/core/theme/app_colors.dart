import 'package:flutter/material.dart';

class AppColors {
  // Linen Day Theme Palette
  static const Color linenBackground = Color(0xFFF5F2EB);
  static const Color linenSurface = Color(0xFFEFEBE0);
  static const Color linenSurfaceBorder = Color(0xFFE2DDD0);
  static const Color linenTextPrimary = Color(0xFF1A1D20);
  static const Color linenTextSecondary = Color(0xFF6C727A);
  
  // Nightstand OLED Midnight Palette
  static const Color midnightBackground = Color(0xFF0B0C0E);
  static const Color midnightSurface = Color(0xFF16181D);
  static const Color midnightSurfaceBorder = Color(0xFF282C34);
  static const Color midnightTextPrimary = Color(0xFFF2F4F7);
  static const Color midnightTextSecondary = Color(0xFF98A2B3);

  // Botanical & Sunrise Accent Palette
  static const Color terracotta = Color(0xFFE05A36);
  static const Color sageGreen = Color(0xFF73937E);
  static const Color warmOchre = Color(0xFFD99B6A);
  static const Color morningSlate = Color(0xFF5C7C8D);
  static const Color softAmber = Color(0xFFFFB74D);
  static const Color gardenWater = Color(0xFF4FC3F7);
  static const Color warningFire = Color(0xFFFF5252);
  static const Color weedThistle = Color(0xFF8D6E63);

  // Circadian Sunrise Gradients
  static const LinearGradient sunriseGradient = LinearGradient(
    begin: Alignment.bottomCenter,
    end: Alignment.topCenter,
    colors: [
      Color(0xFF2C1A1D), // Dark Dawn
      Color(0xFF8A3B2B), // Deep Amber Warmth
      Color(0xFFE05A36), // Terracotta Morning
      Color(0xFFFFB74D), // Golden Hour
      Color(0xFFF5F2EB), // Warm Daylight
    ],
  );
}
