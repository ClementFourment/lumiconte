import 'package:flutter/material.dart';
import 'package:lumiconte/widget/b2_image.dart';
import 'package:lumiconte/pages/story/story_text.dart';
import 'package:lumiconte/pages/story/story_view_params.dart';

class StoryUtils {
  /// Formate une durée en mm:ss
  static String formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}

/// Zone de texte d'une histoire : mesure la place disponible, demande la
/// pagination correspondante et affiche la page courante sans défilement.
class StoryTextArea extends StatelessWidget {
  final StoryViewParams params;
  final StoryTextMetrics metrics;
  final StoryTextColors colors;
  final Alignment alignment;

  const StoryTextArea({
    super.key,
    required this.params,
    required this.metrics,
    required this.colors,
    this.alignment = Alignment.center,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (!constraints.hasBoundedWidth || !constraints.hasBoundedHeight) {
          return const SizedBox.shrink();
        }
        final request = StoryLayoutRequest(
          area: constraints.biggest,
          metrics: metrics,
          textScaler: MediaQuery.textScalerOf(context),
          locale: Localizations.maybeLocaleOf(context),
        );
        if (request.area.isEmpty) return const SizedBox.shrink();

        final pagination = params.paginate(request);
        final pageIndex = pagination.pageOfWord(params.anchorWord);
        final page = pagination.pages[pageIndex];
        final words = params.document.words.sublist(page.start, page.end);

        int? activeIndex;
        if (params.isAudio && params.document.hasTimings) {
          final seconds = params.audioPosition.inMilliseconds / 1000.0;
          final index = words.indexWhere((word) => word.isSpokenAt(seconds));
          if (index >= 0) activeIndex = index;
        }

        return StoryPageTransition(
          pageIndex: pageIndex,
          child: Align(
            alignment: alignment,
            // Filet de sécurité : si une page dépasse malgré la mesure, on la réduit
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: alignment,
              child: StoryPageText(
                words: words,
                request: request,
                colors: colors,
                activeIndex: activeIndex,
              ),
            ),
          ),
        );
      },
    );
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
        objectKey: imageKey,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
        fadeInDuration: const Duration(milliseconds: 200),
        fadeOutDuration: Duration.zero,
        useOldImageOnUrlChange: true,
      ),
    );
  }
}

/// Transition courte entre deux pages : glissement léger dans le sens de lecture
/// et fondu. Les deux pages occupent toute la zone, pour éviter les sauts de position.
class StoryPageTransition extends StatefulWidget {
  final int pageIndex;
  final Widget child;

  const StoryPageTransition({
    super.key,
    required this.pageIndex,
    required this.child,
  });

  @override
  State<StoryPageTransition> createState() => _StoryPageTransitionState();
}

class _StoryPageTransitionState extends State<StoryPageTransition> {
  int _direction = 1;

  @override
  void didUpdateWidget(StoryPageTransition oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.pageIndex != oldWidget.pageIndex) {
      _direction = widget.pageIndex > oldWidget.pageIndex ? 1 : -1;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentKey = ValueKey(widget.pageIndex);

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 220),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      layoutBuilder: (currentChild, previousChildren) => Stack(
        fit: StackFit.expand,
        clipBehavior: Clip.none,
        children: [
          for (final previous in previousChildren)
            Positioned.fill(child: previous),
          if (currentChild != null) currentChild,
        ],
      ),
      transitionBuilder: (child, animation) {
        final isIncoming = child.key == currentKey;
        final shift = 0.06 * _direction * (isIncoming ? 1 : -1);
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: Offset(shift, 0),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      },
      child: KeyedSubtree(key: currentKey, child: widget.child),
    );
  }
}
