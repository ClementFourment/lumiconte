import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'router.dart';
import 'dart:async';

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
      theme: ThemeData(primarySwatch: Colors.indigo),
    );
  }
}