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
  print("1. Starter main");
  WidgetsFlutterBinding.ensureInitialized();
  
  print("2. Avant dotenv");
  await dotenv.load();  

print("3. Avant Firebase");
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      print("Firebase initialisé avec succès : [DEFAULT]");
    } else {
      print("Firebase était déjà prêt dans cet isolate.");
    }
  } catch (e) {
    print("Log d'info : Firebase déjà actif ($e)");
  }

  // 🟢 AJOUT OBLIGATOIRE :
  // Attend que l'application Firebase soit réellement disponible
  while (Firebase.apps.isEmpty) {
    await Future.delayed(const Duration(milliseconds: 50));
  }

  print("4. Instanciation de AppSettings");
  appSettings = AppSettings();
  
  print("5. Initialisation asynchrone des services");
  await appSettings.init();
  
  print("6. Lancement runApp");
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