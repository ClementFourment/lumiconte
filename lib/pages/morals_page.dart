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

    // Référence exacte selon ton Firestore : users/{uid}/profiles/{profileId}/readingProgress
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
          // Map pour stocker : storyId -> progress (0 à 100)
          final Map<String, int> readProgress = {};

          if (snapshot.hasData) {
            for (var doc in snapshot.data!.docs) {
              final data = doc.data() as Map<String, dynamic>?;
              if (data == null) continue;

              final String storyId = data['storyId'] as String? ?? doc.id;
              final num rawProgress = data['progress'] ?? 0;
              
              readProgress[storyId] = rawProgress.toInt();
            }
          }

          // Débloqué uniquement si le champ progress est >= 100
          final unlockedCount = stories.where((story) {
            final progress = readProgress[story.id] ?? 0;
            return progress >= 100;
          }).length;

          return Column(
            children: [
              // Bannières récapitulative
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

              // Liste des histoires et morales
              Expanded(
                child: ListView.builder(
                  itemCount: stories.length,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  itemBuilder: (context, index) {
                    final story = stories[index];
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

  Widget _buildMoralCard(
    BuildContext context,
    StoryModel story,
    bool isUnlocked,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
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
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Vignette de couverture de l'histoire
              SizedBox(
                width: 90,
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

              // Contenu : Titre + Champ morals
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        story.name,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isUnlocked
                              ? colorScheme.onSurface
                              : colorScheme.onSurface.withOpacity(0.5),
                        ),
                      ),
                      const SizedBox(height: 6),
                      if (isUnlocked) ...[
                        Text(
                          // Récupération directe du champ `morals` de ton StoryModel
                          story.morals.isNotEmpty 
                              ? story.morals 
                              : "Pas de morale enregistrée pour ce conte.",
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ] else ...[
                        Text(
                          "Terminez cette histoire pour en débloquer la morale.",
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant.withOpacity(0.6),
                          ),
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