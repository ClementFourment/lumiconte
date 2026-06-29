import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'config/firebase_options.dart';
import 'config/router.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const LumiconteApp());
}

class LumiconteApp extends StatelessWidget {
  const LumiconteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Lumiconte',
      routerConfig: appRouter,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        textTheme: GoogleFonts.nunitoTextTheme(
          Theme.of(context).textTheme,
        ).copyWith(
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
  }
}
