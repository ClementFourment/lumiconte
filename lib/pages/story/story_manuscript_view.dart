import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lumiconte/pages/story/story_text.dart';
import 'package:lumiconte/pages/story/story_view_params.dart';
import 'package:lumiconte/pages/story/story_widgets.dart';

class StoryManuscriptView extends StatelessWidget {
  final StoryViewParams params;
  final String profileId;

  const StoryManuscriptView({
    super.key,
    required this.params,
    required this.profileId,
  });

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor = const Color(0xFFEEEADE);
    final Color pageColor = const Color(0xFFFAF6EB);
    final Color textColor = const Color(0xFF2E2418);
    final Color subtleTextColor = const Color(0xFF6B5D52);
    final Color borderColor = const Color(0xFFB8A680);
    final Color iconBtnBg = const Color(0xFFE8DDD0);

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
            SafeArea(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Column(
                  children: [
                    // 1. Barre supérieure
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          StoryCircleIconButton(
                            icon: Icons.chevron_left,
                            onPressed: params.onBack,
                            backgroundColor: iconBtnBg,
                            iconColor: textColor,
                            size: 34,
                            hasBorder: true,
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
                                size: 34,
                                hasBorder: true,
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
                                size: 34,
                                hasBorder: true,
                              ),
                              const SizedBox(width: 8),
                              StoryCircleIconButton(
                                icon: Icons.settings,
                                onPressed: () =>
                                    context.push('/settings', extra: {
                                  'profileId': profileId,
                                }),
                                backgroundColor: iconBtnBg,
                                iconColor: textColor,
                                size: 34,
                                hasBorder: true,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),

                    // 2. Parchemin
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: pageColor,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: borderColor,
                            width: 3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.4),
                              blurRadius: 24,
                              offset: const Offset(0, 8),
                            ),
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 12,
                              offset: const Offset(0, 0),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(2),
                          child: Stack(
                            children: [
                              Positioned.fill(
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        const Color(0xFFFAF6EB)
                                            .withOpacity(0.3),
                                        const Color(0xFFF0E8D8)
                                            .withOpacity(0.3),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              LayoutBuilder(
                                builder: (context, constraints) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 12),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        _buildDecorativeHeader(
                                            subtleTextColor, textColor),
                                        Expanded(
                                          flex: 4,
                                          child: Center(
                                            child: _buildImageFrame(textColor,
                                                subtleTextColor, borderColor),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Expanded(
                                          flex: 5,
                                          child: StoryTextArea(
                                            params: params,
                                            metrics: StoryTextMetrics(
                                              fontSize: params.fontSize,
                                              fontFamily: GoogleFonts
                                                      .cormorantGaramond()
                                                  .fontFamily,
                                              lineHeight: 1.6,
                                              letterSpacing: -0.15,
                                              textAlign: TextAlign.justify,
                                              dyslexia: params.isDyslexia,
                                              dropCapFontFamily: GoogleFonts
                                                      .cormorantGaramond(
                                                          fontWeight:
                                                              FontWeight.w700)
                                                  .fontFamily,
                                            ),
                                            colors: const StoryTextColors(
                                              text: Color(0xFF32271B),
                                              activeText: Color(0xFF6B3A00),
                                              highlight: Color(0x40B8A680),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            _buildDecorativeFooter(
                                                subtleTextColor, textColor),
                                            const SizedBox(height: 6),
                                            _buildPagination(subtleTextColor),
                                          ],
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // 3. BARRE AUDIO
                    if (params.isAudio)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: pageColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: borderColor.withOpacity(0.6),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            if (params.isLoading)
                              SizedBox(
                                width: 32,
                                height: 32,
                                child: Padding(
                                  padding: const EdgeInsets.all(6.0),
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor:
                                        AlwaysStoppedAnimation(textColor),
                                  ),
                                ),
                              )
                            else
                              GestureDetector(
                                onTap: params.onToggleAudio,
                                child: Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: textColor,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    params.isPlaying
                                        ? Icons.pause_rounded
                                        : Icons.play_arrow_rounded,
                                    color: pageColor,
                                    size: 18,
                                  ),
                                ),
                              ),
                            const SizedBox(width: 6),
                            Text(
                              StoryUtils.formatDuration(params.audioPosition),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: subtleTextColor,
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 4),
                                child: SliderTheme(
                                  data: SliderTheme.of(context).copyWith(
                                    trackHeight: 2,
                                    thumbShape: const RoundSliderThumbShape(
                                        enabledThumbRadius: 6),
                                    activeTrackColor: textColor,
                                    inactiveTrackColor:
                                        subtleTextColor.withOpacity(0.3),
                                    thumbColor: textColor,
                                    overlayColor: textColor.withOpacity(0.1),
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
                                    onChanged: params.onSeekAudioChanged,
                                    onChangeEnd: params.onSeekAudio,
                                  ),
                                ),
                              ),
                            ),
                            Text(
                              StoryUtils.formatDuration(params.audioDuration),
                              style: TextStyle(
                                fontSize: 11,
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
                  backgroundColor: Colors.transparent,
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
                  backgroundColor: Colors.transparent,
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

  Widget _buildDecorativeHeader(Color subtleColor, Color accentColor) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Container(
                height: 1,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      accentColor.withOpacity(0),
                      accentColor.withOpacity(0.5),
                      accentColor.withOpacity(0),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                '✦',
                style: TextStyle(color: accentColor, fontSize: 14),
              ),
            ),
            Expanded(
              child: Container(
                height: 1,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      accentColor.withOpacity(0),
                      accentColor.withOpacity(0.5),
                      accentColor.withOpacity(0),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('❖  ', style: TextStyle(color: subtleColor, fontSize: 10)),
            Text('❖  ', style: TextStyle(color: subtleColor, fontSize: 10)),
            Text('❖', style: TextStyle(color: subtleColor, fontSize: 10)),
          ],
        ),
      ],
    );
  }

  Widget _buildDecorativeFooter(Color subtleColor, Color accentColor) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('❖  ', style: TextStyle(color: subtleColor, fontSize: 10)),
            Text('❖  ', style: TextStyle(color: subtleColor, fontSize: 10)),
            Text('❖', style: TextStyle(color: subtleColor, fontSize: 10)),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Container(
                height: 1,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      accentColor.withOpacity(0),
                      accentColor.withOpacity(0.5),
                      accentColor.withOpacity(0),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                '✦',
                style: TextStyle(color: accentColor, fontSize: 14),
              ),
            ),
            Expanded(
              child: Container(
                height: 1,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      accentColor.withOpacity(0),
                      accentColor.withOpacity(0.5),
                      accentColor.withOpacity(0),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildImageFrame(
      Color accentColor, Color subtleColor, Color borderColor) {
    return AspectRatio(
      aspectRatio: 14 / 10,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: accentColor, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 6,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: borderColor.withOpacity(0.4), width: 1),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(1),
              child: StoryImage(imageKey: params.image),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPagination(Color subtleColor) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 40,
          height: 1,
          color: subtleColor.withOpacity(0.3),
        ),
        const SizedBox(height: 6),
        Text(
          '${params.currentPageIndex + 1} / ${params.totalPages}',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: subtleColor,
            letterSpacing: 2,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }
}
