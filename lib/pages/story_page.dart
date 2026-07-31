import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:ui';
import 'package:lumiconte/models/profile_model.dart';
import 'package:lumiconte/models/story_model.dart';
import 'package:lumiconte/models/settings_model.dart';
import 'package:lumiconte/widget/b2_audio.dart';
import 'package:lumiconte/widget/b2_image.dart';

class StoryPage extends StatefulWidget {
  final StoryModel story;
  final ProfileModel profile;

  const StoryPage({super.key, required this.story, required this.profile});

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

  /// Divise le texte en pages (~150 caractères)
  List<String> _splitTextIntoPages(String text) {
    const int charsPerPage = 150;
    final sentences = text.split(RegExp(r'(?<=[.!?])\s+'));

    final pages = <String>[];
    String currentPage = '';

    for (var sentence in sentences) {
      final testPage =
          currentPage.isEmpty ? sentence : '$currentPage $sentence';

      if (testPage.length > charsPerPage && currentPage.isNotEmpty) {
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
    _isAudio = widget.story.audio?.isNotEmpty == true &&
        widget.story.audio!.first.isNotEmpty;

    final audio = _isAudio ? widget.story.audio!.first.values.first : '';

    if (_isAudio && audio.isNotEmpty) {
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
        style: TextStyle(
          color: defaultTextColor,
          fontSize: baseFontSize,
          height: 1.8,
          letterSpacing: 0.2,
        ),
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

  _ThemeColors _getThemeColors(SettingsModel settings) {
    if (settings.dyslexia) {
      return _ThemeColors(
        backgroundColor: Colors.white,
        textColor: const Color(0xFF2B261F),
        accentColor: const Color(0xFF7C3AED),
      );
    }

    switch (settings.readTheme) {
      case 'dark':
        return _ThemeColors(
          backgroundColor: const Color(0xFF0F172A),
          textColor: Colors.white,
          accentColor: const Color(0xFFA78BFA),
        );
      case 'naturel':
        return _ThemeColors(
          backgroundColor: const Color(0xFFFAF5F0),
          textColor: const Color(0xFF1F2937),
          accentColor: const Color(0xFFC084FC),
        );
      case 'light':
      default:
        return _ThemeColors(
          backgroundColor: Colors.white,
          textColor: const Color(0xFF1F2937),
          accentColor: const Color(0xFF7C3AED),
        );
    }
  }

  /// Parse le texte et extrait les images [img:X]
  /// Retourne une liste de widgets (texte + images)
  List<Widget> _buildPageContent(
    String text,
    double fontSize,
    Color textColor,
    bool isDyslexia,
  ) {
    final widgets = <Widget>[];
    final pattern = RegExp(r'\[img:(\d+)\]');

    int lastIndex = 0;
    for (final match in pattern.allMatches(text)) {
      // Ajouter le texte avant l'image
      if (match.start > lastIndex) {
        final textBefore = text.substring(lastIndex, match.start).trim();
        if (textBefore.isNotEmpty) {
          widgets.add(
            RichText(
              textAlign: TextAlign.center,
              text: _buildColorizedText(
                text: textBefore,
                baseFontSize: fontSize,
                defaultTextColor: textColor,
                isDyslexiaEnabled: isDyslexia,
              ),
            ),
          );
          widgets.add(const SizedBox(height: 16));
        }
      }

      // Ajouter l'image
      final imgNumber = match.group(1);
      final imageUrl = '${widget.story.illustrations}img$imgNumber.jpg';
      widgets.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: B2Image(
              objectKey: imageUrl,
              height: 160,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
        ),
      );
      widgets.add(const SizedBox(height: 16));

      lastIndex = match.end;
    }

    // Ajouter le texte restant
    if (lastIndex < text.length) {
      final textAfter = text.substring(lastIndex).trim();
      if (textAfter.isNotEmpty) {
        widgets.add(
          RichText(
            textAlign: TextAlign.center,
            text: _buildColorizedText(
              text: textAfter,
              baseFontSize: fontSize,
              defaultTextColor: textColor,
              isDyslexiaEnabled: isDyslexia,
            ),
          ),
        );
      }
    }

    return widgets.isEmpty
        ? [
            RichText(
              textAlign: TextAlign.center,
              text: _buildColorizedText(
                text: text,
                baseFontSize: fontSize,
                defaultTextColor: textColor,
                isDyslexiaEnabled: isDyslexia,
              ),
            )
          ]
        : widgets;
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
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: const Center(
              child: CircularProgressIndicator(),
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
          body: SafeArea(
            child: Column(
              children: [
                // Header avec boutons
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Row(
                    children: [
                      _IconBtn(
                        icon: Icons.arrow_back_ios_new,
                        onPressed: () => Navigator.pop(context),
                        color: themeColors.textColor,
                      ),
                      const Spacer(),
                      _IconBtn(
                        icon: _isFavorite
                            ? Icons.favorite
                            : Icons.favorite_border,
                        onPressed: () =>
                            setState(() => _isFavorite = !_isFavorite),
                        color: _isFavorite
                            ? const Color(0xFFEF4444)
                            : themeColors.textColor,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Texte principal avec images
                Expanded(
                  child: GestureDetector(
                    onHorizontalDragEnd: (details) {
                      // Swipe vers la droite → page précédente
                      if (details.primaryVelocity! > 0) {
                        _goToPreviousPage();
                      }
                      // Swipe vers la gauche → page suivante
                      else if (details.primaryVelocity! < 0) {
                        _goToNextPage();
                      }
                    },
                    child: Center(
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 32, vertical: 24),
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 400),
                            transitionBuilder: (child, animation) {
                              return FadeTransition(
                                opacity: animation,
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(
                                    sigmaX: Tween<double>(begin: 10, end: 0)
                                        .evaluate(animation),
                                    sigmaY: Tween<double>(begin: 10, end: 0)
                                        .evaluate(animation),
                                  ),
                                  child: child,
                                ),
                              );
                            },
                            child: Column(
                              key: ValueKey(_currentPage),
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: _buildPageContent(
                                _pages[_currentPage],
                                settings.fontSize.toDouble(),
                                themeColors.textColor,
                                settings.dyslexia,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Pagination
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    '${_currentPage + 1} / ${_pages.length}',
                    style: TextStyle(
                      fontSize: 12,
                      color: themeColors.textColor.withOpacity(0.5),
                      fontWeight: FontWeight.w600,
                      letterSpacing: 2,
                    ),
                  ),
                ),

                // Footer avec contrôles
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Slider audio
                      if (_isAudio)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: Column(
                            children: [
                              Slider(
                                min: 0,
                                max: _audioDuration.inSeconds.toDouble() > 0
                                    ? _audioDuration.inSeconds.toDouble()
                                    : 1,
                                value: _audioPosition.inSeconds
                                    .clamp(0, _audioDuration.inSeconds)
                                    .toDouble(),
                                onChanged: (v) {},
                                onChangeEnd: (value) {
                                  _seekAudio(value);
                                },
                                activeColor: themeColors.accentColor,
                                inactiveColor:
                                    themeColors.textColor.withOpacity(0.1),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      _formatDuration(_audioPosition),
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: themeColors.textColor
                                            .withOpacity(0.6),
                                      ),
                                    ),
                                    Text(
                                      _formatDuration(_audioDuration),
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: themeColors.textColor
                                            .withOpacity(0.6),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                      // Boutons de contrôle
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 16),
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
                            _IconBtn(
                              icon: Icons.arrow_back,
                              onPressed:
                                  _currentPage > 0 ? _goToPreviousPage : null,
                              color: _currentPage > 0
                                  ? themeColors.textColor
                                  : themeColors.textColor.withOpacity(0.3),
                            ),

                            const Spacer(),

                            // Bouton audio
                            if (_isLoading)
                              SizedBox(
                                width: 40,
                                height: 40,
                                child: Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation(
                                        themeColors.accentColor),
                                  ),
                                ),
                              )
                            else if (_isAudio)
                              _IconBtn(
                                icon: _isPlaying
                                    ? Icons.pause_rounded
                                    : Icons.play_arrow_rounded,
                                onPressed: _toggleAudio,
                                color: themeColors.accentColor,
                                size: 28,
                              ),

                            const Spacer(),

                            // Bouton suivant
                            _IconBtn(
                              icon: Icons.arrow_forward,
                              onPressed: _currentPage < _pages.length - 1
                                  ? _goToNextPage
                                  : null,
                              color: _currentPage < _pages.length - 1
                                  ? themeColors.textColor
                                  : themeColors.textColor.withOpacity(0.3),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color color;
  final double size;

  const _IconBtn({
    required this.icon,
    this.onPressed,
    required this.color,
    this.size = 24,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Icon(
            icon,
            color: color,
            size: size,
          ),
        ),
      ),
    );
  }
}

class _ThemeColors {
  final Color backgroundColor;
  final Color textColor;
  final Color accentColor;

  _ThemeColors({
    required this.backgroundColor,
    required this.textColor,
    required this.accentColor,
  });
}
