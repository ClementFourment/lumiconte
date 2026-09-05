import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lumiconte/models/audio_sync_model.dart';
import 'package:lumiconte/pages/story/story_view_params.dart';
import 'package:lumiconte/widget/b2_image.dart';
import 'package:lumiconte/widget/drop_cap_text.dart';

class StoryManuscriptView extends StatelessWidget {
  final StoryViewParams params;
  final String profileId;

  const StoryManuscriptView({
    super.key,
    required this.params,
    required this.profileId,
  });

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Column(
            children: [
              // 1. Barre supérieure
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _CircleIconButton(
                      icon: Icons.chevron_left,
                      onPressed: params.onBack,
                      backgroundColor: iconBtnBg,
                      iconColor: textColor,
                      size: 34,
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
                          size: 34,
                        ),
                        const SizedBox(width: 8),
                        _CircleIconButton(
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
                    child: GestureDetector(
                      onHorizontalDragEnd: (details) {
                        if (details.primaryVelocity! > 0) {
                          params.onPreviousPage();
                        } else if (details.primaryVelocity! < 0) {
                          params.onNextPage();
                        }
                      },
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    const Color(0xFFFAF6EB).withOpacity(0.3),
                                    const Color(0xFFF0E8D8).withOpacity(0.3),
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
                                      child: Center(
                                        child: SingleChildScrollView(
                                          physics:
                                              const BouncingScrollPhysics(),
                                          child: _buildBookCompositionText(
                                              textColor),
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
              ),
              const SizedBox(height: 10),

              // 3. BARRE AUDIO
              if (params.isAudio)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                              valueColor: AlwaysStoppedAnimation(textColor),
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
                        _formatDuration(params.audioPosition),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: subtleTextColor,
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              trackHeight: 2,
                              thumbShape: const RoundSliderThumbShape(
                                  enabledThumbRadius: 4),
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
                              onChanged: (_) {},
                              onChangeEnd: params.onSeekAudio,
                            ),
                          ),
                        ),
                      ),
                      Text(
                        _formatDuration(params.audioDuration),
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
              child: _buildStoryImage(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBookCompositionText(Color textColor) {
    final cleanText = _getCleanPageText(params.currentPageText);

    if (cleanText.isEmpty) {
      return const SizedBox.shrink();
    }

    final adjustedFontSize =
        params.fontSize > 16 ? 15.0 : params.fontSize;
    const inkColor = Color(0xFF32271B);
    final highlightBg = const Color(0xFFB8A680).withOpacity(0.25);
    const activeInkColor = Color(0xFF6B3A00);

    if (params.currentSegments.isNotEmpty) {
      final double currentTimeInSeconds =
          params.audioPosition.inMilliseconds / 1000.0;

      final allWords = params.currentSegments
          .expand((segment) => segment.words)
          .toList();

      if (allWords.isEmpty) return const SizedBox.shrink();

      final firstWordTiming = allWords.first;
      final otherWords = allWords.skip(1);

      final bool isFirstActive = currentTimeInSeconds >= firstWordTiming.start &&
          currentTimeInSeconds <= firstWordTiming.end;

      final String firstLetter = firstWordTiming.word.isNotEmpty
          ? firstWordTiming.word[0]
          : '';
      final String restOfFirstWord = firstWordTiming.word.length > 1
          ? firstWordTiming.word.substring(1)
          : '';

      return AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: KeyedSubtree(
          key: ValueKey(params.currentPageIndex),
          child: Wrap(
            alignment: WrapAlignment.start,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 4.0,
            runSpacing: 6.0,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 120),
                padding: const EdgeInsets.symmetric(horizontal: 3.0, vertical: 1.0),
                decoration: BoxDecoration(
                  color: isFirstActive ? highlightBg : Colors.transparent,
                  borderRadius: BorderRadius.circular(4.0),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      firstLetter,
                      style: GoogleFonts.cormorantGaramond(
                        fontSize: adjustedFontSize * 2.2,
                        fontWeight: FontWeight.bold,
                        color: isFirstActive ? activeInkColor : inkColor,
                        height: 0.8,
                      ),
                    ),
                    Text(
                      restOfFirstWord,
                      style: TextStyle(
                        fontSize: adjustedFontSize,
                        fontWeight:
                            isFirstActive ? FontWeight.w600 : FontWeight.normal,
                        color: isFirstActive ? activeInkColor : inkColor,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              ...otherWords.map((wordTiming) {
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
                      fontSize: adjustedFontSize,
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                      color: isActive ? activeInkColor : inkColor,
                      height: 1.5,
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      );
    }

    if (params.isDyslexia) {
      return AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: RichText(
          key: ValueKey(params.currentPageIndex),
          textAlign: TextAlign.justify,
          text: params.buildColorizedText(
            text: cleanText,
            baseFontSize: adjustedFontSize,
            defaultTextColor: inkColor,
            isDyslexiaEnabled: params.isDyslexia,
          ),
        ),
      );
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: KeyedSubtree(
        key: ValueKey(params.currentPageIndex),
        child: DropCapText(
          cleanText,
          style: GoogleFonts.cormorantGaramond(
            fontSize: adjustedFontSize,
            color: inkColor,
            height: 1.6,
            letterSpacing: -0.15,
          ),
          textAlign: TextAlign.justify,
          dropCapChars: 1,
          indentation: Offset.zero,
          dropCapStyle: GoogleFonts.cormorantGaramond(
            fontSize: adjustedFontSize * 4.6,
            fontWeight: FontWeight.w700,
            color: inkColor,
            height: 0.65,
          ),
          dropCapPadding: const EdgeInsets.only(
            right: 4,
            bottom: 1,
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
    this.size = 36,
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
            border: Border.all(
              color: iconColor.withOpacity(0.2),
              width: 1,
            ),
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