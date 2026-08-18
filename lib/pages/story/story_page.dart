import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:audio_service/audio_service.dart';
import 'package:lumiconte/models/profile_model.dart';
import 'package:lumiconte/models/story_model.dart';
import 'package:lumiconte/models/settings_model.dart';
import 'package:lumiconte/widget/b2_audio.dart';
import 'package:lumiconte/pages/story/story_classic_view.dart';
import 'package:lumiconte/pages/story/story_immersive_view.dart';
import 'package:lumiconte/pages/story/story_manuscript_view.dart';
import 'package:lumiconte/pages/story/story_view_params.dart';
import 'package:lumiconte/services/reading_progress_service.dart';
import 'package:lumiconte/services/audio_background_service.dart';
import 'package:lumiconte/services/audio_notification_service.dart';

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
  bool _isProgressLoaded = false;

  B2Audio? _audio;
  late final String _uid;
  late final CollectionReference _settingsCollection;

  final ReadingProgressService _readingProgressService =
      ReadingProgressService();

  // Services pour l'audio en arrière-plan
  late AudioBackgroundService _audioBackgroundService;
  late AudioNotificationService _audioNotificationService;

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

    // Initialiser les services d'audio en arrière-plan
    _audioBackgroundService = AudioBackgroundService();
    _audioNotificationService = AudioNotificationService();
    _initializeBackgroundAudioService();

    _initializePages();
    _initializeAudio();

    _loadReadingProgress();
  }

  /// Initialiser le service d'audio en arrière-plan
  Future<void> _initializeBackgroundAudioService() async {
    try {
      // Initialiser le service audio
      await _audioBackgroundService.init();
      await _audioNotificationService.init();

      // Écouter l'état de lecture depuis le service
      _audioBackgroundService.playbackState.listen((playbackState) {
        if (mounted) {
          setState(() {
            _isPlaying = playbackState.playing;
            _audioPosition = playbackState.position;
          });
        }
      });
    } catch (e) {
      debugPrint('Erreur initialisation service audio: $e');
    }
  }

  Future<void> _loadReadingProgress() async {
    try {
      final progress = await _readingProgressService.getStoryProgress(
        profileId: widget.profile.id,
        storyId: widget.story.id,
      );

      if (progress != null) {
        setState(() {
          _currentPage = _calculatePageFromProgress(
            progress.progress,
          );
          _isProgressLoaded = true;
        });
      } else {
        await _updateReadingProgress(1);

        setState(() {
          _currentPage = 0;
          _isProgressLoaded = true;
        });
      }
    } catch (e) {
      debugPrint('Erreur chargement progression : $e');
      setState(() {
        _isProgressLoaded = true;
      });
    }
  }

  int _calculatePageFromProgress(int progress) {
    if (_pages.isEmpty) return 0;

    final totalCharacters = _pages.fold(
      0,
      (sum, page) => sum + page.length,
    );

    final targetCharacters = totalCharacters * progress / 100;

    int currentCharacters = 0;

    for (int i = 0; i < _pages.length; i++) {
      currentCharacters += _pages[i].length;

      if (currentCharacters >= targetCharacters) {
        return i;
      }
    }

    return _pages.length - 1;
  }

  int _calculateProgress() {
    if (_pages.isEmpty) return 0;

    if (_currentPage >= _pages.length - 1) {
      return 100;
    }

    final totalCharacters = _pages.fold(
      0,
      (sum, page) => sum + page.length,
    );

    if (totalCharacters == 0) return 0;

    int readCharacters = 0;
    for (int i = 0; i <= _currentPage; i++) {
      readCharacters += _pages[i].length;
    }

    final double percentage = (readCharacters / totalCharacters) * 100;

    return percentage.round().clamp(0, 99);
  }

  Future<void> _updateReadingProgress(int progress) async {
    try {
      await _readingProgressService.createOrUpdate(
        profileId: widget.profile.id,
        storyId: widget.story.id,
        progress: progress,
      );
    } catch (e) {
      debugPrint('Erreur update progress : $e');
    }
  }

  void _initializePages() {
    final rawText = widget.story.content
        .replaceAll(r'\n', '\n\n')
        .replaceAll(RegExp(r'[ \t]+'), ' ')
        .replaceAll(RegExp(r'«\s*'), '«\u00A0')
        .replaceAll(RegExp(r'\s*»'), '\u00A0»')
        .trim();

    _pages = _splitTextIntoPages(rawText);
  }

  List<String> _splitTextIntoPages(String text) {
    const int charsPerPage = 150;
    final sentences = text.split(RegExp(r'(?<=[.!?])\s+'));
    final pages = <String>[];
    String currentPage = '';

    for (var sentence in sentences) {
      final testPage =
          currentPage.isEmpty ? sentence : '$currentPage $sentence';

      // Si ajouter la phrase dépasse le seuil et qu'on a déjà du contenu dans la page
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

      _audio!.onComplete.listen((_) => _handleAudioComplete());
      _audio!.onPositionChanged.listen((position) {
        if (mounted && !_isSeeking) {
          setState(() => _audioPosition = position);
          // Mettre à jour la notification avec la position
          _updateAudioNotification();
        }
      });
      _audio!.onDurationChanged.listen((duration) {
        if (mounted) {
          setState(() => _audioDuration = duration);
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
        setState(() => _isSeeking = false);
        _updateAudioNotification();
      }
    } catch (e) {
      debugPrint('Erreur fin audio: $e');
      if (mounted) setState(() => _isSeeking = false);
    }
  }

  Future<void> _seekAudio(double value) async {
    setState(() => _isSeeking = true);
    try {
      await _audio?.seek(Duration(seconds: value.toInt()));
      if (mounted) {
        setState(() => _audioPosition = Duration(seconds: value.toInt()));
        _updateAudioNotification();
      }
    } catch (e) {
      debugPrint('Erreur seek: $e');
    } finally {
      if (mounted) setState(() => _isSeeking = false);
    }
  }

  Future<void> _toggleAudio() async {
    if (_isPlaying) {
      await _audio?.pause();
      setState(() => _isPlaying = false);
      _updateAudioNotification();
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
        setState(() => _isSeeking = false);
      }
    }

    setState(() => _isLoading = true);
    try {
      await _audio?.play();
      if (mounted) {
        setState(() => _isPlaying = true);
        _updateAudioNotification();
      }
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

  /// Mettre à jour la notification de lecture audio
  void _updateAudioNotification() {
    if (!_isAudio) return;

    final progress = _audioDuration.inSeconds > 0
        ? ((_audioPosition.inSeconds / _audioDuration.inSeconds) * 100)
            .toInt()
            .clamp(0, 100)
        : 0;

    _audioNotificationService.showPlaybackProgressNotification(
      title: widget.story.name,
      subtitle: _isPlaying ? 'En cours de lecture...' : 'En pause',
      isPlaying: _isPlaying,
      progress: progress,
      position: _audioPosition,
      duration: _audioDuration,
    );
  }

  // Algorithmes de texte / dyslexie (inchangé)
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

    final matchStart = RegExp(r'^[^a-zA-ZÀ-ÿ«»]+').firstMatch(word);
    final matchEnd = RegExp(r'[^a-zA-ZÀ-ÿ«»]+$').firstMatch(word);

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
        style: baseDysStyle.copyWith(color: i % 2 == 0 ? colorBlue : colorRed),
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

  dynamic _getThemeColors(SettingsModel settings) {
    if (settings.dyslexia) {
      return _ThemeColors(
        backgroundColor: Colors.white,
        textColor: const Color(0xFF2B261F),
        accentColor: const Color(0xFF7C3AED),
      );
    }
  }

  void _goToNextPage() {
    if (_currentPage < _pages.length - 1) {
      setState(() => _currentPage++);
      _updateReadingProgress(_calculateProgress());
    }
  }

  void _goToPreviousPage() {
    if (_currentPage > 0) {
      setState(() => _currentPage--);
      _updateReadingProgress(_calculateProgress());
    }
  }

  @override
  void dispose() {
    _audio?.dispose();
    // Masquer la notification quand on quitte la page
    _audioNotificationService.hideNotification();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isProgressLoaded) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    return StreamBuilder<QuerySnapshot>(
      stream: _settingsCollection.snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: const Center(child: CircularProgressIndicator()),
          );
        }
        final settingsDoc = snapshot.data!.docs.first;
        final settings = SettingsModel.fromMap(
          settingsDoc.data() as Map<String, dynamic>,
          settingsDoc.id,
        );

        final storyParams = StoryViewParams(
          currentPageText: _pages[_currentPage],
          currentPageIndex: _currentPage,
          totalPages: _pages.length,
          isFavorite: _isFavorite,
          isAudio: _isAudio,
          isPlaying: _isPlaying,
          isLoading: _isLoading,
          audioPosition: _audioPosition,
          audioDuration: _audioDuration,
          fontSize: settings.fontSize.toDouble(),
          isDyslexia: settings.dyslexia,
          image: widget.story.image,
          illustrationsPath: widget.story.illustrations,
          onBack: () => Navigator.pop(context),
          onToggleFavorite: () => setState(() => _isFavorite = !_isFavorite),
          onNextPage: _goToNextPage,
          onPreviousPage: _goToPreviousPage,
          onToggleAudio: _toggleAudio,
          onSeekAudio: _seekAudio,
          buildColorizedText: _buildColorizedText,
        );
        final bool isDarkTheme = settings.theme == 'dark';

        switch (settings.readTheme) {
          case 'immersive':
            return StoryImmersiveView(
                isDark: isDarkTheme,
                params: storyParams,
                profileId: widget.profile.id);
          case 'manuscript':
            return StoryManuscriptView(
                params: storyParams, profileId: widget.profile.id);
          case 'classic':
          default:
            return StoryClassicView(
                isDark: isDarkTheme,
                params: storyParams,
                profileId: widget.profile.id);
        }
      },
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