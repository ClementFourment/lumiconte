import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lumiconte/models/profile_model.dart';

import 'package:lumiconte/models/story_model.dart';
import 'package:lumiconte/pages/onboarding_page.dart';
import 'package:lumiconte/pages/login_page.dart';
import 'package:lumiconte/navigation/bottom_nav.dart';
import 'package:lumiconte/pages/profile_creation_page.dart';
import 'package:lumiconte/pages/manage_profiles_page.dart';
import 'package:lumiconte/pages/settings_page.dart';
import 'package:lumiconte/pages/story/story_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Notifier personnalisé qui signale à GoRouter de réévaluer le `redirect`
/// lors d'un changement d'Auth OU de changement dans le document User Firestore.
class AppRouterNotifier extends ChangeNotifier {
  StreamSubscription? _authSub;
  StreamSubscription? _userDocSub;

  AppRouterNotifier() {
    _authSub = FirebaseAuth.instance.authStateChanges().listen((user) {
      _userDocSub?.cancel();
      if (user != null) {
        _userDocSub = FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .snapshots()
            .listen((_) => notifyListeners());
      }
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _authSub?.cancel();
    _userDocSub?.cancel();
    super.dispose();
  }
}

final AppRouterNotifier _routerNotifier = AppRouterNotifier();

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  refreshListenable: _routerNotifier,
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

    // 3. Vérification s'il existe au moins un profil
    final profiles = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('profiles')
        .get();

    final hasActiveProfile = profiles.docs.isNotEmpty;

    // S'il n'a AUCUN profil actif, il doit obligatoirement en créer un
    if (!hasActiveProfile) {
      if (!isProfileCreation) return '/create-profile';
      return null;
    }

    // 4. Si connecté avec un profil actif :
    // Redirection automatique depuis l'Onboarding ou le Login vers la gestion des profils
    if (isOnboarding || isLogin) {
      return '/manage-profiles'; // 👈 Modifié ici (/home -> /manage-profiles)
    }

    // - On autorise l'accès à /create-profile pour ajouter d'autres profils
    if (isProfileCreation) {
      return null;
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
        final extras = state.extra as Map<String, dynamic>? ?? {};
        final story = extras['story'] as StoryModel?;
        final profile = extras['profile'] as ProfileModel?;

        if (story == null || profile == null) {
          return const BottomNav();
        }
        return StoryPage(story: story, profile: profile);
      },
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) {
        final extras = state.extra as Map<String, dynamic>;
        final profileId = extras['profileId'] as String;
        return SettingsPage(profileId: profileId);
      },
    ),
  ],
);
