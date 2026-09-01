import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lumiconte/models/audio_sync_model.dart';
import 'package:lumiconte/pages/story/story_view_params.dart';
import 'package:lumiconte/widget/b2_image.dart';

class StoryImmersiveView extends StatefulWidget {
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
  State<StoryImmersiveView> createState() => _StoryImmersiveViewState();
}

class _StoryImmersiveViewState extends State<StoryImmersiveView> {
  late String? _currentImageUrl;

  @override
  void initState() {
    super.initState();
    _currentImageUrl = widget.params.image;
  }

  void updateImageUrl(String newUrl) {
    setState(() {
      _currentImageUrl = newUrl;
    });
  }

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor =
        widget.isDark ? const Color(0xFF161224) : const Color(0xFFF3F4F6);
    final Color textColor = Colors.white;
    final Color subtleTextColor = Colors.white70;
    final Color iconBtnBg = Colors.black.withOpacity(0.3);
    const Color accentColor = Color(0xFFF59E0B);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Image en plein écran
          GestureDetector(
            onHorizontalDragEnd: (details) {
              if (details.primaryVelocity! > 0) {
                widget.params.onPreviousPage();
              } else if (details.primaryVelocity! < 0) {
                widget.params.onNextPage();
              }
            },
            child: Stack(
              fit: StackFit.expand,
              children: [
                _buildStoryImage(),
                // Dégradé global sombre sur le bas pour fondre le texte et l'audio
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
          ),

          // 2. Contenu superposé
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                children: [
                  // App Bar supérieure (Retour & Favori)
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
                          const SizedBox(width: 8),
                          _CircleIconButton(
                            icon: Icons.settings,
                            onPressed: () => context.push('/settings', extra: {
                              'profileId': widget.profileId,
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

                  // Texte de l'histoire avec support du surlignage synchronisé
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: KeyedSubtree(
                          key: ValueKey(widget.params.currentPageIndex),
                          child: _buildTextContent(textColor),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Compteur de pages
                  Text(
                    '${widget.params.currentPageIndex + 1} / ${widget.params.totalPages}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: subtleTextColor,
                      letterSpacing: 1.5,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 3. Barre Audio
                  if (widget.params.isAudio)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
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
                                max: widget.params.audioDuration.inSeconds
                                            .toDouble() >
                                        0
                                    ? widget.params.audioDuration.inSeconds
                                        .toDouble()
                                    : 1,
                                value: widget.params.audioPosition.inSeconds
                                    .clamp(
                                        0,
                                        widget.params.audioDuration.inSeconds)
                                    .toDouble(),
                                onChanged: (_) {},
                                onChangeEnd: widget.params.onSeekAudio,
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
        ],
      ),
    );
  }

  /// Rend le texte avec surlignage mot par mot si la synchronisation existe, sinon rendu standard
  Widget _buildTextContent(Color defaultTextColor) {
    if (widget.params.currentSegments.isNotEmpty) {
      final double currentTimeInSeconds =
          widget.params.audioPosition.inMilliseconds / 1000.0;

      return Wrap(
        alignment: WrapAlignment.start,
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
                  color: isActive ? Colors.amber.shade300 : defaultTextColor,
                  height: 1.5,
                ),
              ),
            );
          });
        }).toList(),
      );
    }

    return RichText(
      textAlign: TextAlign.left,
      text: widget.params.buildColorizedText(
        text: _getCleanPageText(widget.params.currentPageText),
        baseFontSize: widget.params.fontSize,
        defaultTextColor: defaultTextColor,
        isDyslexiaEnabled: widget.params.isDyslexia,
      ),
    );
  }

  Widget _buildStoryImage() {
    final pattern = RegExp(r'\[img:(\d+)\]');
    final match = pattern.firstMatch(widget.params.currentPageText);

    if (match != null &&
        widget.params.illustrationsPath != '' &&
        widget.params.illustrationsPath?.isNotEmpty == true) {
      final imgNumber = match.group(1);
      _currentImageUrl =
          '${widget.params.illustrationsPath}/img$imgNumber.webp';
    }
    return SizedBox.expand(
      child: B2Image(
        objectKey: _currentImageUrl,
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