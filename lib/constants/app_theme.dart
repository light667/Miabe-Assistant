import 'package:flutter/material.dart';

/// Constantes de design de l'application Miabe Assistant
class AppTheme {
  // Couleurs principales
  static const Color primaryBlue = Color(0xFF5B8DEF);
  static const Color primaryBlueDark = Color(0xFF4A7AC9);
  static const Color primaryBlueLight = Color(0xFF89B4FA);
  static const Color accentGold = Color(0xFFFBBF24);
  
  // Couleurs de texte
  static const Color textPrimary = Color(0xFF1F2937);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textLight = Color(0xFF9CA3AF);
  
  // Couleurs de fond
  static const Color backgroundLight = Color(0xFFF3F4F6);
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceLight = Colors.white;
  static const Color surfaceDark = Color(0xFF1E1E1E);
  
  // Tailles de police
  static const double fontSizeXSmall = 12.0;
  static const double fontSizeSmall = 14.0;
  static const double fontSizeMedium = 16.0;
  static const double fontSizeLarge = 18.0;
  static const double fontSizeXLarge = 24.0;
  static const double fontSizeXXLarge = 32.0;
  static const double fontSizeHuge = 36.0;
  
  // Espacements
  static const double spacingXSmall = 4.0;
  static const double spacingSmall = 8.0;
  static const double spacingMedium = 16.0;
  static const double spacingLarge = 24.0;
  static const double spacingXLarge = 32.0;
  static const double spacingXXLarge = 48.0;
  
  // Bordures
  static const double borderRadiusSmall = 8.0;
  static const double borderRadiusMedium = 12.0;
  static const double borderRadiusLarge = 16.0;
  static const double borderRadiusXLarge = 20.0;
  static const double borderRadiusCircular = 100.0;
  
  // Élévations
  static const double elevationSmall = 2.0;
  static const double elevationMedium = 4.0;
  static const double elevationLarge = 8.0;
  static const double elevationXLarge = 12.0;
  
  // Tailles d'icônes
  static const double iconSizeSmall = 20.0;
  static const double iconSizeMedium = 24.0;
  static const double iconSizeLarge = 32.0;
  static const double iconSizeXLarge = 48.0;
  
  // Thème clair
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      primary: primaryBlue,
      secondary: accentGold,
      surface: surfaceLight,
      background: backgroundLight,
      error: Color(0xFFDC2626),
      onPrimary: Colors.white,
      onSecondary: Color(0xFF1F2937),
      onSurface: textPrimary,
      onBackground: textPrimary,
    ),
    
    // Police par défaut
    fontFamily: 'Roboto',
    
    // Thème du texte
    textTheme: const TextTheme(
      displayLarge: TextStyle(fontSize: fontSizeHuge, fontWeight: FontWeight.w900, color: textPrimary),
      displayMedium: TextStyle(fontSize: fontSizeXXLarge, fontWeight: FontWeight.w800, color: textPrimary),
      displaySmall: TextStyle(fontSize: fontSizeXLarge, fontWeight: FontWeight.w700, color: textPrimary),
      
      headlineLarge: TextStyle(fontSize: fontSizeXLarge, fontWeight: FontWeight.w700, color: textPrimary),
      headlineMedium: TextStyle(fontSize: fontSizeLarge, fontWeight: FontWeight.w600, color: textPrimary),
      headlineSmall: TextStyle(fontSize: fontSizeMedium, fontWeight: FontWeight.w600, color: textPrimary),
      
      titleLarge: TextStyle(fontSize: fontSizeLarge, fontWeight: FontWeight.w600, color: textPrimary),
      titleMedium: TextStyle(fontSize: fontSizeMedium, fontWeight: FontWeight.w500, color: textPrimary),
      titleSmall: TextStyle(fontSize: fontSizeSmall, fontWeight: FontWeight.w500, color: textPrimary),
      
      bodyLarge: TextStyle(fontSize: fontSizeMedium, fontWeight: FontWeight.w400, color: textPrimary),
      bodyMedium: TextStyle(fontSize: fontSizeSmall, fontWeight: FontWeight.w400, color: textPrimary),
      bodySmall: TextStyle(fontSize: fontSizeXSmall, fontWeight: FontWeight.w400, color: textSecondary),
      
      labelLarge: TextStyle(fontSize: fontSizeMedium, fontWeight: FontWeight.w500, color: textPrimary),
      labelMedium: TextStyle(fontSize: fontSizeSmall, fontWeight: FontWeight.w500, color: textSecondary),
      labelSmall: TextStyle(fontSize: fontSizeXSmall, fontWeight: FontWeight.w500, color: textLight),
    ),
    
    // Thème de l'AppBar
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: primaryBlue),
      titleTextStyle: TextStyle(
        color: primaryBlue,
        fontSize: fontSizeLarge,
        fontWeight: FontWeight.w700,
      ),
    ),
    
    // Thème des cartes
    cardTheme: CardThemeData(
      elevation: elevationMedium,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadiusLarge),
      ),
      color: surfaceLight,
    ),
    
    // Thème des boutons
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        elevation: elevationSmall,
        padding: const EdgeInsets.symmetric(horizontal: spacingLarge, vertical: spacingMedium),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadiusMedium),
        ),
        textStyle: const TextStyle(
          fontSize: fontSizeMedium,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryBlue,
        textStyle: const TextStyle(
          fontSize: fontSizeMedium,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    
    // Thème des champs de texte
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceLight,
      contentPadding: const EdgeInsets.symmetric(horizontal: spacingMedium, vertical: spacingMedium),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadiusMedium),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadiusMedium),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadiusMedium),
        borderSide: const BorderSide(color: primaryBlue, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadiusMedium),
        borderSide: const BorderSide(color: Color(0xFFDC2626)),
      ),
    ),
  );
  
  // Thème sombre
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: primaryBlueLight,
      secondary: accentGold,
      surface: surfaceDark,
      background: backgroundDark,
      error: Color(0xFFEF4444),
      onPrimary: Color(0xFF1F2937),
      onSecondary: Color(0xFF1F2937),
      onSurface: Colors.white,
      onBackground: Colors.white,
    ),
    
    fontFamily: 'Roboto',
    
    textTheme: const TextTheme(
      displayLarge: TextStyle(fontSize: fontSizeHuge, fontWeight: FontWeight.w900, color: Colors.white),
      displayMedium: TextStyle(fontSize: fontSizeXXLarge, fontWeight: FontWeight.w800, color: Colors.white),
      displaySmall: TextStyle(fontSize: fontSizeXLarge, fontWeight: FontWeight.w700, color: Colors.white),
      
      headlineLarge: TextStyle(fontSize: fontSizeXLarge, fontWeight: FontWeight.w700, color: Colors.white),
      headlineMedium: TextStyle(fontSize: fontSizeLarge, fontWeight: FontWeight.w600, color: Colors.white),
      headlineSmall: TextStyle(fontSize: fontSizeMedium, fontWeight: FontWeight.w600, color: Colors.white),
      
      titleLarge: TextStyle(fontSize: fontSizeLarge, fontWeight: FontWeight.w600, color: Colors.white),
      titleMedium: TextStyle(fontSize: fontSizeMedium, fontWeight: FontWeight.w500, color: Colors.white),
      titleSmall: TextStyle(fontSize: fontSizeSmall, fontWeight: FontWeight.w500, color: Colors.white),
      
      bodyLarge: TextStyle(fontSize: fontSizeMedium, fontWeight: FontWeight.w400, color: Colors.white),
      bodyMedium: TextStyle(fontSize: fontSizeSmall, fontWeight: FontWeight.w400, color: Colors.white),
      bodySmall: TextStyle(fontSize: fontSizeXSmall, fontWeight: FontWeight.w400, color: Color(0xFFD1D5DB)),
      
      labelLarge: TextStyle(fontSize: fontSizeMedium, fontWeight: FontWeight.w500, color: Colors.white),
      labelMedium: TextStyle(fontSize: fontSizeSmall, fontWeight: FontWeight.w500, color: Color(0xFFD1D5DB)),
      labelSmall: TextStyle(fontSize: fontSizeXSmall, fontWeight: FontWeight.w500, color: Color(0xFF9CA3AF)),
    ),
    
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: fontSizeLarge,
        fontWeight: FontWeight.w700,
      ),
    ),
    
    cardTheme: CardThemeData(
      elevation: elevationMedium,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadiusLarge),
      ),
      color: surfaceDark,
    ),
    
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryBlueLight,
        foregroundColor: Color(0xFF1F2937),
        elevation: elevationSmall,
        padding: const EdgeInsets.symmetric(horizontal: spacingLarge, vertical: spacingMedium),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadiusMedium),
        ),
        textStyle: const TextStyle(
          fontSize: fontSizeMedium,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryBlueLight,
        textStyle: const TextStyle(
          fontSize: fontSizeMedium,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Color(0xFF2D2D2D),
      contentPadding: const EdgeInsets.symmetric(horizontal: spacingMedium, vertical: spacingMedium),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadiusMedium),
        borderSide: const BorderSide(color: Color(0xFF404040)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadiusMedium),
        borderSide: const BorderSide(color: Color(0xFF404040)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadiusMedium),
        borderSide: const BorderSide(color: primaryBlueLight, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadiusMedium),
        borderSide: const BorderSide(color: Color(0xFFEF4444)),
      ),
    ),
  );
  
  // Ombres standard
  static List<BoxShadow> shadowSmall(Color color) => [
    BoxShadow(
      color: color.withValues(alpha: 0.1),
      blurRadius: 4,
      offset: const Offset(0, 2),
    ),
  ];
  
  static List<BoxShadow> shadowMedium(Color color) => [
    BoxShadow(
      color: color.withValues(alpha: 0.15),
      blurRadius: 8,
      offset: const Offset(0, 4),
    ),
  ];
  
  static List<BoxShadow> shadowLarge(Color color) => [
    BoxShadow(
      color: color.withValues(alpha: 0.2),
      blurRadius: 15,
      offset: const Offset(0, 8),
    ),
  ];
  
  static List<BoxShadow> shadowXLarge(Color color) => [
    BoxShadow(
      color: color.withValues(alpha: 0.25),
      blurRadius: 20,
      offset: const Offset(0, 10),
    ),
  ];
}
