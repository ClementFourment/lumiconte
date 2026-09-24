import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
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
        if (params.isAudio && params.isListening) {
          final spoken = params.document.spokenWordAt(
            params.audioPosition.inMilliseconds / 1000.0,
          );
          if (spoken != null && spoken >= page.start && spoken < page.end) {
            activeIndex = spoken - page.start;
          }
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

/// Flèches page précédente / suivante de part et d'autre du compteur de pages.
/// Placées sous le texte pour ne jamais le recouvrir.
class StoryPageNavigation extends StatelessWidget {
  final StoryViewParams params;
  final Color iconColor;
  final Color backgroundColor;
  final TextStyle counterStyle;
  final double size;
  final bool hasBorder;

  const StoryPageNavigation({
    super.key,
    required this.params,
    required this.iconColor,
    required this.backgroundColor,
    required this.counterStyle,
    this.size = 44,
    this.hasBorder = false,
  });

  @override
  Widget build(BuildContext context) {
    final bool canGoBack = params.currentPageIndex > 0;
    final bool canGoForward = params.currentPageIndex < params.totalPages - 1;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        StoryCircleIconButton(
          icon: Icons.chevron_left,
          onPressed: canGoBack ? params.onPreviousPage : null,
          backgroundColor: backgroundColor,
          iconColor: canGoBack ? iconColor : iconColor.withOpacity(0.3),
          size: size,
          hasBorder: hasBorder,
        ),
        SizedBox(
          width: 90,
          child: Text(
            '${params.currentPageIndex + 1} / ${params.totalPages}',
            textAlign: TextAlign.center,
            style: counterStyle,
          ),
        ),
        StoryCircleIconButton(
          icon: Icons.chevron_right,
          onPressed: canGoForward ? params.onNextPage : null,
          backgroundColor: backgroundColor,
          iconColor: canGoForward ? iconColor : iconColor.withOpacity(0.3),
          size: size,
          hasBorder: hasBorder,
        ),
      ],
    );
  }
}

/// Illustration de la page. Quand la clé change, la nouvelle image n'est
/// affichée qu'une fois chargée : si elle n'existe pas, on garde la précédente.
/// S'il n'y a pas d'image précédente, on affiche [fallbackKey] (la couverture).
class StoryImage extends StatefulWidget {
  final String? imageKey;
  final String? fallbackKey;

  const StoryImage({super.key, this.imageKey, this.fallbackKey});

  @override
  State<StoryImage> createState() => _StoryImageState();
}

class _StoryImageState extends State<StoryImage> {
  String? _shownKey;
  ImageStream? _stream;
  ImageStreamListener? _listener;

  @override
  void initState() {
    super.initState();
    _shownKey = widget.imageKey;
  }

  @override
  void didUpdateWidget(StoryImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.imageKey != oldWidget.imageKey) _load(widget.imageKey);
  }

  void _load(String? key) {
    _stopListening();
    if (key == null || key.isEmpty || key == _shownKey) return;

    final stream = CachedNetworkImageProvider(B2Image.urlFor(key))
        .resolve(createLocalImageConfiguration(context));
    final listener = ImageStreamListener(
      (_, __) {
        _stopListening();
        if (mounted) setState(() => _shownKey = key);
      },
      onError: (_, __) => _stopListening(),
    );
    _stream = stream;
    _listener = listener;
    stream.addListener(listener);
  }

  void _stopListening() {
    final listener = _listener;
    if (listener != null) _stream?.removeListener(listener);
    _stream = null;
    _listener = null;
  }

  @override
  void dispose() {
    _stopListening();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: B2Image(
        objectKey: _shownKey,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
        fadeInDuration: const Duration(milliseconds: 200),
        fadeOutDuration: Duration.zero,
        useOldImageOnUrlChange: true,
        errorWidget: _shownKey == widget.fallbackKey
            ? null
            : B2Image(
                objectKey: widget.fallbackKey,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
                fadeInDuration: const Duration(milliseconds: 200),
                fadeOutDuration: Duration.zero,
              ),
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
      duration: const Duration(milliseconds: 50),
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
