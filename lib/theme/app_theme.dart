import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color primaryColor = Color(0xFFEA580C);
  static const Color secondaryColor = Color(0xFFF97316);
  static const Color accentColor = Color(0xFFFFEDD5);
  static const Color darkBackground = Color(0xFF0F172A);
  static const Color cardDark = Color(0xFF1E293B);
  static const Color textColor = Color(0xFFF8FAFC);
  static const Color errorColor = Color(0xFFEF4444);
  static const Color successColor = Color(0xFF10B981);
  static const Color warningColor = Color(0xFFF59E0B);
  static const Color infoColor = Color(0xFF3B82F6);
}

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData.dark().copyWith(
      primaryColor: AppColors.primaryColor,
      scaffoldBackgroundColor: AppColors.darkBackground,
      textTheme: GoogleFonts.cairoTextTheme(ThemeData.dark().textTheme).apply(
        bodyColor: AppColors.textColor,
        displayColor: AppColors.textColor,
      ),
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryColor,
        secondary: AppColors.secondaryColor,
        surface: AppColors.cardDark,
        background: AppColors.darkBackground,
        error: AppColors.errorColor,
        onPrimary: Colors.white,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.darkBackground,
        elevation: 2,
        centerTitle: true,
        titleTextStyle: GoogleFonts.cairo(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: AppColors.primaryColor,
        ),
        iconTheme: const IconThemeData(color: AppColors.textColor),
      ),
      cardTheme: CardTheme(
        color: AppColors.cardDark,
        elevation: 6,
        shadowColor: Colors.black38,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.cardDark.withOpacity(0.8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.errorColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        hintStyle: TextStyle(color: Colors.grey[400]),
        labelStyle: const TextStyle(color: AppColors.textColor, fontSize: 16),
        errorStyle: const TextStyle(color: AppColors.errorColor, fontSize: 14),
        floatingLabelStyle: const TextStyle(color: AppColors.primaryColor),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: GoogleFonts.cairo(fontSize: 17, fontWeight: FontWeight.w600),
          elevation: 6,
          shadowColor: AppColors.primaryColor.withOpacity(0.4),
          minimumSize: const Size(double.infinity, 56),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryColor,
          side: const BorderSide(color: AppColors.primaryColor, width: 2),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.w600),
          minimumSize: const Size(double.infinity, 52),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryColor,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          textStyle: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.cardDark,
        contentTextStyle: GoogleFonts.cairo(fontSize: 15),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 6,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.cardDark,
        selectedItemColor: AppColors.primaryColor,
        unselectedItemColor: Colors.grey[400],
        selectedLabelStyle: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.w600),
        unselectedLabelStyle: GoogleFonts.cairo(fontSize: 11),
        showSelectedLabels: true,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      dividerTheme: DividerThemeData(
        color: Colors.grey[700]!.withOpacity(0.5),
        thickness: 1,
        space: 20,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primaryColor,
        circularTrackColor: AppColors.cardDark,
      ),
    );
  }
}
