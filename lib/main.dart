import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:lumiconte/config/firebase_options.dart';
import 'package:lumiconte/config/router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:lumiconte/services/app_settings.dart';
import 'package:lumiconte/theme/app_theme.dart';

late final AppSettings appSettings;

void main() async {
  // 1. Indispensable avant tout appel async natif
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Chargement du fichier .env
  try {
    await dotenv.load();
  } catch (e) {
    debugPrint("Erreur chargement dotenv: $e");
  }

  // 3. Initialisation de Firebase sécurisée
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } else {
      Firebase.app(); // Reconnecte le SDK Dart à l'instance native existante
    }
  } catch (e) {
    debugPrint("Erreur lors de initializeApp: $e");
  }

  // 4. Initialisation des services
  appSettings = AppSettings();
  await appSettings.init();

  // 5. Lancement de l'application
  runApp(const LumiconteApp());
}

class LumiconteApp extends StatelessWidget {
  const LumiconteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: appSettings,
      builder: (context, child) {
        final lightTextTheme =
            Typography.material2021(platform: TargetPlatform.android).black;
        final darkTextTheme =
            Typography.material2021(platform: TargetPlatform.android).white;

        return MaterialApp.router(
          title: 'Lumiconte',
          routerConfig: appRouter,
          debugShowCheckedModeBanner: false,
          themeMode: appSettings.isDarkMode ? ThemeMode.dark : ThemeMode.light,

          // ☀️ THÈME CLAIR
          theme: AppTheme.lightTheme.copyWith(
            textTheme: GoogleFonts.nunitoTextTheme(lightTextTheme).copyWith(
              titleLarge: GoogleFonts.aBeeZee(
                fontSize: 48,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: -1.2,
                height: 1.0,
              ),
            ),
          ),

          // 🌙 THÈME SOMBRE
          darkTheme: AppTheme.darkTheme.copyWith(
            textTheme: GoogleFonts.nunitoTextTheme(darkTextTheme).copyWith(
              titleLarge: GoogleFonts.aBeeZee(
                fontSize: 48,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: -1.2,
                height: 1.0,
              ),
            ),
          ),
        );
      },
    );
  }
}