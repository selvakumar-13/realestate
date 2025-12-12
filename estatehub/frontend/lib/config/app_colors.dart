import 'package:flutter/material.dart';

class AppColors {
  // Primary - Emerald
  static const Color emeraldPrimary = Color(0xFF10B981);
  static const Color emeraldDark = Color(0xFF059669);
  static const Color emeraldLight = Color(0xFF34D399);
  static const Color emerald50 = Color(0xFFECFDF5);
  
  // Secondary - Blue
  static const Color bluePrimary = Color(0xFF3B82F6);
  static const Color blueDark = Color(0xFF1E40AF);
  static const Color blue50 = Color(0xFFEFF6FF);
  static const Color blue900 = Color(0xFF1E3A8A);
  
  // Neutral - Slate
  static const Color slate50 = Color(0xFFF8FAFC);
  static const Color slate100 = Color(0xFFF1F5F9);
  static const Color slate200 = Color(0xFFE2E8F0);
  static const Color slate300 = Color(0xFFCBD5E1);
  static const Color slate400 = Color(0xFF94A3B8);
  static const Color slate600 = Color(0xFF475569);
  static const Color slate700 = Color(0xFF334155);
  static const Color slate900 = Color(0xFF0F172A);
  
  // Accent - Amber/Orange for featured
  static const Color amber500 = Color(0xFFF59E0B);
  static const Color orange500 = Color(0xFFF97316);
  
  // Background
  static const Color backgroundLight = slate50;
  static const Color cardBackground = Colors.white;
  
  // Text
  static const Color textPrimary = slate900;
  static const Color textSecondary = slate600;
  static const Color textMuted = slate400;
  
  // Gradient colors
  static const LinearGradient emeraldGradient = LinearGradient(
    colors: [emeraldPrimary, emeraldDark],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
  
  static const LinearGradient featuredGradient = LinearGradient(
    colors: [amber500, orange500],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
  
  static const LinearGradient heroGradient = LinearGradient(
    colors: [emerald50, Colors.white, blue50],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}