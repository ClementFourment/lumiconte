import 'package:flutter/material.dart';

class AppTheme {
  // Couleurs réutilisables Lumiconte
  static const Color accentColor = Color(0xFFFDB833); // Doré Lumiconte

  static const Color lightBg = Color(0xFFF8F9FA);
  static const Color lightCard = Colors.white;

  static const Color darkBg = Color(0xFF1E1B29); // Fond de l'app (violet nuit)
  static const Color darkCard = Color(0xFF2D283E); // Cartes / Surface

  /// Raccourci pour obtenir la couleur de carte selon le thème actif
  static Color getCardColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkCard
        : lightCard;
  }

  // --- THÈME CLAIR ---
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: lightBg,
    primaryColor: accentColor,
    splashColor: accentColor.withValues(alpha: 0.2),
    highlightColor: accentColor.withValues(alpha: 0.1),
    colorScheme: const ColorScheme.light(
      primary: accentColor,
      secondary: accentColor,
      surface: lightCard,
      onSurface: Colors.black87,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      foregroundColor: Colors.black,
      titleTextStyle: TextStyle(
        color: Colors.black,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    ),
    cardTheme: CardThemeData(
      color: lightCard,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
  );

  // --- THÈME SOMBRE ---
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: darkBg,
    primaryColor: accentColor,
    splashColor: accentColor.withValues(alpha: 0.2),
    highlightColor: accentColor.withValues(alpha: 0.1),
    colorScheme: const ColorScheme.dark(
      primary: accentColor,
      secondary: accentColor,
      surface: darkCard,
      onSurface: Colors.white,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      foregroundColor: Colors.white,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    ),
    cardTheme: CardThemeData(
      color: darkCard,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
  );
}