import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lumiconte/models/story_model.dart';
import 'package:lumiconte/services/category_service.dart';
import 'package:lumiconte/services/story_service.dart';
import '../models/profile_model.dart';
import '../models/category_model.dart';
import '../services/profile_service.dart';
import '../pages/home_page.dart';
import '../pages/profile_page.dart';
import '../pages/library_page.dart';
import '../pages/favorites_page.dart';

class BottomNav extends StatefulWidget {
  const BottomNav({super.key});

  @override
  State<BottomNav> createState() => _BottomNavState();
}

class DataFuture {
  final List<ProfileModel> profiles;
  final List<CategoryModel> categories;
  final List<StoryModel> stories;

  DataFuture({
    required this.profiles,
    required this.categories,
    required this.stories,
  });
}

class _BottomNavState extends State<BottomNav> {
  int index = 0;
  final ProfileService _profileService = ProfileService();
  final CategoryService _categoryService = CategoryService();
  final StoryService _storyService = StoryService();

  late final Future<DataFuture> _dataFuture;

  @override
  void initState() {
    super.initState();
    // on fetch une seule fois !! à l'ouverture !! pas à chaque changement d'onglet.
    final uid = FirebaseAuth.instance.currentUser!.uid;

    _dataFuture = _loadData(uid);
  }

  Future<DataFuture> _loadData(String uid) async {
    final profiles = await _profileService.getUserProfiles(uid);
    final categories = await _categoryService.getAllCategories();
    final stories = await _storyService.getAllStories();

    return DataFuture(
      profiles: profiles,
      categories: categories,
      stories: stories,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DataFuture>(
      future: _dataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return const Scaffold(
            body: Center(child: Text("Erreur de chargement")),
          );
        }

        final data = snapshot.data!;
        final profiles = data.profiles;
        final categories = data.categories;
        final stories = data.stories;

        if (profiles.isEmpty) {
          // Ne devrait normalement pas arriver : le router redirige déjà
          // vers /create-profile si l'utilisateur n'a aucun profil.. normalement.
          return const Scaffold(
            body: Center(child: Text("Aucun profil trouvé")),
          );
        }

        final profile =
            profiles.first; // a changer plus tard si y a plusieurs profils....

        final pages = [
          HomePage(profile: profile, categories: categories, stories: stories),
          const LibraryPage(),
          const FavoritesPage(),
          const ProfilePage(),
        ];

        return Scaffold(
          body: pages[index],
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: index,
            onTap: (value) => setState(() => index = value),
            type: BottomNavigationBarType.fixed,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: "Accueil"),
              BottomNavigationBarItem(
                  icon: Icon(Icons.menu_book), label: "Bibliothèque"),
              BottomNavigationBarItem(
                  icon: Icon(Icons.favorite), label: "Favoris"),
              BottomNavigationBarItem(
                  icon: Icon(Icons.person), label: "Profil"),
            ],
          ),
        );
      },
    );
  }
}
