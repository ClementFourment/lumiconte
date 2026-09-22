import 'package:lumiconte/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lumiconte/models/profile_model.dart';
import 'package:lumiconte/models/reading_progress_model.dart';
import 'package:lumiconte/models/story_model.dart';
import 'package:lumiconte/widget/b2_image.dart';

class MoralsPage extends StatelessWidget {
  final ProfileModel profile;
  final List<StoryModel> stories;

  const MoralsPage({
    super.key,
    required this.profile,
    required this.stories,
  });

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
            AppLocalizations.of(context).userNotConnected,
            style: textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      );
    }

    final readingProgressRef = FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .collection('profiles')
        .doc(profile.id)
        .collection('readingProgress');

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        elevation: 0,
        title: Text(
          AppLocalizations.of(context).myMorals,
          style: textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        centerTitle: false,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: readingProgressRef.snapshots(),
        builder: (context, snapshot) {
          final Set<String> unlockedStoryIds = {};
          final Map<String, DateTime> unlockDates = {};

          if (snapshot.hasData) {
            for (var doc in snapshot.data!.docs) {
              final data = doc.data() as Map<String, dynamic>?;
              if (data == null) continue;

              final String storyId = data['storyId'] as String? ?? doc.id;
              if (ReadingProgressModel.moraleUnlockedFrom(data)) {
                unlockedStoryIds.add(storyId);
              }

              if (data['updatedAt'] is Timestamp) {
                unlockDates[storyId] = (data['updatedAt'] as Timestamp).toDate();
              } else if (data['createdAt'] is Timestamp) {
                unlockDates[storyId] = (data['createdAt'] as Timestamp).toDate();
              }
            }
          }

          final sortedStories = List<StoryModel>.from(stories)..sort((a, b) {
            final isUnlockedA = unlockedStoryIds.contains(a.id);
            final isUnlockedB = unlockedStoryIds.contains(b.id);

            if (isUnlockedA && !isUnlockedB) return -1;
            if (!isUnlockedA && isUnlockedB) return 1;

            if (isUnlockedA && isUnlockedB) {
              final dateA = unlockDates[a.id] ?? DateTime.fromMillisecondsSinceEpoch(0);
              final dateB = unlockDates[b.id] ?? DateTime.fromMillisecondsSinceEpoch(0);
              return dateB.compareTo(dateA);
            }

            return 0;
          });

          final unlockedCount = sortedStories
              .where((story) => unlockedStoryIds.contains(story.id))
              .length;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.auto_awesome,
                        color: colorScheme.primary,
                        size: 30,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppLocalizations.of(context).wisdomCollected,
                              style: textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              AppLocalizations.of(context)
                                  .moralsUnlockedCount(
                                      unlockedCount, stories.length),
                              style: textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: sortedStories.length,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  itemBuilder: (context, index) {
                    final story = sortedStories[index];
                    final bool isUnlocked =
                        unlockedStoryIds.contains(story.id);

                    return _buildMoralCard(context, story, isUnlocked);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // Aperçu de la morale : on retire le préfixe "Le conseil de... :" pour
  // afficher directement le conseil (le préfixe seul donnait une carte vide)
  String _getMoralPreview(String text) {
    final colonIndex = text.indexOf(':');
    if (colonIndex != -1 && colonIndex < 60) {
      final advice = text.substring(colonIndex + 1).trim();
      if (advice.isNotEmpty) return advice;
    }
    return text.trim();
  }

  void _showMoralDialog(BuildContext context, StoryModel story) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            story.displayName,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            child: Text(
              story.displayMorals.isNotEmpty
                  ? story.displayMorals
                  : AppLocalizations.of(context).noMoralForStory,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface,
                height: 1.4,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(AppLocalizations.of(context).close),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMoralCard(
    BuildContext context,
    StoryModel story,
    bool isUnlocked,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final String displayText = isUnlocked
        ? (story.displayMorals.isNotEmpty
            ? _getMoralPreview(story.displayMorals)
            : AppLocalizations.of(context).noMoralShort)
        : AppLocalizations.of(context).moralLocked;

    return Container(
      height: 100,
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isUnlocked
            ? colorScheme.surfaceContainerLow
            : colorScheme.surfaceContainerLowest.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isUnlocked
              ? colorScheme.primary.withOpacity(0.3)
              : colorScheme.outlineVariant.withOpacity(0.2),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: isUnlocked ? () => _showMoralDialog(context, story) : null,
          child: Row(
            children: [
              SizedBox(
                width: 90,
                height: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    B2Image(
                      objectKey: story.image,
                      fit: BoxFit.cover,
                    ),
                    if (!isUnlocked)
                      Container(
                        color: Colors.black.withOpacity(0.65),
                        child: const Icon(
                          Icons.lock_rounded,
                          color: Colors.white70,
                          size: 26,
                        ),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        story.displayName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isUnlocked
                              ? colorScheme.onSurface
                              : colorScheme.onSurface.withOpacity(0.5),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        displayText,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: isUnlocked
                            ? theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                                fontStyle: FontStyle.italic,
                              )
                            : theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant.withOpacity(0.6),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
              if (isUnlocked)
                Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: Icon(
                    Icons.chevron_right_rounded,
                    color: colorScheme.primary,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}