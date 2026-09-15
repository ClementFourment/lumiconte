import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lumiconte/pages/story/story_text.dart';
import 'package:lumiconte/pages/story/story_view_params.dart';
import 'package:lumiconte/pages/story/story_widgets.dart';

// Ombre douce pour garder le texte lisible quand l'illustration est claire
const List<Shadow> _readabilityShadows = [
  Shadow(color: Color(0x73000000), blurRadius: 6, offset: Offset(0, 1)),
  Shadow(color: Color(0x40000000), blurRadius: 2),
];

class StoryImmersiveView extends StatelessWidget {
  final StoryViewParams params;
  final bool isDark;
  final String profileId;

  const StoryImmersiveView({
    super.key,
    required this.params,
    required this.isDark,
    required this.profileId,
  });

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor =
        isDark ? const Color(0xFF161224) : const Color(0xFFF3F4F6);
    final Color textColor = Colors.white;
    final Color subtleTextColor = Colors.white70;
    final Color iconBtnBg = Colors.black.withOpacity(0.3);
    const Color accentColor = Color(0xFFF59E0B);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: GestureDetector(
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity! > 0) {
            params.onPreviousPage();
          } else if (details.primaryVelocity! < 0) {
            params.onNextPage();
          }
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            // 1. Image en plein écran
            Stack(
              fit: StackFit.expand,
              children: [
                StoryImage(imageKey: params.image, fallbackKey: params.cover),
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.2),
                        Colors.black.withOpacity(0.85),
                        Colors.black.withOpacity(0.95),
                      ],
                      stops: const [0.4, 0.6, 0.85, 1.0],
                    ),
                  ),
                ),
              ],
            ),

            // 2. Contenu superposé
            SafeArea(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(children: [
                  // App Bar supérieure
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      StoryCircleIconButton(
                        icon: Icons.chevron_left,
                        onPressed: params.onBack,
                        backgroundColor: iconBtnBg,
                        iconColor: textColor,
                      ),
                      Row(
                        children: [
                          StoryCircleIconButton(
                            icon: Icons.restart_alt,
                            onPressed:
                                params.isAtStart ? null : params.onRestart,
                            backgroundColor: iconBtnBg,
                            iconColor: params.isAtStart
                                ? textColor.withOpacity(0.3)
                                : textColor,
                          ),
                          const SizedBox(width: 8),
                          StoryCircleIconButton(
                            icon: params.isFavorite
                                ? Icons.favorite
                                : Icons.favorite_border,
                            onPressed: params.onToggleFavorite,
                            backgroundColor: iconBtnBg,
                            iconColor: params.isFavorite
                                ? const Color(0xFFEF4444)
                                : textColor,
                          ),
                          const SizedBox(width: 8),
                          StoryCircleIconButton(
                            icon: Icons.settings,
                            onPressed: () => context.push('/settings', extra: {
                              'profileId': profileId,
                            }),
                            backgroundColor: iconBtnBg,
                            iconColor: textColor,
                            size: 34,
                          ),
                        ],
                      ),
                    ],
                  ),

                  const Spacer(),

                  // Texte de l'histoire
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: StoryTextArea(
                        params: params,
                        alignment: Alignment.topLeft,
                        metrics: StoryTextMetrics(
                          fontSize: params.fontSize,
                          dyslexia: params.isDyslexia,
                        ),
                        colors: StoryTextColors(
                          text: textColor,
                          activeText: const Color(0xFFFDE68A),
                          highlight: const Color(0x40F59E0B),
                          shadows: _readabilityShadows,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Compteur de pages
                  Text(
                    '${params.currentPageIndex + 1} / ${params.totalPages}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: subtleTextColor,
                      letterSpacing: 1.5,
                      shadows: _readabilityShadows,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 3. Barre Audio
                  if (params.isAudio)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
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
                            StoryUtils.formatDuration(params.audioPosition),
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
                                inactiveTrackColor:
                                    Colors.white.withOpacity(0.2),
                                thumbColor: accentColor,
                                overlayColor: accentColor.withOpacity(0.2),
                              ),
                              child: Slider(
                                min: 0,
                                max: params.audioDuration.inSeconds.toDouble() >
                                        0
                                    ? params.audioDuration.inSeconds.toDouble()
                                    : 1,
                                value: params.audioPosition.inSeconds
                                    .clamp(0, params.audioDuration.inSeconds)
                                    .toDouble(),
                                onChanged: params.onSeekAudioChanged,
                                onChangeEnd: params.onSeekAudio,
                              ),
                            ),
                          ),
                          Text(
                            StoryUtils.formatDuration(params.audioDuration),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: subtleTextColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                ]),
              ),
            ),

            // Navigation Arrows
            Positioned(
              left: 8,
              top: 0,
              bottom: 0,
              child: Center(
                child: StoryCircleIconButton(
                  icon: Icons.chevron_left,
                  onPressed: params.currentPageIndex > 0
                      ? params.onPreviousPage
                      : null,
                  backgroundColor: Colors.black.withOpacity(0.3),
                  iconColor: params.currentPageIndex > 0
                      ? textColor
                      : textColor.withOpacity(0.3),
                  size: 44,
                ),
              ),
            ),
            Positioned(
              right: 8,
              top: 0,
              bottom: 0,
              child: Center(
                child: StoryCircleIconButton(
                  icon: Icons.chevron_right,
                  onPressed: params.currentPageIndex < params.totalPages - 1
                      ? params.onNextPage
                      : null,
                  backgroundColor: Colors.black.withOpacity(0.3),
                  iconColor: params.currentPageIndex < params.totalPages - 1
                      ? textColor
                      : textColor.withOpacity(0.3),
                  size: 44,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
