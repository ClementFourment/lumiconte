import 'package:lumiconte/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:lumiconte/constants/avatars.dart';
import 'package:lumiconte/models/category_model.dart';
import 'package:lumiconte/models/reading_progress_model.dart';
import 'package:lumiconte/models/story_model.dart';
import 'package:lumiconte/models/profile_model.dart';
import 'package:lumiconte/navigation/bottom_nav.dart';
import 'package:lumiconte/services/reading_progress_service.dart';
import 'package:lumiconte/services/story_queue_player.dart';
import 'package:lumiconte/widget/b2_image.dart';
import 'package:lumiconte/pages/story_search_page.dart';
import 'package:go_router/go_router.dart';
import 'package:lumiconte/widget/lantern_progress_bar.dart';
import 'package:lumiconte/widget/mascot.dart';
import 'package:lumiconte/widget/story_cover_card.dart';
import 'package:lumiconte/widget/story_queue_widgets.dart';

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
    // Pas de demande d'autorisation de notifications ici : l'enfant voit cet
    // écran. Elle est faite côté parent (création de profil, espace parents).
    _readingProgressService
        .addMissingMoraleUnlocked(widget.profile.id)
        .catchError((e) => debugPrint('Erreur ajout moraleUnlocked : $e'));
    StoryQueuePlayer().followLanguage(widget.profile);
  }

  /// Petite phrase de la mascotte, adaptée au moment de la journée.
  String _greetingSubtitle(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final hour = DateTime.now().hour;
    if (hour >= 18 || hour < 5) return l10n.greetingEvening;
    return l10n.greetingDay;
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
          backgroundColor: Colors.transparent,
          body: SafeArea(
            // Le bas est géré à la main : le contenu défile sous la barre
            // flottante mais peut toujours remonter au-dessus
            bottom: false,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.only(
                top: 15,
                bottom: MediaQuery.paddingOf(context).bottom + 24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Mascot(size: 64),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppLocalizations.of(context).greetingHello(widget.profile.name),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: textTheme.headlineSmall?.copyWith(
                                  fontSize: 26,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _greetingSubtitle(context),
                                style: textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onSurface
                                      .withValues(alpha: 0.7),
                                ),
                              ),
                            ],
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
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Bouton de recherche : ouvre l'écran de recherche
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: StorySearchButton(
                      onTap: () => openStorySearch(
                        context,
                        profile: widget.profile,
                        stories: widget.stories,
                        categories: widget.categories,
                        readingProgress: readingProgress,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Reprendre la lecture Header
                  if (continueStories.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        AppLocalizations.of(context).continueReading,
                        style: sectionTitleStyle,
                      ),
                    ),

                  const SizedBox(height: 12),

                  // Carte Continue
                  if (continueStories.isNotEmpty) ...[
                    SizedBox(
                      height: 190,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 20),
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
                    _carrousel(context, AppLocalizations.of(context).forYourAge,
                        adaptedFromAgeStories, readingProgress),
                  // _carrousel(context, "Histoires populaires",
                  //     widget.stories.sublist(0, 10), readingProgress),
                  _carrousel(context, AppLocalizations.of(context).newStories,
                      latestStories, readingProgress),
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
                  story.displayName,
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
                  AppLocalizations.of(context)
                      .percentDone(progress.progress.round()),
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: QueueToggleButton(story: story),
          ),
        ],
      ),
    );
  }

  Widget _carrousel(BuildContext context, String titleText,
      List<StoryModel> stories, List<ReadingProgressModel> readingProgress) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final sectionTitleStyle = textTheme.titleMedium?.copyWith(
      fontWeight: FontWeight.bold,
      fontSize: 18,
      color: colorScheme.onSurface,
    );

    return Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                titleText,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: sectionTitleStyle,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 175,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: stories.length,
                itemBuilder: (context, index) {
                  final story = stories[index];
                  final progress = readingProgress
                      .where((p) => p.storyId == story.id)
                      .firstOrNull;
                  return Padding(
                    padding: const EdgeInsets.only(right: 14),
                    child: SizedBox(
                      width: 115,
                      child: StoryCoverCard(
                        story: story,
                        progress: progress?.progress ?? 0,
                        onTap: () => context.push('/story', extra: {
                          'story': story,
                          'profile': widget.profile,
                        }),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
          ],
        ));
  }
}
