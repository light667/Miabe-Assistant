import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Constantes de design de l'application Miabe Assistant (Refonte Premium)
/// Constantes de design de l'application Miabe Assistant (Refonte Premium)
class AppTheme {
  // --- Palette de Couleurs Premium ---
  // Primary: Deep Indigo - Corporate, Trust, Tech
  static const Color primary = Color(0xFF00B4D8); // Cyan

  static const Color primaryDark = Color(0xFF312E81);
  static const Color primaryLight = Color(0xFF6366F1);

  // Secondary: Teal - Success, Growth, Modernity
  static const Color secondary = Color(0xFF03045E); // Navy

  static const Color secondaryDark = Color(0xFF0F766E);
  static const Color secondaryLight = Color(0xFF2DD4BF);
  
  // Tertiary: Amber - Attention, Highlights
  static const Color accent = Color(0xFFF59E0B);
  
  // Neutral - Clean & Crisp
  static const Color backgroundLight = Color(0xFFF8FAFC); // Slate 50
  static const Color surfaceLight = Colors.white;
  static const Color textPrimaryLight = Color(0xFF0F172A); // Slate 900
  static const Color textSecondaryLight = Color(0xFF475569); // Slate 600
  static const Color textTertiaryLight = Color(0xFF94A3B8); // Slate 400

  static const Color backgroundDark = Color(0xFF020617); // Slate 950 (Rich Dark)
  static const Color surfaceDark = Color(0xFF0F172A); // Slate 900
  static const Color textPrimaryDark = Color(0xFFF8FAFC); // Slate 50
  static const Color textSecondaryDark = Color(0xFFCBD5E1); // Slate 300
  static const Color textTertiaryDark = Color(0xFF64748B); // Slate 500

  static const Color error = Color(0xFFDC2626); // Red 600

  // --- Dimensions & Shapes ---
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 16.0;
  static const double radiusLarge = 24.0;
  static const double radiusXLarge = 32.0;

  static const double paddingSmall = 12.0;
  static const double paddingMedium = 20.0;
  static const double paddingLarge = 32.0;

  // --- Text Theme Builder ---
  static TextTheme _buildTextTheme(Color primaryColor, Color secondaryColor) {
    return TextTheme(
      displayLarge: GoogleFonts.outfit(
        fontSize: 48,
        fontWeight: FontWeight.w800,
        color: primaryColor,
        letterSpacing: -1.5,
        height: 1.1,
      ),
      displayMedium: GoogleFonts.outfit(
        fontSize: 36,
        fontWeight: FontWeight.bold,
        color: primaryColor,
        letterSpacing: -1.0,
        height: 1.2,
      ),
      displaySmall: GoogleFonts.outfit(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: primaryColor,
        letterSpacing: -0.5,
      ),
      headlineLarge: GoogleFonts.outfit(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: primaryColor,
      ),
      headlineMedium: GoogleFonts.outfit(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: primaryColor,
      ),
      headlineSmall: GoogleFonts.outfit(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: primaryColor,
      ),
      titleLarge: GoogleFonts.plusJakartaSans(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: primaryColor,
      ),
      titleMedium: GoogleFonts.plusJakartaSans(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: primaryColor,
        letterSpacing: 0.1,
      ),
      titleSmall: GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: primaryColor,
      ),
      bodyLarge: GoogleFonts.plusJakartaSans(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: primaryColor,
        height: 1.6,
      ),
      bodyMedium: GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: secondaryColor,
        height: 1.6,
      ),
      bodySmall: GoogleFonts.plusJakartaSans(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: secondaryColor,
      ),
      labelLarge: GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: primaryColor,
        letterSpacing: 0.5,
      ),
      labelMedium: GoogleFonts.plusJakartaSans(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: secondaryColor,
        letterSpacing: 0.5,
      ),
    );
  }

  // --- Light Theme ---
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: backgroundLight,
    colorScheme: ColorScheme.light(
      primary: primary,
      onPrimary: Colors.white,
      primaryContainer: Color(0xFFE0E7FF),
      onPrimaryContainer: primaryDark,
      secondary: secondary,
      onSecondary: Colors.white,
      secondaryContainer: Color(0xFFCCFBF1),
      onSecondaryContainer: secondaryDark,
      surface: surfaceLight,
      onSurface: textPrimaryLight,
      surfaceContainerHighest: Color(0xFFF1F5F9),
      error: error,
      onError: Colors.white,
      outline: Color(0xFFE2E8F0),
      outlineVariant: Color(0xFFF1F5F9), // Subtle borders
    ),
    
    // Typography
    textTheme: _buildTextTheme(textPrimaryLight, textSecondaryLight),
    
    // Components
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      scrolledUnderElevation: 0,
      iconTheme: const IconThemeData(color: textPrimaryLight),
      titleTextStyle: GoogleFonts.outfit(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: textPrimaryLight,
      ),
    ),
    
    cardTheme: CardThemeData(
      color: surfaceLight,
      elevation: 0, // Flat design
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        side: const BorderSide(color: Color(0xFFE2E8F0), width: 1),
      ),
      margin: EdgeInsets.zero,
    ),
    
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0,
        shadowColor: Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: paddingLarge, vertical: 18),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16), // Softer corners
        ),
        textStyle: GoogleFonts.plusJakartaSans(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    ),
    
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        padding: const EdgeInsets.symmetric(horizontal: paddingLarge, vertical: 18),
        textStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primary,
        padding: const EdgeInsets.symmetric(horizontal: paddingLarge, vertical: 18),
        side: const BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        textStyle: GoogleFonts.plusJakartaSans(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: paddingMedium, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: error),
      ),
      labelStyle: GoogleFonts.plusJakartaSans(color: textSecondaryLight, fontWeight: FontWeight.w500),
      hintStyle: GoogleFonts.plusJakartaSans(color: textTertiaryLight),
      floatingLabelStyle: GoogleFonts.plusJakartaSans(color: primary, fontWeight: FontWeight.w600),
    ),
  );

  // --- Dark Theme ---
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: backgroundDark,
    colorScheme: ColorScheme.dark(
      primary: primaryLight, // Lighter primary for dark mode
      onPrimary: backgroundDark,
      primaryContainer: primary.withValues(alpha: 0.3),
      onPrimaryContainer: Colors.white,
      secondary: secondaryLight,
      onSecondary: backgroundDark,
      surface: surfaceDark,
      onSurface: textPrimaryDark,
      surfaceContainerHighest: Color(0xFF1E293B), // Slate 800
      error: Color(0xFFF87171),
      onError: backgroundDark,
      outline: Color(0xFF334155),
    ),
    
    textTheme: _buildTextTheme(textPrimaryDark, textSecondaryDark),
    
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      scrolledUnderElevation: 0,
      iconTheme: const IconThemeData(color: textPrimaryDark),
      titleTextStyle: GoogleFonts.outfit(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: textPrimaryDark,
      ),
    ),
    
    cardTheme: CardThemeData(
      color: surfaceDark,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        side: const BorderSide(color: Color(0xFF334155), width: 1),
      ),
      margin: EdgeInsets.zero,
    ),
    
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryLight,
        foregroundColor: backgroundDark,
        elevation: 0,
        shadowColor: Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: paddingLarge, vertical: 18),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        textStyle: GoogleFonts.plusJakartaSans(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),

    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        padding: const EdgeInsets.symmetric(horizontal: paddingLarge, vertical: 18),
        textStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
      ),
    ),
    
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryLight,
        padding: const EdgeInsets.symmetric(horizontal: paddingLarge, vertical: 18),
        side: const BorderSide(color: Color(0xFF334155), width: 1.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        textStyle: GoogleFonts.plusJakartaSans(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF1E293B), // surfaceDark
      contentPadding: const EdgeInsets.symmetric(horizontal: paddingMedium, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFF334155)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFF334155)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: primaryLight, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: error),
      ),
      labelStyle: GoogleFonts.plusJakartaSans(color: textSecondaryDark),
      hintStyle: GoogleFonts.plusJakartaSans(color: textTertiaryDark),
      floatingLabelStyle: GoogleFonts.plusJakartaSans(color: primaryLight, fontWeight: FontWeight.w600),
    ),
  );
  
  // Helpers modernisés
  static List<BoxShadow> get softShadow => [
    BoxShadow(
      color: const Color(0xFF4338CA).withValues(alpha: 0.1), // Primary Hint
      blurRadius: 20,
      offset: const Offset(0, 10),
      spreadRadius: -5,
    ),
  ];
  
  static List<BoxShadow> get cardShadow => [
     BoxShadow(
      color: Colors.black.withValues(alpha: 0.03),
      blurRadius: 10,
      offset: const Offset(0, 2),
    ),
  ];
}
