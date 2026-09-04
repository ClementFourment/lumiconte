import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lumiconte/models/audio_sync_model.dart';
import 'package:lumiconte/pages/story/story_view_params.dart';
import 'package:lumiconte/widget/b2_image.dart';

class StoryClassicView extends StatefulWidget {
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
  State<StoryClassicView> createState() => _StoryClassicViewState();
}

class _StoryClassicViewState extends State<StoryClassicView> {
  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor =
        widget.isDark ? const Color(0xFF161224) : const Color(0xFFF3F4F6);
    final Color cardColor =
        widget.isDark ? const Color(0xFF26203B) : Colors.white;
    final Color textColor =
        widget.isDark ? Colors.white : const Color(0xFF1F2937);
    final Color subtleTextColor =
        widget.isDark ? Colors.white38 : Colors.black38;
    final Color iconBtnBg = widget.isDark
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
                    onPressed: widget.params.onBack,
                    backgroundColor: iconBtnBg,
                    iconColor: textColor,
                  ),
                  Row(
                    children: [
                      _CircleIconButton(
                        icon: widget.params.isFavorite
                            ? Icons.favorite
                            : Icons.favorite_border,
                        onPressed: widget.params.onToggleFavorite,
                        backgroundColor: iconBtnBg,
                        iconColor: widget.params.isFavorite
                            ? const Color(0xFFEF4444)
                            : textColor,
                      ),
                      const SizedBox(width: 6),
                      _CircleIconButton(
                        icon: Icons.settings,
                        onPressed: () => context.push('/settings', extra: {
                          'profileId': widget.profileId,
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
                    boxShadow: widget.isDark
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
                                        widget.params.onPreviousPage();
                                      } else if (details.primaryVelocity! < 0) {
                                        widget.params.onNextPage();
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
                                                  key: ValueKey(widget.params.currentPageIndex),
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
                                            '${widget.params.currentPageIndex + 1} / ${widget.params.totalPages}',
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
                                    onPressed:
                                        widget.params.currentPageIndex > 0
                                            ? widget.params.onPreviousPage
                                            : null,
                                    backgroundColor: widget.isDark
                                        ? Colors.black.withOpacity(0.5)
                                        : Colors.white.withOpacity(0.9),
                                    iconColor:
                                        widget.params.currentPageIndex > 0
                                            ? textColor
                                            : textColor.withOpacity(0.3),
                                    size: 40,
                                  ),
                                  _CircleIconButton(
                                    icon: Icons.chevron_right,
                                    onPressed: widget.params.currentPageIndex <
                                            widget.params.totalPages - 1
                                        ? widget.params.onNextPage
                                        : null,
                                    backgroundColor: widget.isDark
                                        ? Colors.black.withOpacity(0.5)
                                        : Colors.white.withOpacity(0.9),
                                    iconColor: widget.params.currentPageIndex <
                                            widget.params.totalPages - 1
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
              if (widget.params.isAudio)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    children: [
                      if (widget.params.isLoading)
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
                          onTap: widget.params.onToggleAudio,
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: const BoxDecoration(
                              color: accentColor,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              widget.params.isPlaying
                                  ? Icons.pause_rounded
                                  : Icons.play_arrow_rounded,
                              color: Colors.black,
                              size: 24,
                            ),
                          ),
                        ),
                      const SizedBox(width: 8),
                      Text(
                        _formatDuration(widget.params.audioPosition),
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
                            inactiveTrackColor: widget.isDark
                                ? Colors.white.withOpacity(0.15)
                                : Colors.black.withOpacity(0.1),
                            thumbColor: accentColor,
                            overlayColor: accentColor.withOpacity(0.2),
                          ),
                          child: Slider(
                            min: 0,
                            max: widget.params.audioDuration.inSeconds
                                        .toDouble() >
                                    0
                                ? widget.params.audioDuration.inSeconds
                                    .toDouble()
                                : 1,
                            value: widget.params.audioPosition.inSeconds
                                .clamp(
                                    0, widget.params.audioDuration.inSeconds)
                                .toDouble(),
                            onChanged: (_) {},
                            onChangeEnd: widget.params.onSeekAudio,
                          ),
                        ),
                      ),
                      Text(
                        _formatDuration(widget.params.audioDuration),
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
    if (widget.params.currentSegments.isNotEmpty) {
      final double currentTimeInSeconds =
          widget.params.audioPosition.inMilliseconds / 1000.0;

      return Wrap(
        alignment: WrapAlignment.center,
        spacing: 4.0,
        runSpacing: 6.0,
        children: widget.params.currentSegments.expand((segment) {
          return segment.words.map((wordTiming) {
            final bool isActive = currentTimeInSeconds >= wordTiming.start &&
                currentTimeInSeconds <= wordTiming.end;

            return AnimatedContainer(
              duration: const Duration(milliseconds: 80),
              padding:
                  const EdgeInsets.symmetric(horizontal: 3.0, vertical: 1.0),
              decoration: BoxDecoration(
                color: isActive
                    ? const Color(0xFFF59E0B).withOpacity(0.4)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(4.0),
              ),
              child: Text(
                wordTiming.word,
                style: TextStyle(
                  fontSize: widget.params.fontSize,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  color: isActive ? Colors.amber.shade900 : defaultTextColor,
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
      text: widget.params.buildColorizedText(
        text: _getCleanPageText(widget.params.currentPageText),
        baseFontSize: widget.params.fontSize,
        defaultTextColor: defaultTextColor,
        isDyslexiaEnabled: widget.params.isDyslexia,
      ),
    );
  }

  Widget _buildStoryImage() {
    String? imageUrl = widget.params.image;

    final pattern = RegExp(r'\[img:(\d+)\]');
    final match = pattern.firstMatch(widget.params.currentPageText);

    if (match != null &&
        widget.params.illustrationsPath != null &&
        widget.params.illustrationsPath!.isNotEmpty) {
      final imgNumber = match.group(1);
      imageUrl = '${widget.params.illustrationsPath}/img$imgNumber.webp';
    }

    return SizedBox.expand(
      child: B2Image(
        key: ValueKey(imageUrl),
        objectKey: imageUrl,
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