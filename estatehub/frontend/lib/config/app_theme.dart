import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: AppColors.emeraldPrimary,
        secondary: AppColors.bluePrimary,
        surface: AppColors.cardBackground,
        background: AppColors.backgroundLight,
      ),
      
      // Typography using Google Fonts (Inter or similar)
      textTheme: GoogleFonts.interTextTheme(
        TextTheme(
          // Headings
          displayLarge: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
          displayMedium: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
          headlineMedium: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
          
          // Body text
          bodyLarge: TextStyle(
            fontSize: 16,
            color: AppColors.textPrimary,
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
          bodySmall: TextStyle(
            fontSize: 12,
            color: AppColors.textMuted,
          ),
        ),
      ),
      
      // Card theme
      cardTheme: CardTheme(
        color: AppColors.cardBackground,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: AppColors.slate200, width: 1),
        ),
      ),
      
      // Elevated button theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.emeraldPrimary,
          foregroundColor: Colors.white,
          elevation: 4,
          shadowColor: AppColors.emeraldPrimary.withOpacity(0.3),
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      
      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.slate50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.slate200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.slate200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.emeraldPrimary, width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }
}