import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Importations des modèles et services
import 'package:lumiconte/models/story_model.dart';
import 'package:lumiconte/models/profile_model.dart';
import 'package:lumiconte/models/category_model.dart';
import 'package:lumiconte/services/category_service.dart';
import 'package:lumiconte/services/story_service.dart';
import 'package:lumiconte/services/profile_service.dart';

// Importations des pages
import 'package:lumiconte/pages/home_page.dart';
import 'package:lumiconte/pages/profile_page.dart';
import 'package:lumiconte/pages/library_page.dart';
import 'package:lumiconte/pages/favorites_page.dart';

class BottomNav extends StatefulWidget {
  const BottomNav({super.key});

  @override
  State<BottomNav> createState() => _BottomNavState();
}

class DataFuture {
  final List<CategoryModel> categories;
  final List<StoryModel> stories;

  DataFuture({
    required this.categories,
    required this.stories,
  });
}

class _BottomNavState extends State<BottomNav> {
  int _currentIndex = 0;
  
  final ProfileService _profileService = ProfileService();
  final CategoryService _categoryService = CategoryService();
  final StoryService _storyService = StoryService();

  late final Future<DataFuture> _dataFuture;
  final String? _uid = FirebaseAuth.instance.currentUser?.uid;

  @override
  void initState() {
    super.initState();
    _dataFuture = _loadStaticData();
  }

  Future<DataFuture> _loadStaticData() async {
    final categories = await _categoryService.getAllCategories();
    final stories = await _storyService.getAllStories();

    return DataFuture(
      categories: categories,
      stories: stories,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_uid == null) {
      return const Scaffold(
        body: Center(child: Text("Utilisateur non connecté.")),
      );
    }

    return FutureBuilder<DataFuture>(
      future: _dataFuture,
      builder: (context, staticSnapshot) {
        if (staticSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (staticSnapshot.hasError || !staticSnapshot.hasData) {
          return const Scaffold(
            body: Center(child: Text("Erreur lors du chargement des données")),
          );
        }

        final categories = staticSnapshot.data!.categories;
        final stories = staticSnapshot.data!.stories;

        // Écoute en temps réel du profil actif enregistré sur l'utilisateur
        return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance.collection('users').doc(_uid).snapshots(),
          builder: (context, userSnapshot) {
            final activeProfileId = userSnapshot.data?.data()?['activeProfileId'] as String?;

            // Écoute en temps réel de tous les profils rattachés
            return StreamBuilder<List<ProfileModel>>(
              stream: _profileService.getUserProfilesStream(_uid!),
              builder: (context, profilesSnapshot) {
                if (profilesSnapshot.connectionState == ConnectionState.waiting) {
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                }

                final profiles = profilesSnapshot.data ?? [];

                if (profiles.isEmpty) {
                  return const Scaffold(
                    body: Center(child: Text("Aucun profil trouvé")),
                  );
                }

                // Résolution du profil actif
                ProfileModel activeProfile;
                if (activeProfileId != null) {
                  activeProfile = profiles.firstWhere(
                    (p) => p.id == activeProfileId,
                    orElse: () => profiles.first,
                  );
                } else {
                  activeProfile = profiles.first;
                }

                // Utilisation des ValueKey basées sur activeProfile.id
                // pour forcer la reconstruction si le profil actif change.
                final pages = [
                  HomePage(
                    key: ValueKey('home_${activeProfile.id}'),
                    profile: activeProfile,
                    categories: categories,
                    stories: stories,
                  ),
                  LibraryPage(
                    key: ValueKey('library_${activeProfile.id}'),
                    profileId: activeProfile.id,
                    categories: categories,
                    stories: stories,
                  ),
                  FavoritesPage(
                    key: ValueKey('favorites_${activeProfile.id}'),
                    profileId: activeProfile.id,
                  ),
                  ProfilePage(
                    key: ValueKey('profile_${activeProfile.id}'),
                    profileId: activeProfile.id,
                  ),
                ];

                return Scaffold(
                  body: pages[_currentIndex],
                  bottomNavigationBar: BottomNavigationBar(
                    currentIndex: _currentIndex,
                    onTap: (value) => setState(() => _currentIndex = value),
                    type: BottomNavigationBarType.fixed,
                    items: const [
                      BottomNavigationBarItem(
                        icon: Icon(Icons.home), 
                        label: "Accueil",
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.menu_book), 
                        label: "Bibliothèque",
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.favorite), 
                        label: "Favoris",
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.person), 
                        label: "Profil",
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}