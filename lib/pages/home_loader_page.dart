import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lumiconte/main.dart'; // Import pour accéder à appSettings
import 'package:lumiconte/models/category_model.dart';
import 'package:lumiconte/models/profile_model.dart';
import 'package:lumiconte/models/story_model.dart';
import 'package:lumiconte/services/profile_service.dart';
import 'package:lumiconte/pages/home_page.dart';
import 'package:lumiconte/pages/profile_creation_page.dart'; // Import de la page de création

class HomePageLoader extends StatelessWidget {
  final List<CategoryModel> categories;
  final List<StoryModel> stories;

  const HomePageLoader({
    super.key,
    required this.categories,
    required this.stories,
  });

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final profileService = ProfileService();

    if (uid == null) {
      return const Scaffold(
          body: Center(child: Text('Utilisateur non connecté')));
    }

    // 1. Écoute en temps réel de l'utilisateur (pour activeProfileId)
    return StreamBuilder<DocumentSnapshot>(
      stream:
          FirebaseFirestore.instance.collection('users').doc(uid).snapshots(),
      builder: (context, userSnapshot) {
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }

        final userData = userSnapshot.data?.data() as Map<String, dynamic>?;
        final activeProfileId = userData?['activeProfileId'] as String?;

        // 2. Écoute de la liste des profils
        return StreamBuilder<List<ProfileModel>>(
          stream: profileService.getUserProfilesStream(uid),
          builder: (context, profilesSnapshot) {
            if (profilesSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                  body: Center(child: CircularProgressIndicator()));
            }

            final profiles = profilesSnapshot.data ?? [];

            // CAS 0 PROFIL : Redirection directe vers la création sans créer de nouvelle page d'aiguillage
            if (profiles.isEmpty) {
              return const ProfileCreationPage();
            }

            // Récupérer le profil actif sélectionné ou prendre le premier de la liste
            ProfileModel activeProfile;
            if (activeProfileId != null) {
              activeProfile = profiles.firstWhere(
                (p) => p.id == activeProfileId,
                orElse: () => profiles.first,
              );
            } else {
              activeProfile = profiles.first;
            }

            // 3. Écoute des paramètres (thème sombre/clair) du profil actif
            return StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(uid)
                  .collection('profiles')
                  .doc(activeProfile.id)
                  .collection('settings')
                  .snapshots(),
              builder: (context, settingsSnapshot) {
                if (settingsSnapshot.hasData &&
                    settingsSnapshot.data!.docs.isNotEmpty) {
                  final settingsData = settingsSnapshot.data!.docs.first.data()
                      as Map<String, dynamic>;
                  final bool isDarkMode = settingsData['theme'] == 'dark';

                  // Application automatique du thème du profil chargé
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    appSettings.toggleDarkMode(activeProfile.id, isDarkMode);
                  });
                }

                return HomePage(
                  profile: activeProfile,
                  categories: categories,
                  stories: stories,
                );
              },
            );
          },
        );
      },
    );
  }
}
