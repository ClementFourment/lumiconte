import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../pages/onboarding_page.dart';
import '../pages/login_page.dart';
import '../pages/home_page.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  refreshListenable:
      GoRouterRefreshStream(FirebaseAuth.instance.authStateChanges()),
  redirect: (context, state) {
    final user = FirebaseAuth.instance.currentUser;
    final isLoggedIn = user != null;

    final isGoingToLogin = state.matchedLocation == '/login';
    final isGoingToOnboarding = state.matchedLocation == '/';

    if (!isLoggedIn && !isGoingToLogin && !isGoingToOnboarding) {
      return '/login';
    }

    if (isLoggedIn && isGoingToLogin) {
      return '/home';
    }

    return null;
  },
  routes: [
    GoRoute(path: '/', builder: (context, state) => const OnboardingPage()),
    GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
    GoRoute(path: '/home', builder: (context, state) => const HomePage()),
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
