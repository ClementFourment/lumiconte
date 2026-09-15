import 'package:flutter/material.dart';
import 'package:lumiconte/models/story_model.dart';
import 'package:lumiconte/widget/b2_image.dart';
import 'package:lumiconte/widget/lantern_progress_bar.dart';
import 'package:lumiconte/widget/story_queue_widgets.dart';

/// Couverture d'histoire avec son titre et, si elle est commencée, sa
/// progression. Prend la taille que lui donne son parent.
class StoryCoverCard extends StatelessWidget {
  final StoryModel story;

  /// Progression de 0 à 100.
  final double progress;
  final VoidCallback onTap;

  const StoryCoverCard({
    super.key,
    required this.story,
    required this.progress,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    story.name,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  if (progress > 0) ...[
                    const SizedBox(height: 8),
                    SizedBox(
                      width: 80,
                      child: LanternProgressBar(progress: progress / 100),
                    ),
                  ],
                ],
              ),
            ),
            Positioned(
              top: 0,
              right: 0,
              child: QueueToggleButton(story: story, size: 30),
            ),
          ],
        ),
      ),
    );
  }
}
