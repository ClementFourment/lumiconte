import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lumiconte/models/profile_model.dart';
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
            'Utilisateur non connecté',
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
      appBar: AppBar(
        elevation: 0,
        title: Text(
          'Morales débloquées',
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
          final Map<String, int> readProgress = {};
          final Map<String, DateTime> unlockDates = {};

          if (snapshot.hasData) {
            for (var doc in snapshot.data!.docs) {
              final data = doc.data() as Map<String, dynamic>?;
              if (data == null) continue;

              final String storyId = data['storyId'] as String? ?? doc.id;
              final num rawProgress = data['progress'] ?? 0;
              readProgress[storyId] = rawProgress.toInt();

              if (data['updatedAt'] is Timestamp) {
                unlockDates[storyId] = (data['updatedAt'] as Timestamp).toDate();
              } else if (data['createdAt'] is Timestamp) {
                unlockDates[storyId] = (data['createdAt'] as Timestamp).toDate();
              }
            }
          }

          final sortedStories = List<StoryModel>.from(stories)..sort((a, b) {
            final progressA = readProgress[a.id] ?? 0;
            final progressB = readProgress[b.id] ?? 0;
            final isUnlockedA = progressA >= 100;
            final isUnlockedB = progressB >= 100;

            if (isUnlockedA && !isUnlockedB) return -1;
            if (!isUnlockedA && isUnlockedB) return 1;

            if (isUnlockedA && isUnlockedB) {
              final dateA = unlockDates[a.id] ?? DateTime.fromMillisecondsSinceEpoch(0);
              final dateB = unlockDates[b.id] ?? DateTime.fromMillisecondsSinceEpoch(0);
              return dateB.compareTo(dateA);
            }

            return 0;
          });

          final unlockedCount = sortedStories.where((story) {
            final progress = readProgress[story.id] ?? 0;
            return progress >= 100;
          }).length;

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
                              "Sagesse accumulée",
                              style: textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "$unlockedCount / ${stories.length} morales débloquées",
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
                    final int progress = readProgress[story.id] ?? 0;
                    final bool isUnlocked = progress >= 100;

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

  // Extraction du préfixe "Le conseil de... :"
  String _getConseilHeader(String text) {
    final colonIndex = text.indexOf(':');
    if (colonIndex != -1) {
      return text.substring(0, colonIndex + 1).trim();
    }
    return text;
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
            story.name,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            child: Text(
              story.morals.isNotEmpty 
                  ? story.morals 
                  : "Pas de morale enregistrée pour ce conte.",
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface,
                height: 1.4,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Fermer'),
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
        ? (story.morals.isNotEmpty
            ? _getConseilHeader(story.morals)
            : "Pas de morale enregistrée.")
        : "Terminez cette histoire pour en débloquer la morale.";

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
                        story.name,
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
                      if (isUnlocked) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              "Toucher pour lire la suite",
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 2),
                            Icon(
                              Icons.touch_app,
                              size: 12,
                              color: colorScheme.primary,
                            ),
                          ],
                        ),
                      ],
                    ],
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