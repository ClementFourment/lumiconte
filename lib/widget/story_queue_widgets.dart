import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:audio_service/audio_service.dart' show PlaybackState;
import 'package:go_router/go_router.dart';
import 'package:lumiconte/models/profile_model.dart';
import 'package:lumiconte/models/story_model.dart';
import 'package:lumiconte/services/audio_background_service.dart';
import 'package:lumiconte/services/story_queue.dart';
import 'package:lumiconte/services/story_queue_player.dart';
import 'package:lumiconte/theme/app_theme.dart';
import 'package:lumiconte/widget/b2_image.dart';

/// Pastille posée sur une couverture : ajoute l'histoire à la file de lecture,
/// ou l'en retire. Dans la file, elle affiche la place de l'histoire.
/// Rien n'est affiché pour une histoire sans audio.
class QueueToggleButton extends StatelessWidget {
  final StoryModel story;
  final double size;

  const QueueToggleButton({super.key, required this.story, this.size = 34});

  @override
  Widget build(BuildContext context) {
    final queue = StoryQueue();

    return ListenableBuilder(
      listenable: queue,
      builder: (context, _) {
        // Suit la langue : la pastille disparaît si l'histoire n'y a pas de voix
        if (!queue.canQueue(story)) return const SizedBox.shrink();
        final index = queue.indexOf(story.id);
        final inQueue = index >= 0;
        final disabled = !inQueue && queue.isFull;

        return Semantics(
          button: true,
          label: inQueue
              ? 'Retirer de la file de lecture'
              : 'Ajouter à la file de lecture',
          excludeSemantics: true,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              if (inQueue) {
                queue.remove(story.id);
              } else if (disabled) {
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(const SnackBar(
                    content: Text(
                        'La file est pleine : ${StoryQueue.maxLength} histoires maximum'),
                  ));
              } else {
                queue.add(story);
              }
            },
            // Zone de toucher plus grande que la pastille
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: size,
                height: size,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: inQueue
                      ? AppTheme.accentColor
                      : Colors.black.withValues(alpha: disabled ? 0.25 : 0.55),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: inQueue ? 0 : 0.6),
                  ),
                ),
                child: inQueue
                    ? Text(
                        '${index + 1}',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w900,
                          fontSize: size * 0.48,
                        ),
                      )
                    : Icon(
                        Icons.playlist_add_rounded,
                        size: size * 0.6,
                        color:
                            Colors.white.withValues(alpha: disabled ? 0.4 : 1),
                      ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Barre de la file de lecture : les couvertures dans l'ordre d'écoute (un
/// appui en retire une) et le bouton pour tout écouter. Masquée si la file est vide.
class StoryQueueBar extends StatelessWidget {
  final ProfileModel profile;

  const StoryQueueBar({super.key, required this.profile});

  void _listen(BuildContext context) {
    final player = StoryQueuePlayer();
    // start() lance la file tout de suite, l'audio suit
    player.start(profile);
    _openCurrentStory(context);
  }

  void _openCurrentStory(BuildContext context) {
    final story = StoryQueue().current;
    if (story == null) return;
    context.push('/story', extra: {
      'story': story,
      'profile': profile,
    });
  }

  @override
  Widget build(BuildContext context) {
    final queue = StoryQueue();
    final player = StoryQueuePlayer();

    return ListenableBuilder(
      listenable: Listenable.merge([queue, player]),
      builder: (context, _) {
        final stories = queue.stories;
        if (stories.isEmpty) return const SizedBox.shrink();
        if (player.isActive) {
          return _NowPlayingBar(
            queue: queue,
            player: player,
            onOpen: () => _openCurrentStory(context),
          );
        }

        final isDark = Theme.of(context).brightness == Brightness.dark;
        final onSurface = Theme.of(context).colorScheme.onSurface;
        final barColor = (isDark ? AppTheme.darkCard : Colors.white)
            .withValues(alpha: isDark ? 0.9 : 0.94);

        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
              child: Container(
                height: 68,
                padding: const EdgeInsets.fromLTRB(8, 6, 6, 6),
                decoration: BoxDecoration(
                  color: barColor,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: AppTheme.accentColor.withValues(alpha: 0.35),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: stories.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 6),
                        itemBuilder: (context, index) => _QueuedCover(
                          story: stories[index],
                          position: index + 1,
                          onRemove: () => queue.remove(stories[index].id),
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Vider la file',
                      icon: const Icon(Icons.close_rounded),
                      color: onSurface.withValues(alpha: 0.6),
                      onPressed: queue.clear,
                    ),
                    FilledButton.icon(
                      onPressed: () => _listen(context),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppTheme.accentColor,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        minimumSize: const Size(0, 48),
                        shape: const StadiumBorder(),
                      ),
                      icon: const Icon(Icons.play_arrow_rounded, size: 26),
                      label: const Text(
                        'Écouter',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Barre affichée pendant l'écoute de la file, page d'histoire fermée :
/// histoire en cours, lecture / pause, suivante et arrêt. Un appui rouvre la page.
class _NowPlayingBar extends StatelessWidget {
  final StoryQueue queue;
  final StoryQueuePlayer player;
  final VoidCallback onOpen;

  const _NowPlayingBar({
    required this.queue,
    required this.player,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    final story = player.currentStory;
    if (story == null) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final barColor = (isDark ? AppTheme.darkCard : Colors.white)
        .withValues(alpha: isDark ? 0.9 : 0.94);
    final audio = AudioBackgroundService();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Material(
            color: barColor,
            child: InkWell(
              onTap: onOpen,
              child: Container(
                height: 68,
                padding: const EdgeInsets.fromLTRB(8, 6, 6, 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: AppTheme.accentColor.withValues(alpha: 0.35),
                  ),
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 44,
                      height: 56,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child:
                            B2Image(objectKey: story.image, fit: BoxFit.cover),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            story.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: onSurface,
                            ),
                          ),
                          Text(
                            'Histoire ${(queue.currentIndex ?? 0) + 1} sur ${queue.stories.length}',
                            style: TextStyle(
                              fontSize: 12,
                              color: onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (player.hasPrevious)
                      IconButton(
                        tooltip: 'Histoire précédente',
                        icon: const Icon(Icons.skip_previous_rounded),
                        color: onSurface,
                        onPressed: player.skipToPrevious,
                      ),
                    StreamBuilder<PlaybackState>(
                      stream: audio.playbackState,
                      builder: (context, snapshot) {
                        final playing = snapshot.data?.playing ?? false;
                        return IconButton(
                          tooltip: playing ? 'Pause' : 'Lecture',
                          iconSize: 32,
                          color: AppTheme.accentColor,
                          icon: Icon(playing
                              ? Icons.pause_circle_filled_rounded
                              : Icons.play_circle_filled_rounded),
                          onPressed: playing ? audio.pause : audio.play,
                        );
                      },
                    ),
                    if (player.hasNext)
                      IconButton(
                        tooltip: 'Histoire suivante',
                        icon: const Icon(Icons.skip_next_rounded),
                        color: onSurface,
                        onPressed: player.skipToNext,
                      ),
                    IconButton(
                      tooltip: 'Arrêter la file',
                      icon: const Icon(Icons.close_rounded),
                      color: onSurface.withValues(alpha: 0.6),
                      onPressed: player.stop,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _QueuedCover extends StatelessWidget {
  final StoryModel story;
  final int position;
  final VoidCallback onRemove;

  const _QueuedCover({
    required this.story,
    required this.position,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Retirer ${story.name} de la file',
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onRemove,
        child: SizedBox(
          width: 44,
          child: Stack(
            fit: StackFit.expand,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: B2Image(objectKey: story.image, fit: BoxFit.cover),
              ),
              Positioned(
                left: 2,
                top: 2,
                child: CircleAvatar(
                  radius: 9,
                  backgroundColor: AppTheme.accentColor,
                  child: Text(
                    '$position',
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
              const Positioned(
                right: 2,
                bottom: 2,
                child: CircleAvatar(
                  radius: 8,
                  backgroundColor: Colors.black54,
                  child:
                      Icon(Icons.close_rounded, size: 11, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
