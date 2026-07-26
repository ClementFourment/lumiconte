import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lumiconte/models/category_model.dart';
import 'package:lumiconte/models/story_model.dart';
import 'package:lumiconte/models/reading_progress_model.dart';
import 'package:lumiconte/widget/b2_image.dart';
import 'package:go_router/go_router.dart';

class LibraryPage extends StatefulWidget {
  final List<CategoryModel> categories;
  final List<StoryModel> stories;
  final String profileId;

  const LibraryPage({
    super.key,
    required this.categories,
    required this.stories,
    required this.profileId,
  });

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  String _selectedFilter = 'tous';

  /// Combine en temps réel la progression de lecture (ReadingProgressModel)
  /// et la sous-collection des favoris du profil
  Stream<List<QuerySnapshot>> _combineStreams(DocumentReference profileRef) {
    Stream<QuerySnapshot> s1 = profileRef.collection('readingProgress').snapshots();
    Stream<QuerySnapshot> s2 = profileRef.collection('favoris').snapshots();

    QuerySnapshot? lastS1;
    QuerySnapshot? lastS2;

    return Stream<List<QuerySnapshot>>.multi((controller) {
      final sub1 = s1.listen((data) {
        lastS1 = data;
        if (lastS2 != null && !controller.isClosed) controller.add([lastS1!, lastS2!]);
      });
      final sub2 = s2.listen((data) {
        lastS2 = data;
        if (lastS1 != null && !controller.isClosed) controller.add([lastS1!, lastS2!]);
      });

      controller.onCancel = () {
        sub1.cancel();
        sub2.cancel();
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return Scaffold(
        body: Center(
          child: Text(
            'Utilisateur non connecté',
            style: textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      );
    }

    final profileRef = FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .collection('profiles')
        .doc(widget.profileId);

    return StreamBuilder<List<QuerySnapshot>>(
      stream: _combineStreams(profileRef),
      builder: (context, snapshot) {
        Map<String, double> activeProfileReadProgress = {};
        List<String> favoriteStoryIds = [];

        if (snapshot.hasData && snapshot.data!.length == 2) {
          // Parse ReadingProgress via ReadingProgressModel
          final progressDocs = snapshot.data![0].docs;
          for (var doc in progressDocs) {
            try {
              final progressModel = ReadingProgressModel.fromMap(
                doc.data() as Map<String, dynamic>,
                doc.id,
              );
              // Standardisation à un ratio 0.0 - 1.0 pour l'affichage de la barre
              activeProfileReadProgress[progressModel.storyId] =
                  (progressModel.progress / 100.0).clamp(0.0, 1.0);
            } catch (_) {
              // Ignore les documents mal structurés si nécessaire
            }
          }

          // Parse Favoris
          final favoriteDocs = snapshot.data![1].docs;
          for (var doc in favoriteDocs) {
            final data = doc.data() as Map<String, dynamic>?;
            final String? storyId = data?['storyId'] ?? doc.id;
            if (storyId != null) {
              favoriteStoryIds.add(storyId);
            }
          }
        }

        return Scaffold(
          appBar: AppBar(
            elevation: 0,
            title: Text(
              'Bibliothèque',
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
            centerTitle: false,
          ),
          body: Column(
            children: [
              _buildFilterBar(context),
              Expanded(
                child: ListView.builder(
                  itemCount: widget.categories.length,
                  padding: const EdgeInsets.only(top: 10, bottom: 30),
                  itemBuilder: (context, index) {
                    final category = widget.categories[index];

                    // Filtrage des histoires associées à cette catégorie
                    List<StoryModel> categoryStories = widget.stories
                        .where((story) => story.categoryIds.contains(category.id))
                        .toList();

                    // Application des filtres utilisateur
                    if (_selectedFilter == 'favoris') {
                      categoryStories = categoryStories
                          .where((story) => favoriteStoryIds.contains(story.id))
                          .toList();
                    } else if (_selectedFilter == 'en_cours') {
                      categoryStories = categoryStories.where((story) {
                        final p = activeProfileReadProgress[story.id] ?? 0.0;
                        return p > 0.0 && p < 1.0;
                      }).toList();
                    } else if (_selectedFilter == 'non_lu') {
                      categoryStories = categoryStories
                          .where((story) =>
                              !activeProfileReadProgress.containsKey(story.id) ||
                              activeProfileReadProgress[story.id] == 0.0)
                          .toList();
                    }

                    if (categoryStories.isEmpty) return const SizedBox.shrink();

                    return _buildShelf(
                      context,
                      category,
                      categoryStories,
                      activeProfileReadProgress,
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterBar(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final filters = [
      {'id': 'tous', 'label': 'Tous'},
      {'id': 'favoris', 'label': 'Favoris'},
      {'id': 'en_cours', 'label': 'En cours'},
      {'id': 'non_lu', 'label': 'Non lu'},
    ];

    return Container(
      height: 40,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = _selectedFilter == filter['id'];

          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: ChoiceChip(
              label: Text(
                filter['label']!,
                style: TextStyle(
                  color: isSelected
                      ? colorScheme.onPrimary
                      : colorScheme.onSurfaceVariant,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              selected: isSelected,
              selectedColor: colorScheme.primary,
              backgroundColor: colorScheme.surfaceContainerHigh,
              showCheckmark: false,
              side: BorderSide(
                color: isSelected ? colorScheme.primary : Colors.transparent,
                width: isSelected ? 1 : 0,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              onSelected: (bool selected) {
                if (selected) {
                  setState(() {
                    _selectedFilter = filter['id']!;
                  });
                }
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildShelf(
    BuildContext context,
    CategoryModel category,
    List<StoryModel> categoryStories,
    Map<String, double> activeProfileReadProgress,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    // Définition des couleurs de l'étagère adaptables au mode Clair/Sombre
    final nicheTopColor = isDark
        ? Colors.black.withOpacity(0.85)
        : colorScheme.surfaceContainerLowest;
    final nicheBottomColor = isDark
        ? colorScheme.surfaceContainerHigh
        : colorScheme.surfaceContainer;

    final shelfColorTop = isDark
        ? Color.alphaBlend(colorScheme.primary.withOpacity(0.15), colorScheme.surfaceContainerHighest)
        : Color.alphaBlend(colorScheme.primary.withOpacity(0.08), colorScheme.surfaceContainerHigh);

    final shelfColorBottom = isDark
        ? Color.alphaBlend(colorScheme.primary.withOpacity(0.05), colorScheme.surfaceContainer)
        : Color.alphaBlend(colorScheme.primary.withOpacity(0.12), colorScheme.surfaceContainerHighest);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 15),
        Stack(
          alignment: Alignment.bottomCenter,
          children: [
            // Fond de renfoncement (la niche de l'étagère)
            Container(
              height: 210,
              margin: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    nicheTopColor,
                    nicheBottomColor,
                  ],
                  stops: const [0.0, 0.35],
                ),
                borderRadius: BorderRadius.circular(4),
              ),
            ),

            // Rangée de livres
            Container(
              height: 225,
              padding: const EdgeInsets.only(bottom: 24),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: categoryStories.length,
                padding: const EdgeInsets.symmetric(horizontal: 28),
                itemBuilder: (context, index) {
                  final story = categoryStories[index];
                  return _buildBook(context, story, activeProfileReadProgress);
                },
              ),
            ),

            // La planche en bois / Socle de l'étagère
            Container(
              height: 32,
              margin: const EdgeInsets.symmetric(horizontal: 6),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [shelfColorTop, shelfColorBottom],
                ),
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(4),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.6 : 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  // Étiquette de catégorie sur le rebord de l'étagère
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      borderRadius: BorderRadius.circular(3),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 2,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Text(
                      category.name.toUpperCase(),
                      style: TextStyle(
                        color: colorScheme.onPrimary,
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 25),
      ],
    );
  }

  Widget _buildBook(
    BuildContext context,
    StoryModel story,
    Map<String, double> activeProfileReadProgress,
  ) {
    final double progress = activeProfileReadProgress[story.id] ?? 0.0;
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () => context.push('/story', extra: story),
      child: Container(
        width: 115,
        margin: const EdgeInsets.only(right: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 8,
              offset: const Offset(4, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Image de couverture du livre
              B2Image(objectKey: story.image, fit: BoxFit.cover),

              // Effet d'ombrage de la reliure du livre (à gauche)
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                width: 10,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        Colors.black.withOpacity(0.5),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),

              // Barre de progression sur la tranche droite du livre
              if (progress > 0.0)
                Positioned(
                  right: 0,
                  top: 0,
                  bottom: 0,
                  width: 6,
                  child: Container(
                    color: Colors.black.withOpacity(0.2),
                    alignment: Alignment.bottomCenter,
                    child: FractionallySizedBox(
                      heightFactor: progress,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              colorScheme.primary,
                              colorScheme.tertiary,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(2),
                          boxShadow: [
                            BoxShadow(
                              color: colorScheme.primary.withOpacity(0.5),
                              blurRadius: 4,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

              // Ombrage sombre au bas de l'image pour la lisibilité du titre
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black87,
                      Colors.black38,
                      Colors.transparent,
                    ],
                    stops: [0.0, 0.7, 1.0],
                  ),
                ),
              ),

              // Titre du livre (sur l'image)
              Align(
                alignment: Alignment.bottomLeft,
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 10.0,
                    right: 15.0,
                    bottom: 10.0,
                  ),
                  child: Text(
                    story.name,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white, // Toujours blanc sur le dégradé noir
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}