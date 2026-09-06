import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lumiconte/models/audio_sync_model.dart';
import 'package:lumiconte/pages/story/story_view_params.dart';
import 'package:lumiconte/widget/b2_image.dart';

class StoryClassicView extends StatelessWidget {
  final StoryViewParams params;
  final bool isDark;
  final String profileId;

  const StoryClassicView({
    super.key,
    required this.params,
    required this.isDark,
    required this.profileId,
  });

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor =
        isDark ? const Color(0xFF161224) : const Color(0xFFF3F4F6);
    final Color cardColor =
        isDark ? const Color(0xFF26203B) : Colors.white;
    final Color textColor =
        isDark ? Colors.white : const Color(0xFF1F2937);
    final Color subtleTextColor =
        isDark ? Colors.white38 : Colors.black38;
    final Color iconBtnBg = isDark
        ? Colors.white.withOpacity(0.08)
        : Colors.black.withOpacity(0.05);
    const Color accentColor = Color(0xFFF59E0B);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            children: [
              // 1. App Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _CircleIconButton(
                    icon: Icons.chevron_left,
                    onPressed: params.onBack,
                    backgroundColor: iconBtnBg,
                    iconColor: textColor,
                  ),
                  Row(
                    children: [
                      _CircleIconButton(
                        icon: params.isFavorite
                            ? Icons.favorite
                            : Icons.favorite_border,
                        onPressed: params.onToggleFavorite,
                        backgroundColor: iconBtnBg,
                        iconColor: params.isFavorite
                            ? const Color(0xFFEF4444)
                            : textColor,
                      ),
                      const SizedBox(width: 6),
                      _CircleIconButton(
                        icon: Icons.settings,
                        onPressed: () => context.push('/settings', extra: {
                          'profileId': profileId,
                        }),
                        backgroundColor: iconBtnBg,
                        iconColor: textColor,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 2. Carte Principale
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: isDark
                        ? []
                        : [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(28),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final double junctionTop =
                            (constraints.maxHeight * 0.5) - 20;

                        return Stack(
                          children: [
                            Column(
                              children: [
                                // Image
                                Expanded(
                                  flex: 5,
                                  child: _buildStoryImage(),
                                ),
                                // Texte
                                Expanded(
                                  flex: 5,
                                  child: GestureDetector(
                                    onHorizontalDragEnd: (details) {
                                      if (details.primaryVelocity! > 0) {
                                        params.onPreviousPage();
                                      } else if (details.primaryVelocity! < 0) {
                                        params.onNextPage();
                                      }
                                    },
                                    child: Column(
                                      children: [
                                        Expanded(
                                          child: SingleChildScrollView(
                                            padding: const EdgeInsets.fromLTRB(
                                                28, 16, 28, 12),
                                            child: Center(
                                              child: AnimatedSwitcher(
                                                duration: const Duration(
                                                    milliseconds: 300),
                                                child: KeyedSubtree(
                                                  key: ValueKey(
                                                      params.currentPageIndex),
                                                  child: _buildTextContent(textColor),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        // Page Counter
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              bottom: 12, top: 4),
                                          child: Text(
                                            '${params.currentPageIndex + 1} / ${params.totalPages}',
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              color: subtleTextColor,
                                              letterSpacing: 1.5,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            // Controls Flottants
                            Positioned(
                              top: junctionTop,
                              left: 12,
                              right: 12,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  _CircleIconButton(
                                    icon: Icons.chevron_left,
                                    onPressed: params.currentPageIndex > 0
                                        ? params.onPreviousPage
                                        : null,
                                    backgroundColor: isDark
                                        ? Colors.black.withOpacity(0.5)
                                        : Colors.white.withOpacity(0.9),
                                    iconColor: params.currentPageIndex > 0
                                        ? textColor
                                        : textColor.withOpacity(0.3),
                                    size: 40,
                                  ),
                                  _CircleIconButton(
                                    icon: Icons.chevron_right,
                                    onPressed: params.currentPageIndex <
                                            params.totalPages - 1
                                        ? params.onNextPage
                                        : null,
                                    backgroundColor: isDark
                                        ? Colors.black.withOpacity(0.5)
                                        : Colors.white.withOpacity(0.9),
                                    iconColor: params.currentPageIndex <
                                            params.totalPages - 1
                                        ? textColor
                                        : textColor.withOpacity(0.3),
                                    size: 40,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // 3. Barre Audio
              if (params.isAudio)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    children: [
                      if (params.isLoading)
                        const SizedBox(
                          width: 40,
                          height: 40,
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: accentColor,
                            ),
                          ),
                        )
                      else
                        GestureDetector(
                          onTap: params.onToggleAudio,
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: const BoxDecoration(
                              color: accentColor,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              params.isPlaying
                                  ? Icons.pause_rounded
                                  : Icons.play_arrow_rounded,
                              color: Colors.black,
                              size: 24,
                            ),
                          ),
                        ),
                      const SizedBox(width: 8),
                      Text(
                        _formatDuration(params.audioPosition),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: subtleTextColor,
                        ),
                      ),
                      Expanded(
                        child: SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            trackHeight: 3,
                            thumbShape: const RoundSliderThumbShape(
                                enabledThumbRadius: 6),
                            activeTrackColor: accentColor,
                            inactiveTrackColor: isDark
                                ? Colors.white.withOpacity(0.15)
                                : Colors.black.withOpacity(0.1),
                            thumbColor: accentColor,
                            overlayColor: accentColor.withOpacity(0.2),
                          ),
                          child: Slider(
                            min: 0,
                            max: params.audioDuration.inSeconds
                                        .toDouble() >
                                    0
                                ? params.audioDuration.inSeconds
                                    .toDouble()
                                : 1,
                            value: params.audioPosition.inSeconds
                                .clamp(
                                    0, params.audioDuration.inSeconds)
                                .toDouble(),
                            onChanged: (_) {},
                            onChangeEnd: params.onSeekAudio,
                          ),
                        ),
                      ),
                      Text(
                        _formatDuration(params.audioDuration),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: subtleTextColor,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextContent(Color defaultTextColor) {
    if (params.currentSegments.isNotEmpty) {
      final double currentTimeInSeconds =
          params.audioPosition.inMilliseconds / 1000.0;

      final Color highlightBg = isDark
          ? const Color(0xFFD97706).withOpacity(0.25)
          : const Color(0xFFFDE68A).withOpacity(0.5);

      final Color activeTextColor = isDark
          ? const Color(0xFFFDE68A)
          : const Color(0xFF92400E);

      return Wrap(
        alignment: WrapAlignment.center,
        spacing: 4.0,
        runSpacing: 6.0,
        children: params.currentSegments.expand((segment) {
          return segment.words.map((wordTiming) {
            final bool isActive = currentTimeInSeconds >= wordTiming.start &&
                currentTimeInSeconds <= wordTiming.end;

            return AnimatedContainer(
              duration: const Duration(milliseconds: 120),
              padding:
                  const EdgeInsets.symmetric(horizontal: 3.0, vertical: 1.0),
              decoration: BoxDecoration(
                color: isActive ? highlightBg : Colors.transparent,
                borderRadius: BorderRadius.circular(4.0),
              ),
              child: Text(
                wordTiming.word,
                style: TextStyle(
                  fontSize: params.fontSize,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                  color: isActive ? activeTextColor : defaultTextColor,
                  height: 1.5,
                ),
              ),
            );
          });
        }).toList(),
      );
    }

    return RichText(
      textAlign: TextAlign.center,
      text: params.buildColorizedText(
        text: _getCleanPageText(params.currentPageText),
        baseFontSize: params.fontSize,
        defaultTextColor: defaultTextColor,
        isDyslexiaEnabled: params.isDyslexia,
      ),
    );
  }

  Widget _buildStoryImage() {
    return SizedBox.expand(
      child: B2Image(
        key: ValueKey(params.image),
        objectKey: params.image,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
      ),
    );
  }

  String _getCleanPageText(String rawText) {
    return rawText.replaceAll(RegExp(r'\[img:\d+\]'), '').trim();
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color backgroundColor;
  final Color iconColor;
  final double size;

  const _CircleIconButton({
    required this.icon,
    this.onPressed,
    required this.backgroundColor,
    required this.iconColor,
    this.size = 40,
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