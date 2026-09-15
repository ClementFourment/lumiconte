import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lumiconte/pages/story/story_text.dart';
import 'package:lumiconte/pages/story/story_view_params.dart';
import 'package:lumiconte/pages/story/story_widgets.dart';

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

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor =
        isDark ? const Color(0xFF161224) : const Color(0xFFF3F4F6);
    final Color cardColor = isDark ? const Color(0xFF26203B) : Colors.white;
    final Color textColor = isDark ? Colors.white : const Color(0xFF1F2937);
    final Color subtleTextColor = isDark ? Colors.white38 : Colors.black38;
    final Color iconBtnBg = isDark
        ? Colors.white.withOpacity(0.08)
        : Colors.black.withOpacity(0.05);
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
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              children: [
                // 1. App Bar
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
                        if (params.isInQueue != null) ...[
                          StoryCircleIconButton(
                            icon: params.isInQueue!
                                ? Icons.playlist_add_check_rounded
                                : Icons.playlist_add_rounded,
                            onPressed: params.onToggleQueue,
                            backgroundColor: iconBtnBg,
                            iconColor:
                                params.isInQueue! ? accentColor : textColor,
                          ),
                          const SizedBox(width: 6),
                        ],
                        StoryCircleIconButton(
                          icon: Icons.restart_alt,
                          onPressed: params.isAtStart ? null : params.onRestart,
                          backgroundColor: iconBtnBg,
                          iconColor: params.isAtStart
                              ? textColor.withOpacity(0.3)
                              : textColor,
                        ),
                        const SizedBox(width: 6),
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
                        const SizedBox(width: 6),
                        StoryCircleIconButton(
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
                      child: Column(
                        children: [
                          // Image
                          Expanded(
                            flex: 5,
                            child: StoryImage(
                                imageKey: params.image,
                                fallbackKey: params.cover),
                          ),
                          // Texte
                          Expanded(
                            flex: 5,
                            child: Column(
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        28, 16, 28, 12),
                                    child: StoryTextArea(
                                      params: params,
                                      metrics: StoryTextMetrics(
                                        fontSize: params.fontSize,
                                        textAlign: TextAlign.center,
                                        dyslexia: params.isDyslexia,
                                      ),
                                      colors: StoryTextColors(
                                        text: textColor,
                                        activeText: isDark
                                            ? const Color(0xFFFDE68A)
                                            : const Color(0xFF92400E),
                                        highlight: isDark
                                            ? const Color(0x40D97706)
                                            : const Color(0x80FDE68A),
                                      ),
                                    ),
                                  ),
                                ),
                                // Navigation + compteur de pages
                                Padding(
                                  padding:
                                      const EdgeInsets.only(bottom: 10, top: 4),
                                  child: StoryPageNavigation(
                                    params: params,
                                    iconColor: textColor,
                                    backgroundColor: iconBtnBg,
                                    size: 40,
                                    counterStyle: TextStyle(
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
                        ],
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
                              inactiveTrackColor: isDark
                                  ? Colors.white.withOpacity(0.15)
                                  : Colors.black.withOpacity(0.1),
                              thumbColor: accentColor,
                              overlayColor: accentColor.withOpacity(0.2),
                            ),
                            child: Slider(
                              min: 0,
                              max: params.audioDuration.inSeconds.toDouble() > 0
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
                        if (params.onSkipToPrevious != null) ...[
                          const SizedBox(width: 6),
                          StoryCircleIconButton(
                            icon: Icons.skip_previous_rounded,
                            onPressed: params.onSkipToPrevious,
                            backgroundColor: iconBtnBg,
                            iconColor: textColor,
                          ),
                        ],
                        if (params.onSkipToNext != null) ...[
                          const SizedBox(width: 6),
                          StoryCircleIconButton(
                            icon: Icons.skip_next_rounded,
                            onPressed: params.onSkipToNext,
                            backgroundColor: iconBtnBg,
                            iconColor: textColor,
                          ),
                        ],
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
