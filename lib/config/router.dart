import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lumiconte/models/story_model.dart';
import 'package:lumiconte/pages/onboarding_page.dart';
import 'package:lumiconte/pages/login_page.dart';
import 'package:lumiconte/navigation/bottom_nav.dart';
import 'package:lumiconte/pages/profile_creation_page.dart';
import 'package:lumiconte/pages/manage_profiles_page.dart'; // Importez votre page de gestion des profils
import 'package:lumiconte/pages/story_page.dart';
import 'package:lumiconte/services/profile_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  refreshListenable: GoRouterRefreshStream(
    FirebaseAuth.instance.authStateChanges(),
  ),
  redirect: (context, state) async {
    final user = FirebaseAuth.instance.currentUser;
    final prefs = await SharedPreferences.getInstance();
    final hasSeenOnboarding = prefs.getBool('seen_onboarding') ?? false;

    final location = state.matchedLocation;
    final isOnboarding = location == '/';
    final isLogin = location == '/login';
    final isProfileCreation = location == '/create-profile';

    // 1. Si pas vu l'onboarding → afficher onboarding
    if (!hasSeenOnboarding) {
      if (!isOnboarding) return '/';
      return null;
    }

    // 2. Si pas connecté → afficher login
    if (user == null) {
      if (!isLogin) return '/login';
      return null;
    }

    // 3. Si connecté mais aucun profil créé → forcer la création de profil
    final profileService = ProfileService();
    final profiles = await profileService.getUserProfiles(user.uid);

    if (profiles.isEmpty) {
      if (!isProfileCreation) return '/create-profile';
      return null;
    }

    // 4. Si connecté avec un profil et tente d'aller sur les pages de démarrage → rediriger vers /home
    if (isOnboarding || isLogin || isProfileCreation) {
      return '/home';
    }

    return null;
  },
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const OnboardingPage(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: '/create-profile',
      builder: (context, state) => const ProfileCreationPage(),
    ),
    GoRoute(
      path: '/manage-profiles',
      builder: (context, state) => const ManageProfilesPage(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const BottomNav(),
    ),
    GoRoute(
      path: '/story',
      builder: (context, state) {
        final story = state.extra as StoryModel?;
        if (story == null) {
          return const BottomNav();
        }
        return StoryPage(story: story);
      },
    ),
  ],
);

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  late final StreamSubscription _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}