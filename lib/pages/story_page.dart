import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lumiconte/models/profile_model.dart';
import 'package:lumiconte/models/story_model.dart';
import 'package:lumiconte/models/settings_model.dart';
import 'package:lumiconte/widget/b2_audio.dart';
import 'package:lumiconte/widget/b2_image.dart';
import 'package:lumiconte/theme/app_theme.dart';

class StoryPage extends StatefulWidget {
  final StoryModel story;
  final ProfileModel profile;

  const StoryPage({
    super.key,
    required this.story,
    required this.profile,
  });

  @override
  State<StoryPage> createState() => _StoryPageState();
}

class _StoryPageState extends State<StoryPage> {
  late List<String> _pages;
  int _currentPage = 0;
  bool _isFavorite = false;
  bool _isPlaying = false;
  bool _isLoading = false;
  bool _isSeeking = false;
  bool _isAudio = false;
  Duration _audioPosition = Duration.zero;
  Duration _audioDuration = Duration.zero;

  B2Audio? _audio;
  late final String _uid;
  late final CollectionReference _settingsCollection;

  @override
  void initState() {
    super.initState();
    _uid = FirebaseAuth.instance.currentUser!.uid;
    _settingsCollection = FirebaseFirestore.instance
        .collection('users')
        .doc(_uid)
        .collection('profiles')
        .doc(widget.profile.id)
        .collection('settings');

    _initializePages();
    _initializeAudio();
  }

  void _initializePages() {
    final rawText = widget.story.content
        .replaceAll(r'\n', '\n\n')
        .replaceAll(RegExp(r'[ \t]+'), ' ')
        .trim();

    _pages = _splitTextIntoPages(rawText);
  }

  /// Divise le texte en pages intelligemment
  List<String> _splitTextIntoPages(String text) {
    final sentences = text.split(RegExp(r'(?<=[.!?])\s+'));

    final pages = <String>[];
    String currentPage = '';

    for (var sentence in sentences) {
      final testPage =
          currentPage.isEmpty ? sentence : '$currentPage $sentence';

      if (testPage.length > 150 && currentPage.isNotEmpty) {
        pages.add(currentPage.trim());
        currentPage = sentence;
      } else {
        currentPage = testPage;
      }
    }

    if (currentPage.isNotEmpty) {
      pages.add(currentPage.trim());
    }

    return pages.isEmpty ? [text] : pages;
  }

  void _initializeAudio() {
    _isAudio = (widget.story.audio.isNotEmpty &&
        widget.story.audio.first.values.isNotEmpty);

    final audio = _isAudio ? widget.story.audio.first.values.first : '';

    if (_isAudio) {
      _audio = B2Audio(objectKey: audio);
      _audio!.preload();

      _audio!.onComplete.listen((_) {
        _handleAudioComplete();
      });

      _audio!.onPositionChanged.listen((position) {
        if (mounted && !_isSeeking) {
          setState(() {
            _audioPosition = position;
          });
        }
      });

      _audio!.onDurationChanged.listen((duration) {
        if (mounted) {
          setState(() {
            _audioDuration = duration;
          });
        }
      });
    }
  }

  /// Algorithme dyslexie réutilisé de SettingsPage
  List<TextSpan> _parseWordToDyslexiaSpans(
    String word,
    TextStyle baseDysStyle,
    Color defaultTextColor,
  ) {
    final Color colorRed = Colors.red.shade700;
    final Color colorBlue = Colors.blue.shade700;
    final Color colorSilent = defaultTextColor.withOpacity(0.35);

    if (word.trim().isEmpty) {
      return [
        TextSpan(
            text: word, style: baseDysStyle.copyWith(color: defaultTextColor))
      ];
    }

    final matchStart = RegExp(r'^[^a-zA-ZÀ-ÿ]+').firstMatch(word);
    final matchEnd = RegExp(r'[^a-zA-ZÀ-ÿ]+$').firstMatch(word);

    String prefix = matchStart?.group(0) ?? '';
    String suffix = matchEnd?.group(0) ?? '';

    String cleanWord = word;

    if (prefix.length + suffix.length < word.length) {
      cleanWord = word.substring(prefix.length, word.length - suffix.length);
    } else {
      return [
        TextSpan(
            text: word, style: baseDysStyle.copyWith(color: defaultTextColor))
      ];
    }

    if (cleanWord.isEmpty) {
      return [
        TextSpan(
            text: word, style: baseDysStyle.copyWith(color: defaultTextColor))
      ];
    }

    String silentLetters = '';
    final silentMatch = RegExp(r'(ts|ds|es|[stdxega])$', caseSensitive: false)
        .firstMatch(cleanWord);

    if (silentMatch != null &&
        cleanWord.length > 2 &&
        !['les', 'des', 'mes', 'tes', 'ses', 'est']
            .contains(cleanWord.toLowerCase())) {
      String potentialSilent = silentMatch.group(0) ?? '';
      if (cleanWord.length > potentialSilent.length) {
        silentLetters = potentialSilent;
        cleanWord =
            cleanWord.substring(0, cleanWord.length - silentLetters.length);
      }
    }

    List<TextSpan> wordSpans = [];

    if (prefix.isNotEmpty) {
      wordSpans.add(TextSpan(
          text: prefix, style: baseDysStyle.copyWith(color: defaultTextColor)));
    }

    List<String> syllables = [];
    if (cleanWord.length <= 3) {
      syllables.add(cleanWord);
    } else {
      final regex = RegExp(
        r'[^aeiouyéèàùûâîôœüéèêë]*[aeiouyéèàùûâîôœüéèêë]+(?:[^aeiouyéèàùûâîôœüéèêë](?![aeiouyéèàùûâîôœüéèêë]))*',
        caseSensitive: false,
      );
      final matches = regex.allMatches(cleanWord);
      if (matches.isEmpty) {
        syllables.add(cleanWord);
      } else {
        for (var m in matches) {
          syllables.add(m.group(0) ?? '');
        }
        int totalLength = syllables.join().length;
        if (totalLength < cleanWord.length && syllables.isNotEmpty) {
          syllables[syllables.length - 1] += cleanWord.substring(totalLength);
        }
      }
    }

    for (int i = 0; i < syllables.length; i++) {
      if (syllables[i].isEmpty) continue;
      wordSpans.add(TextSpan(
        text: syllables[i],
        style: baseDysStyle.copyWith(
          color: i % 2 == 0 ? colorBlue : colorRed,
        ),
      ));
    }

    if (silentLetters.isNotEmpty) {
      wordSpans.add(TextSpan(
        text: silentLetters,
        style: baseDysStyle.copyWith(
          color: colorSilent,
          fontWeight: FontWeight.w300,
          fontStyle: FontStyle.italic,
        ),
      ));
    }

    if (suffix.isNotEmpty) {
      wordSpans.add(TextSpan(
          text: suffix, style: baseDysStyle.copyWith(color: defaultTextColor)));
    }

    return wordSpans;
  }

  TextSpan _buildColorizedText({
    required String text,
    required double baseFontSize,
    required Color defaultTextColor,
    required bool isDyslexiaEnabled,
  }) {
    if (!isDyslexiaEnabled) {
      return TextSpan(
        text: text,
        style: TextStyle(color: defaultTextColor, fontSize: baseFontSize),
      );
    }

    final double dysFontSize = baseFontSize + 4;
    const double dysLetterSpacing = 1.8;
    const double dysLineHeight = 1.6;

    final TextStyle baseDysStyle = TextStyle(
      fontSize: dysFontSize,
      letterSpacing: dysLetterSpacing,
      height: dysLineHeight,
      fontWeight: FontWeight.bold,
    );

    List<TextSpan> allSpans = [];
    List<String> words = text.split(' ');

    for (int i = 0; i < words.length; i++) {
      allSpans.addAll(
          _parseWordToDyslexiaSpans(words[i], baseDysStyle, defaultTextColor));
      if (i < words.length - 1) {
        allSpans.add(TextSpan(text: ' ', style: baseDysStyle));
      }
    }

    return TextSpan(children: allSpans);
  }

  /// Récupère les couleurs en fonction du thème de lecture
  _ThemeColors _getThemeColors(SettingsModel settings) {
    if (settings.dyslexia) {
      return _ThemeColors(
        backgroundColor: Colors.white,
        textColor: const Color(0xFF2B261F),
      );
    }

    switch (settings.readTheme) {
      case 'dark':
        return _ThemeColors(
          backgroundColor: const Color(0xFF1C1C1E),
          textColor: Colors.white,
        );
      case 'naturel':
        return _ThemeColors(
          backgroundColor: const Color(0xFFF5EFE6),
          textColor: const Color(0xFF2B261F),
        );
      case 'light':
      default:
        return _ThemeColors(
          backgroundColor: Colors.white,
          textColor: Colors.black87,
        );
    }
  }

  Future<void> _handleAudioComplete() async {
    if (!mounted) return;

    try {
      setState(() {
        _isPlaying = false;
        _audioPosition = Duration.zero;
        _isSeeking = true;
      });

      await _audio?.seekToStart();

      if (mounted) {
        setState(() {
          _isSeeking = false;
        });
      }
    } catch (e) {
      debugPrint('Erreur lors de la fin d\'audio: $e');
      if (mounted) {
        setState(() {
          _isSeeking = false;
        });
      }
    }
  }

  Future<void> _seekAudio(double value) async {
    setState(() => _isSeeking = true);
    try {
      await _audio?.seek(Duration(seconds: value.toInt()));
      if (mounted) {
        setState(() {
          _audioPosition = Duration(seconds: value.toInt());
        });
      }
    } catch (e) {
      debugPrint('Erreur seek: $e');
    } finally {
      if (mounted) {
        setState(() => _isSeeking = false);
      }
    }
  }

  Future<void> _toggleAudio() async {
    if (_isPlaying) {
      await _audio?.pause();
      setState(() => _isPlaying = false);
      return;
    }

    if (_audioPosition >= _audioDuration && _audioDuration > Duration.zero) {
      setState(() => _isSeeking = true);
      try {
        await _audio?.seekToStart();
        setState(() {
          _audioPosition = Duration.zero;
          _isSeeking = false;
        });
      } catch (e) {
        debugPrint('Erreur lors du rewind: $e');
        setState(() => _isSeeking = false);
      }
    }

    setState(() => _isLoading = true);
    try {
      await _audio?.play();
      if (mounted) setState(() => _isPlaying = true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur audio: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _goToNextPage() {
    if (_currentPage < _pages.length - 1) {
      setState(() => _currentPage++);
    }
  }

  void _goToPreviousPage() {
    if (_currentPage > 0) {
      setState(() => _currentPage--);
    }
  }

  @override
  void dispose() {
    _audio?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _settingsCollection.snapshots(),
      builder: (context, snapshot) {
        // Chargement des settings
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: const Center(
              child: CircularProgressIndicator(
                color: AppTheme.accentColor,
              ),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: Text(
                'Erreur : paramètres non trouvés',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ),
          );
        }

        final settingsDoc = snapshot.data!.docs.first;
        final settings = SettingsModel.fromMap(
          settingsDoc.data() as Map<String, dynamic>,
          settingsDoc.id,
        );

        final themeColors = _getThemeColors(settings);

        return Scaffold(
          backgroundColor: themeColors.backgroundColor,
          body: Stack(
            children: [
              SafeArea(
                child: Column(
                  children: [
                    // Top bar
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          _CircleButton(
                            icon: Icons.arrow_back,
                            onPressed: () => Navigator.pop(context),
                            color: themeColors.textColor,
                          ),
                          const Spacer(),
                          _CircleButton(
                            icon: _isFavorite
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: _isFavorite
                                ? Colors.red
                                : themeColors.textColor,
                            onPressed: () =>
                                setState(() => _isFavorite = !_isFavorite),
                          ),
                        ],
                      ),
                    ),

                    // Image illustrative
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 16),
                        child: Hero(
                          tag: widget.story.image,
                          child: B2Image(
                            objectKey: widget.story.image,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),

                    // Texte - Page actuelle
                    Expanded(
                      flex: 2,
                      child: Center(
                        child: SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 32, vertical: 24),
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              transitionBuilder: (child, animation) {
                                return FadeTransition(
                                    opacity: animation, child: child);
                              },
                              child: RichText(
                                key: ValueKey(_currentPage),
                                textAlign: TextAlign.center,
                                text: _buildColorizedText(
                                  text: _pages[_currentPage],
                                  baseFontSize: settings.fontSize.toDouble(),
                                  defaultTextColor: themeColors.textColor,
                                  isDyslexiaEnabled: settings.dyslexia,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Pagination
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        '${_currentPage + 1}/${_pages.length}',
                        style: TextStyle(
                          fontSize: 14,
                          color: themeColors.textColor.withOpacity(0.5),
                          fontWeight: FontWeight.w500,
                          letterSpacing: 1,
                        ),
                      ),
                    ),

                    // Contrôles du bas
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                      child: _BottomControls(
                        storyId: widget.story.id,
                        isPlaying: _isPlaying,
                        isLoading: _isLoading,
                        isAudio: _isAudio,
                        audioPosition: _audioPosition,
                        audioDuration: _audioDuration,
                        onSeek: _seekAudio,
                        onToggleAudio: _toggleAudio,
                        onPrevious: _goToPreviousPage,
                        onNext: _goToNextPage,
                        canGoPrevious: _currentPage > 0,
                        canGoNext: _currentPage < _pages.length - 1,
                        themeColors: themeColors,
                        isDyslexia: settings.dyslexia,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _BottomControls extends StatelessWidget {
  final String storyId;
  final bool isPlaying;
  final bool isLoading;
  final bool isAudio;
  final Duration audioPosition;
  final Duration audioDuration;
  final ValueChanged<double> onSeek;
  final VoidCallback onToggleAudio;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final bool canGoPrevious;
  final bool canGoNext;
  final _ThemeColors themeColors;
  final bool isDyslexia;

  const _BottomControls({
    required this.storyId,
    required this.isPlaying,
    required this.isLoading,
    required this.isAudio,
    required this.audioPosition,
    required this.audioDuration,
    required this.onSeek,
    required this.onToggleAudio,
    required this.onPrevious,
    required this.onNext,
    required this.canGoPrevious,
    required this.canGoNext,
    required this.themeColors,
    required this.isDyslexia,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Slider audio
        if (isAudio)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Slider(
              min: 0,
              max: audioDuration.inSeconds.toDouble() > 0
                  ? audioDuration.inSeconds.toDouble()
                  : 1,
              value: audioPosition.inSeconds
                  .clamp(
                    0,
                    audioDuration.inSeconds,
                  )
                  .toDouble(),
              onChanged: (v) {},
              onChangeEnd: (value) {
                onSeek(value);
              },
              activeColor: AppTheme.accentColor,
              inactiveColor: themeColors.textColor.withOpacity(0.1),
            ),
          ),

        // Boutons de contrôle
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: themeColors.textColor.withOpacity(0.05),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: themeColors.textColor.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              // Bouton précédent
              _ControlButton(
                icon: Icons.arrow_back,
                onPressed: canGoPrevious ? onPrevious : null,
                disabled: !canGoPrevious,
                color: themeColors.textColor,
              ),

              const SizedBox(width: 8),

              // Bouton audio
              if (isLoading)
                SizedBox(
                  width: 40,
                  height: 40,
                  child: Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(AppTheme.accentColor),
                    ),
                  ),
                )
              else if (isAudio)
                _ControlButton(
                  icon: isPlaying ? Icons.pause : Icons.play_arrow,
                  onPressed: onToggleAudio,
                  color: themeColors.textColor,
                ),

              const SizedBox(width: 8),

              // Bouton suivant
              _ControlButton(
                icon: Icons.arrow_forward,
                onPressed: canGoNext ? onNext : null,
                disabled: !canGoNext,
                color: themeColors.textColor,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  const _CircleButton({
    required this.icon,
    required this.onPressed,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final bool disabled;
  final Color color;

  const _ControlButton({
    required this.icon,
    required this.onPressed,
    required this.color,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: disabled ? null : onPressed,
      icon: Icon(
        icon,
        color: disabled ? color.withOpacity(0.3) : color,
        size: 24,
      ),
      splashRadius: 24,
    );
  }
}

/// Classe helper pour les couleurs du thème
class _ThemeColors {
  final Color backgroundColor;
  final Color textColor;

  _ThemeColors({
    required this.backgroundColor,
    required this.textColor,
  });
}
