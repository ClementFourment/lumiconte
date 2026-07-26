import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lumiconte/models/category_model.dart';
import 'package:lumiconte/models/profile_model.dart';
import 'package:lumiconte/models/story_model.dart';
import 'package:lumiconte/services/profile_service.dart';
import 'package:lumiconte/pages/home_page.dart'; // Ajustez le chemin selon votre projet

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
      return const Scaffold(body: Center(child: Text('Utilisateur non connecté')));
    }

    // Écoute en temps réel des profils et du profil actif
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(uid).snapshots(),
      builder: (context, userSnapshot) {
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final userData = userSnapshot.data?.data() as Map<String, dynamic>?;
        final activeProfileId = userData?['activeProfileId'] as String?;

        return StreamBuilder<List<ProfileModel>>(
          stream: profileService.getUserProfilesStream(uid),
          builder: (context, profilesSnapshot) {
            if (profilesSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(body: Center(child: CircularProgressIndicator()));
            }

            final profiles = profilesSnapshot.data ?? [];

            if (profiles.isEmpty) {
              return const Scaffold(
                body: Center(child: Text('Aucun profil trouvé. Veuillez en créer un.')),
              );
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

            // Transmettre le profil actif mis à jour à HomePage
            return HomePage(
              profile: activeProfile,
              categories: categories,
              stories: stories,
            );
          },
        );
      },
    );
  }
}