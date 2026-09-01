import 'package:flutter/material.dart';
import 'package:lumiconte/constants/avatars.dart';
import 'package:lumiconte/models/category_model.dart';
import 'package:lumiconte/models/reading_progress_model.dart';
import 'package:lumiconte/models/story_model.dart';
import 'package:lumiconte/models/profile_model.dart';
import 'package:lumiconte/navigation/bottom_nav.dart';
import 'package:lumiconte/services/reading_progress_service.dart';
import 'package:lumiconte/widget/b2_image.dart';
import 'package:lumiconte/widget/story_search_bar.dart';
import 'package:lumiconte/pages/story/story_page.dart';
import 'package:go_router/go_router.dart';
import 'package:lumiconte/widget/lantern_progress_bar.dart';
import 'package:lumiconte/main.dart';

class HomePage extends StatefulWidget {
  final ProfileModel profile;
  final List<CategoryModel> categories;
  final List<StoryModel> stories;

  const HomePage({
    super.key,
    required this.profile,
    required this.categories,
    required this.stories,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ReadingProgressService _readingProgressService =
      ReadingProgressService();
  @override
  void initState() {
    super.initState();
    // Demande les permissions une fois l'écran et l'Activity Android affichés
    WidgetsBinding.instance.addPostFrameCallback((_) {
      appSettings.requestNotificationPermissions();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final sectionTitleStyle = textTheme.titleMedium?.copyWith(
      fontWeight: FontWeight.bold,
      fontSize: 18,
      color: colorScheme.onSurface,
    );
    final latestStories = ([...widget.stories]..sort((a, b) {
            final dateA = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
            final dateB = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
            return dateB.compareTo(dateA);
          }))
        .take(10)
        .toList();
    final int profileAge = widget.profile.age;
    final adaptedFromAgeStories = widget.stories.where((story) {
      final int ageMin = story.age_min ?? 0;
      final int ageMax = story.age_max ?? 99;

      return profileAge >= ageMin && profileAge <= ageMax;
    }).toList();

    return StreamBuilder<List<ReadingProgressModel>>(
      stream: _readingProgressService.getUserReadingProgress(widget.profile.id),
      builder: (context, snapshot) {
        final readingProgress = snapshot.data ?? [];

        final continueReading = readingProgress
            .where((p) => p.progress > 0 && p.progress < 100)
            .toList()
          ..sort((a, b) => b.lastRead.compareTo(a.lastRead));
        final continueStories = continueReading.map((progress) {
          final story = widget.stories
              .where(
                (story) => story.id == progress.storyId,
              )
              .firstOrNull;

          return {
            "story": story,
            "progress": progress,
          };
        }).toList();
        return Scaffold(
          body: SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.only(
                  left: 20, right: 20, top: 15, bottom: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          "Bonjour ${widget.profile.name} !",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: () {
                          context
                              .findAncestorStateOfType<BottomNavState>()
                              ?.changeTab(2);
                        },
                        child: CircleAvatar(
                          radius: 22,
                          backgroundColor: colorScheme.surfaceContainerHigh,
                          backgroundImage: AssetImage(
                            widget.profile.avatarPath ??
                                AppAvatars.defaultAvatar,
                          ),
                        ),
                      )
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Barre de Recherche
                  StorySearchBar(
                    onStorySelected: (story) {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          transitionDuration: const Duration(milliseconds: 300),
                          reverseTransitionDuration:
                              const Duration(milliseconds: 250),
                          pageBuilder: (_, __, ___) => StoryPage(
                            story: story,
                            profile: widget.profile,
                          ),
                          transitionsBuilder: (_, animation, __, child) {
                            final curved = CurvedAnimation(
                              parent: animation,
                              curve: Curves.easeOut,
                            );

                            return FadeTransition(
                              opacity: curved,
                              child: SlideTransition(
                                position: Tween<Offset>(
                                  begin: const Offset(0, 0.03),
                                  end: Offset.zero,
                                ).animate(curved),
                                child: child,
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  // Reprendre la lecture Header
                  if (continueStories.isNotEmpty)
                    Text(
                      "Reprendre la lecture",
                      style: sectionTitleStyle,
                    ),

                  const SizedBox(height: 12),

                  // Carte Continue
                  if (continueStories.isNotEmpty) ...[
                    SizedBox(
                      height: 190,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: continueStories.length,
                        itemBuilder: (context, index) {
                          final story =
                              continueStories[index]["story"] as StoryModel;

                          final progress = continueStories[index]["progress"]
                              as ReadingProgressModel;

                          return GestureDetector(
                            onTap: () => context.push('/story', extra: {
                              'story': story,
                              'profile': widget.profile,
                            }),
                            child: _buildContinueCard(
                              context,
                              story,
                              progress,
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  if (adaptedFromAgeStories.isNotEmpty)
                    _carrousel(
                        context, "Adapté à ton âge", adaptedFromAgeStories),
                  _carrousel(context, "Histoires populaires",
                      widget.stories.sublist(0, 10)),
                  _carrousel(context, "Nouveautés", latestStories),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildContinueCard(
    BuildContext context,
    StoryModel story,
    ReadingProgressModel progress,
  ) {
    return Container(
      width: 220,
      margin: const EdgeInsets.only(right: 14),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          B2Image(
            objectKey: story.image,
            fit: BoxFit.cover,
          ),
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.black87,
                  Colors.transparent,
                ],
              ),
            ),
          ),
          Positioned(
            left: 12,
            right: 12,
            bottom: 12,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  story.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                LanternProgressBar(
                  progress: progress.progress / 100,
                ),
                const SizedBox(height: 6),
                Text(
                  "${progress.progress}% terminé",
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildStoryCard(BuildContext context, StoryModel story) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: 115,
      height: 175,
      margin: const EdgeInsets.only(right: 14),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: colorScheme.surfaceContainerHigh,
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          B2Image(objectKey: story.image, fit: BoxFit.cover),
          Container(
            alignment: Alignment.bottomCenter,
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.black87,
                  Colors.black38,
                  Colors.transparent,
                ],
                stops: [0.0, 0.6, 1.0],
              ),
            ),
            child: Text(
              story.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _carrousel(
      BuildContext context, String titleText, List<StoryModel> stories) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final sectionTitleStyle = textTheme.titleMedium?.copyWith(
      fontWeight: FontWeight.bold,
      fontSize: 18,
      color: colorScheme.onSurface,
    );

    return Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              titleText,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: sectionTitleStyle,
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 175,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: stories.length,
                itemBuilder: (context, index) {
                  final story = stories[index];
                  return GestureDetector(
                    onTap: () => context.push('/story', extra: {
                      'story': story,
                      'profile': widget.profile,
                    }),
                    child: _buildStoryCard(context, story),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
          ],
        ));
  }
}
