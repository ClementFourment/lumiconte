import 'package:flutter/material.dart';
import 'package:lumiconte/widget/b2_image.dart';
import 'package:lumiconte/pages/story/story_view_params.dart';

class StoryUtils {
  /// Formate une durée en mm:ss
  static String formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  /// Retire les tags d'images [img:X] du texte
  static String getCleanPageText(String rawText) {
    return rawText.replaceAll(RegExp(r'\[img:\d+\]'), '').trim();
  }
}

class StoryCircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color backgroundColor;
  final Color iconColor;
  final double size;
  final bool hasBorder;

  const StoryCircleIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    required this.backgroundColor,
    required this.iconColor,
    this.size = 40,
    this.hasBorder = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: backgroundColor,
            shape: BoxShape.circle,
            border: hasBorder
                ? Border.all(
                    color: iconColor.withOpacity(0.2),
                    width: 1,
                  )
                : null,
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: size * 0.55,
          ),
        ),
      ),
    );
  }
}

class StoryImage extends StatelessWidget {
  final String? imageKey;

  const StoryImage({super.key, this.imageKey});

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: B2Image(
        key: ValueKey(imageKey),
        objectKey: imageKey,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
      ),
    );
  }
}
