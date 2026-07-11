import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lumiconte/models/category_model.dart';
import 'package:lumiconte/models/story_model.dart';
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

  // Fonction pour combiner les streams sans dépendance externe 'async'
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
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final profileRef = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('profiles')
        .doc(widget.profileId);

    return StreamBuilder<List<QuerySnapshot>>(
      stream: _combineStreams(profileRef),
      builder: (context, snapshot) {
        Map<String, double> activeProfileReadProgress = {};
        List<String> favoriteStoryIds = [];

        if (snapshot.hasData && snapshot.data!.length == 2) {
          final progressDocs = snapshot.data![0].docs;
          for (var doc in progressDocs) {
            final data = doc.data() as Map<String, dynamic>;
            final String? storyId = data['storyId'];
            final num? progressNum = data['progress'];
            if (storyId != null && progressNum != null) {
              activeProfileReadProgress[storyId] = progressNum.toDouble() / 100.0;
            }
          }

          final favoriteDocs = snapshot.data![1].docs;
          for (var doc in favoriteDocs) {
            final data = doc.data() as Map<String, dynamic>;
            final String? storyId = data['storyId'] ?? doc.id;
            if (storyId != null) {
              favoriteStoryIds.add(storyId);
            }
          }
        }

        return Scaffold(
          backgroundColor: const Color(0xFF140E17),
          appBar: AppBar(
            backgroundColor: const Color(0xFF140E17),
            elevation: 0,
            title: const Text(
              'Bibliothèque',
              style: TextStyle(
                color: Color(0xFFD1C4E9),
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
            centerTitle: false,
          ),
          body: Column(
            children: [
              _buildFilterBar(),
              Expanded(
                child: ListView.builder(
                  itemCount: widget.categories.length,
                  padding: const EdgeInsets.only(top: 10, bottom: 30),
                  itemBuilder: (context, index) {
                    final category = widget.categories[index];
                    
                    List<StoryModel> categoryStories = widget.stories
                        .where((story) => story.categoryIds.contains(category.id))
                        .toList();

                    if (_selectedFilter == 'favoris') {
                      categoryStories = categoryStories
                          .where((story) => favoriteStoryIds.contains(story.id))
                          .toList();
                    } else if (_selectedFilter == 'en_cours') {
                      categoryStories = categoryStories
                          .where((story) {
                            final p = activeProfileReadProgress[story.id] ?? 0.0;
                            return p > 0.0 && p < 1.0;
                          })
                          .toList();
                    } else if (_selectedFilter == 'non_lu') {
                      categoryStories = categoryStories
                          .where((story) => !activeProfileReadProgress.containsKey(story.id) || activeProfileReadProgress[story.id] == 0.0)
                          .toList();
                    }

                    if (categoryStories.isEmpty) return const SizedBox.shrink();

                    return _buildShelf(context, category, categoryStories, activeProfileReadProgress);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterBar() {
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
                  color: isSelected ? Colors.white : const Color(0xFFD1C4E9).withOpacity(0.6),
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              selected: isSelected,
              selectedColor: const Color(0xFF4A3780),
              backgroundColor: const Color(0xFF261C2C),
              showCheckmark: false,
              // 🛠️ Remplacement ici : on utilise 'side' à la place de 'border'
              side: BorderSide(
                color: isSelected ? const Color(0xFF6A4FB3) : Colors.transparent,
                width: isSelected ? 1 : 0,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20), // Donne une belle forme ovale/arrondie aux filtres
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 15),
        Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Container(
              height: 210,
              margin: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.85),
                    const Color(0xFF261C2C),
                  ],
                  stops: const [0.0, 0.30],
                ),
                borderRadius: BorderRadius.circular(4),
              ),
            ),

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

            Container(
              height: 32,
              margin: const EdgeInsets.symmetric(horizontal: 6),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF3C2A4D), Color(0xFF21152B)],
                ),
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(4)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.7),
                    blurRadius: 10,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4A3780),
                      borderRadius: BorderRadius.circular(3),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.4),
                          blurRadius: 2,
                          offset: const Offset(0, 1),
                        ),
                      ],
                      border: Border.all(color: const Color(0xFF6A4FB3), width: 1),
                    ),
                    child: Text(
                      category.name.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
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

    return GestureDetector(
      onTap: () => context.push('/story', extra: story),
      child: Container(
        width: 115,
        margin: const EdgeInsets.only(right: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.6),
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
              B2Image(objectKey: story.image, fit: BoxFit.cover),
              
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
                      colors: [Colors.black.withOpacity(0.5), Colors.transparent],
                    ),
                  ),
                ),
              ),

              if (progress > 0.0)
                Positioned(
                  right: 0,
                  top: 0,
                  bottom: 0,
                  width: 6,
                  child: Container(
                    color: const Color(0x33000000),
                    alignment: Alignment.bottomCenter,
                    child: FractionallySizedBox(
                      heightFactor: progress.clamp(0.0, 1.0),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Color(0xFF0D47A1),
                              Color(0xFF1976D2),
                              Color(0xFF4FC3F7),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(2),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF4FC3F7).withOpacity(0.5),
                              blurRadius: 4,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [Colors.black87, Colors.black38, Colors.transparent],
                    stops: [0.0, 0.7, 1.0],
                  ),
                ),
              ),
              
              Align(
                alignment: Alignment.bottomLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 10.0, right: 15.0, bottom: 10.0),
                  child: Text(
                    story.name,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFFF5F5F5),
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