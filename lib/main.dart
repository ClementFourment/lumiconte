import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'config/firebase_options.dart';
import 'config/router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lumiconte/services/app_settings.dart';

final appSettings = AppSettings();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );

  runApp(const LumiconteApp());
}

class LumiconteApp extends StatelessWidget {
  const LumiconteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: appSettings,
      builder: (context, child) {
        // On récupère le style de base propre à chaque mode pour éviter le conflit d'interpolation
        final lightTextTheme = Typography.material2021(platform: TargetPlatform.android).black;
        final darkTextTheme = Typography.material2021(platform: TargetPlatform.android).white;

        return MaterialApp.router(
          title: 'Lumiconte',
          routerConfig: appRouter,
          debugShowCheckedModeBanner: false,
          themeMode: appSettings.isDarkMode ? ThemeMode.dark : ThemeMode.light,

          // ☀️ THÈME CLAIR
          theme: ThemeData(
            brightness: Brightness.light,
            primarySwatch: Colors.indigo,
            scaffoldBackgroundColor: const Color(0xFFF8F9FA),
            cardColor: Colors.white,
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
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            primarySwatch: Colors.indigo,
            scaffoldBackgroundColor: const Color(0xFF121212), 
            cardColor: const Color(0xFF1E1E1E), 
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