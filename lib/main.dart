import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:lumiconte/l10n/app_localizations.dart';
import 'package:lumiconte/models/app_language.dart';
import 'package:lumiconte/config/firebase_options.dart';
import 'package:lumiconte/config/router.dart';
import 'package:lumiconte/services/app_settings.dart';
import 'package:lumiconte/theme/app_theme.dart';
import 'package:audio_service/audio_service.dart';
import 'package:lumiconte/services/audio_background_service.dart';

late final AppSettings appSettings;

void main() async {
  // 1. Indispensable avant tout appel async natif
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Initialisation de Firebase sécurisée
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

  // 3. Initialisation des services
  // Avant tout affichage : l'écran de choix du profil arrive avant qu'un
  // profil, donc une langue de profil, existe
  await AppLanguage.restore();

  appSettings = AppSettings();
  await appSettings.init();

  // Initialisation du service audio global
  await AudioService.init(
    builder: () => AudioBackgroundService(),
    config: AudioServiceConfig(
      androidStopForegroundOnPause: false,
      androidNotificationChannelId: 'lumiconte_audio_playback',
      androidNotificationChannelName: 'Lumiconte Audio Playback',
      androidNotificationOngoing: false,
      androidNotificationIcon: 'drawable/ic_notification',
      notificationColor: Color(0xFFF59E0B),
    ),
  );

  // 4. Lancement de l'application
  runApp(const LumiconteApp());
}

class LumiconteApp extends StatelessWidget {
  const LumiconteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: appSettings.themeNotifier,
      builder: (context, isDarkMode, child) {
        final lightTextTheme =
            Typography.material2021(platform: TargetPlatform.android).black;
        final darkTextTheme =
            Typography.material2021(platform: TargetPlatform.android).white;

        // L'app se traduit dans la langue du profil, pas dans celle du
        // téléphone : un parent peut mettre l'app en anglais sur un mobile
        // français, et ses contes suivent le même choix.
        return ValueListenableBuilder<String>(
          valueListenable: AppLanguage.current,
          builder: (context, languageCode, child) => MaterialApp.router(
            title: 'Lumiconte',
            routerConfig: appRouter,
            debugShowCheckedModeBanner: false,
            themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
            locale: AppLanguage.localeOf(languageCode),
            supportedLocales: AppLanguage.supportedLocales,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],

            // ☀️ THÈME CLAIR
            theme: AppTheme.lightTheme.copyWith(
              textTheme: AppTheme.buildTextTheme(lightTextTheme),
            ),

            // 🌙 THÈME SOMBRE
            darkTheme: AppTheme.darkTheme.copyWith(
              textTheme: AppTheme.buildTextTheme(darkTextTheme),
            ),
          ),
        );
      },
    );
  }
}
