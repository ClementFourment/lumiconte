import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  /// Titres en Fredoka (police arrondie, identité enfant), textes courants en
  /// Nunito (très lisible).
  static TextTheme buildTextTheme(TextTheme base) {
    final body = GoogleFonts.nunitoTextTheme(base);
    TextStyle? title(TextStyle? style) =>
        GoogleFonts.fredoka(textStyle: style, fontWeight: FontWeight.w600);

    return body.copyWith(
      displayLarge: title(body.displayLarge),
      displayMedium: title(body.displayMedium),
      displaySmall: title(body.displaySmall),
      headlineLarge: title(body.headlineLarge),
      headlineMedium: title(body.headlineMedium),
      headlineSmall: title(body.headlineSmall),
      titleLarge: title(body.titleLarge),
      titleMedium: title(body.titleMedium),
      titleSmall: title(body.titleSmall),
    );
  }

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
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      foregroundColor: Colors.black,
      titleTextStyle: GoogleFonts.fredoka(
        color: Colors.black,
        fontSize: 22,
        fontWeight: FontWeight.w600,
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
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      foregroundColor: Colors.white,
      titleTextStyle: GoogleFonts.fredoka(
        color: Colors.white,
        fontSize: 22,
        fontWeight: FontWeight.w600,
      ),
    ),
    cardTheme: CardThemeData(
      color: darkCard,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
  );
}
