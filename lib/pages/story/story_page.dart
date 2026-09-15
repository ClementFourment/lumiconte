import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:audio_service/audio_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:lumiconte/widget/b2_image.dart';
import 'package:lumiconte/models/badge_model.dart';
import 'package:lumiconte/models/profile_model.dart';
import 'package:lumiconte/models/story_model.dart';
import 'package:lumiconte/models/settings_model.dart';
import 'package:lumiconte/pages/story/story_classic_view.dart';
import 'package:lumiconte/pages/story/story_immersive_view.dart';
import 'package:lumiconte/pages/story/story_manuscript_view.dart';
import 'package:lumiconte/pages/story/story_text.dart';
import 'package:lumiconte/pages/story/story_view_params.dart';
import 'package:lumiconte/services/badge_service.dart';
import 'package:lumiconte/services/reading_progress_service.dart';
import 'package:lumiconte/services/settings_service.dart';
import 'package:lumiconte/services/audio_background_service.dart';
import 'package:lumiconte/services/story_sync_service.dart';

class StoryPage extends StatefulWidget {
  final StoryModel story;
  final ProfileModel profile;

  const StoryPage({super.key, required this.story, required this.profile});

  @override
  State<StoryPage> createState() => _StoryPageState();
}

class _StoryPageState extends State<StoryPage> {
  late StoryDocument _document;

  /// Premier mot de la page courante. On retient un mot plutôt qu'un numéro de
  /// page, car la pagination change avec la police et la taille de l'écran.
  int _anchorWord = 0;
  StoryPagination? _pagination;
  StoryLayoutRequest? _paginationRequest;

  bool _isFavorite = false;
  bool _isPlaying = false;
  bool _isLoading = false;
  bool _isSeeking = false;
  bool _isAudio = false;
  bool _isAudioInitialized = false;
  String? _currentVoiceKey;
  Duration _audioPosition = Duration.zero;
  Duration _audioDuration = Duration.zero;
  bool _isProgressLoaded = false;

  late final String _uid;
  late final CollectionReference _settingsCollection;
  // Créé une seule fois : un nouvel abonnement à chaque build relançait des rebuilds complets
  late final Stream<QuerySnapshot> _settingsStream;
  late final CollectionReference _favoritesCollection;

  final ReadingProgressService _readingProgressService =
      ReadingProgressService();
  late AudioBackgroundService _audioBackgroundService;

  final SettingsService _settingsService = SettingsService();
  final Stopwatch _readingTimer = Stopwatch();
  Timer? _readingSaveTimer;
  int _savedReadingSeconds = 0;

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
    _settingsStream = _settingsCollection.snapshots();
    // Sans document de paramètres, l'écran resterait bloqué sur le chargement
    _settingsService
        .ensureDefaultSettings(_uid, widget.profile.id)
        .catchError((e) => debugPrint('Paramètres du profil : $e'));

    _favoritesCollection = FirebaseFirestore.instance
        .collection('users')
        .doc(_uid)
        .collection('profiles')
        .doc(widget.profile.id)
        .collection('favorites');

    _audioBackgroundService = AudioBackgroundService();
    _initializeBackgroundAudioService();

    _document = StoryDocument(storyWordsFromText(widget.story.content));
    // Une police chargée après coup (Google Fonts) change les mesures du texte
    PaintingBinding.instance.systemFonts.addListener(_onSystemFontsChanged);
    _loadReadingProgress();
    _loadFavoriteStatus();

    _readingTimer.start();
    _readingSaveTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _saveReadingTime(),
    );
  }

  Future<void> _saveReadingTime() async {
    final totalSeconds = _readingTimer.elapsed.inSeconds;
    final secondsToSave = totalSeconds - _savedReadingSeconds;

    if (secondsToSave <= 0) return;

    try {
      await _settingsService.incrementTotalReadingTime(
        _uid,
        widget.profile.id,
        secondsToSave,
      );

      _savedReadingSeconds = totalSeconds;
    } catch (e) {
      debugPrint('Erreur sauvegarde temps de lecture : $e');
    }
  }

  Future<void> _loadFavoriteStatus() async {
    try {
      final doc = await _favoritesCollection.doc(widget.story.id).get();
      if (mounted) {
        setState(() {
          _isFavorite = doc.exists;
        });
      }
    } catch (e) {
      debugPrint('Erreur chargement favori : $e');
    }
  }

  Future<void> _initializeBackgroundAudioService() async {
    try {
      await _audioBackgroundService.init();

      _audioBackgroundService.playbackState.listen((playbackState) {
        // play() ne se termine qu'à la fin ou à la pause : le badge est
        // attribué dès que la lecture démarre réellement
        if (playbackState.playing) _awardFirstListen();
        if (mounted) {
          setState(() {
            _isPlaying = playbackState.playing;
            _isLoading = playbackState.processingState == AudioProcessingState.loading ||
                playbackState.processingState == AudioProcessingState.buffering;
          });
        }
      });

      _audioBackgroundService.audioPlayer.positionStream.listen((position) {
        if (mounted && !_isSeeking) {
          setState(() {
            _audioPosition = position;
          });
          _checkPageChangeForAudio(_audioPosition);
        }
      });

      _audioBackgroundService.audioPlayer.durationStream.listen((duration) {
        if (mounted) {
          setState(() {
            _audioDuration = duration ?? Duration.zero;
          });
        }
      });
    } catch (e) {
      debugPrint('Erreur initialisation service audio: $e');
    }
  }

  void _onSystemFontsChanged() {
    if (!mounted) return;
    clearStoryTextCaches();
    setState(() {
      _pagination = null;
      _paginationRequest = null;
    });
  }

  int get _currentPageIndex => _pagination?.pageOfWord(_anchorWord) ?? 0;

  StoryPagination _paginate(StoryLayoutRequest request) {
    final previous = _pagination;
    if (previous != null && request == _paginationRequest) return previous;

    final next = paginateStory(_document, request);
    _pagination = next;
    _paginationRequest = request;

    // Appelé pendant la mise en page : le compteur et les flèches se mettent
    // à jour à la frame suivante
    if (previous == null || !previous.hasSameBreaks(next)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() {});
      });
    }
    return next;
  }

  void _replaceDocument(StoryDocument document) {
    final readFraction = _document.fractionBefore(_anchorWord);
    _document = document;
    _anchorWord = document.wordStartingAt(readFraction);
    _pagination = null;
    _paginationRequest = null;
  }

  void _checkPageChangeForAudio(Duration position) {
    final pagination = _pagination;
    if (pagination == null || !_isPlaying) return;

    final spokenWord =
        _document.wordAtTime(position.inMilliseconds / 1000.0);
    if (spokenWord == null) return;

    final targetPage = pagination.pageOfWord(spokenWord);
    if (targetPage != _currentPageIndex) {
      setState(() => _anchorWord = pagination.pages[targetPage].start);
      _precacheIllustration(targetPage + 1);
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
          _anchorWord = _document.lastWordReadAt(progress.progress / 100);
          _isProgressLoaded = true;
        });
      } else {
        await _updateReadingProgress(1.0);
        setState(() {
          _anchorWord = 0;
          _isProgressLoaded = true;
        });
      }
    } catch (e) {
      debugPrint('Erreur chargement progression : $e');
      setState(() => _isProgressLoaded = true);
    }
  }

  double _calculateProgress() {
    final pagination = _pagination;
    if (pagination == null || _document.isEmpty) return 0.0;

    final pageIndex = _currentPageIndex;
    if (pageIndex >= pagination.pages.length - 1) return 100.0;

    final readFraction =
        _document.fractionBefore(pagination.pages[pageIndex].end);
    return (readFraction * 100).clamp(0.0, 100.0);
  }

  Future<void> _updateReadingProgress(double progress) async {
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

  String? _getCalculatedImageUrl([int? pageIndex]) {
    final illustrationsPath = widget.story.illustrations;

    if (illustrationsPath != null && illustrationsPath.isNotEmpty) {
      final pagination = _pagination;
      final int pageEnd;
      if (pagination == null) {
        pageEnd = _anchorWord + 1;
      } else {
        final index = (pageIndex ?? _currentPageIndex)
            .clamp(0, pagination.pages.length - 1);
        pageEnd = pagination.pages[index].end;
      }

      final imageNumber = _document.imageNumberBefore(pageEnd);
      if (imageNumber != null) {
        return '$illustrationsPath/img$imageNumber.webp';
      }
    }

    return widget.story.image;
  }

  Future<void> _initializeAudio(SettingsModel settings) async {
    final requestedVoiceKey =
        (settings.voiceGender == 'homme' || settings.voiceGender == 'male')
            ? 'homme'
            : 'femme';

    if (_isAudioInitialized && _currentVoiceKey == requestedVoiceKey) {
      return;
    }

    final audioMap = widget.story.audio;
    if (audioMap == null || audioMap.isEmpty) {
      _isAudio = false;
      _isAudioInitialized = true;
      return;
    }

    String targetKey = requestedVoiceKey;
    AudioVoiceData? voiceData = audioMap[targetKey];

    if (voiceData == null || voiceData.url.trim().isEmpty) {
      final alternateKey = targetKey == 'homme' ? 'femme' : 'homme';
      if (audioMap.containsKey(alternateKey) &&
          audioMap[alternateKey]!.url.trim().isNotEmpty) {
        targetKey = alternateKey;
        voiceData = audioMap[targetKey];
      }
    }

    final selectedAudioPath = voiceData?.url.trim() ?? '';
    _isAudio = selectedAudioPath.isNotEmpty;
    _isAudioInitialized = true;
    _currentVoiceKey = targetKey;

    if (_isAudio && voiceData != null) {
      // Avec l'audio, on affiche les mots minutés de la voix pour pouvoir les surligner
      final audioWords = storyWordsFromSegments(
        StorySyncService.parseSegments(voiceData.audioTimes),
      );

      final documentReady = Completer<void>();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _replaceDocument(StoryDocument(audioWords.isNotEmpty
                ? audioWords
                : storyWordsFromText(widget.story.content)));
            // Remet l'état audio à jour lors d'une réinitialisation de voix
            _isPlaying = false;
            _audioPosition = Duration.zero;
          });
        }
        documentReady.complete();
      });

      await Future.wait([
        _audioBackgroundService.setStory(widget.story, selectedAudioPath),
        documentReady.future,
      ]);
      await _seekAudioToCurrentPage();
    }
  }

  /// Place l'audio au début de la page affichée (reprise de lecture, changement de voix).
  Future<void> _seekAudioToCurrentPage() async {
    // La pagination est recalculée pendant la mise en page qui suit le changement de document
    if (mounted && _pagination == null) {
      await WidgetsBinding.instance.endOfFrame;
    }
    if (!mounted) return;
    final pagination = _pagination;
    final pageStart = pagination == null
        ? _anchorWord
        : pagination.pages[_currentPageIndex].start;
    if (pageStart <= 0) return;

    final Duration position;
    final wordStart = _document.words[pageStart].start;
    if (wordStart != null) {
      position = Duration(milliseconds: (wordStart * 1000).round());
    } else if (_audioDuration > Duration.zero) {
      // Sans minutage, on se place au prorata du texte déjà lu
      position = _audioDuration * _document.fractionBefore(pageStart);
    } else {
      return;
    }

    setState(() {
      _isSeeking = true;
      _audioPosition = position;
    });
    try {
      await _audioBackgroundService.seek(position);
    } finally {
      if (mounted) setState(() => _isSeeking = false);
    }
  }

  void _onSeekAudioChanged(double value) {
    setState(() {
      _isSeeking = true;
      _audioPosition = Duration(seconds: value.toInt());
    });
  }

  Future<void> _seekAudio(double value) async {
    setState(() => _isSeeking = true);
    try {
      await _audioBackgroundService.seek(Duration(seconds: value.toInt()));
      if (mounted) {
        setState(() => _audioPosition = Duration(seconds: value.toInt()));
      }
    } catch (e) {
      debugPrint('Erreur seek: $e');
    } finally {
      if (mounted) setState(() => _isSeeking = false);
    }
  }

  void _onRewind() {
    _audioBackgroundService.rewind();
  }

  void _onFastForward() {
    _audioBackgroundService.fastForward();
  }

  Future<void> _toggleAudio() async {
    if (_isPlaying) {
      await _audioBackgroundService.pause();
      return;
    }

    if (_audioPosition >= _audioDuration && _audioDuration > Duration.zero) {
      setState(() => _isSeeking = true);
      try {
        await _audioBackgroundService.seek(Duration.zero);
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
      await _audioBackgroundService.play();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur audio: $e')),
        );
      }
    }
    // _isLoading and _isPlaying are updated via the playbackState stream
  }

  bool _firstListenAwarded = false;

  /// La première écoute n'est visible dans aucune donnée : le badge est
  /// enregistré directement, et fêté par le BadgeWatcher.
  void _awardFirstListen() {
    if (_firstListenAwarded) return;
    _firstListenAwarded = true;
    BadgeService()
        .award(_uid, widget.profile.id, const [BadgeModel.firstListenId]);
  }

  void _goToNextPage() {
    final pagination = _pagination;
    if (pagination == null) return;
    final pageIndex = _currentPageIndex;
    if (pageIndex < pagination.pages.length - 1) {
      setState(() => _anchorWord = pagination.pages[pageIndex + 1].start);
      _updateReadingProgress(_calculateProgress());
      _precacheIllustration(pageIndex + 2);
    }
  }

  // Charge à l'avance l'illustration d'une page pour qu'elle s'affiche sans attente
  void _precacheIllustration(int pageIndex) {
    final pagination = _pagination;
    if (pagination == null || pageIndex >= pagination.pages.length) return;
    final imageKey = _getCalculatedImageUrl(pageIndex);
    if (imageKey == null || imageKey.isEmpty) return;
    precacheImage(
      CachedNetworkImageProvider(B2Image.urlFor(imageKey)),
      context,
      onError: (_, __) {},
    );
  }

  Future<void> _restartStory() async {
    if (_currentPageIndex == 0 && _audioPosition == Duration.zero) return;

    // _isSeeking empêche la synchro audio de ramener la page d'avant pendant le seek
    setState(() {
      _isSeeking = _isAudio;
      _anchorWord = 0;
      _audioPosition = Duration.zero;
    });
    _updateReadingProgress(_calculateProgress());
    _precacheIllustration(1);

    if (!_isAudio) return;
    try {
      await _audioBackgroundService.seek(Duration.zero);
    } finally {
      if (mounted) setState(() => _isSeeking = false);
    }
  }

  void _goToPreviousPage() {
    final pagination = _pagination;
    if (pagination == null) return;
    final pageIndex = _currentPageIndex;
    if (pageIndex > 0) {
      setState(() => _anchorWord = pagination.pages[pageIndex - 1].start);
      _updateReadingProgress(_calculateProgress());
    }
  }

  Future<void> _toggleFavorite() async {
    final newState = !_isFavorite;
    setState(() => _isFavorite = newState);

    try {
      final docRef = _favoritesCollection.doc(widget.story.id);
      if (newState) {
        await docRef.set({
          'storyId': widget.story.id,
          'addedAt': FieldValue.serverTimestamp(),
        });
      } else {
        await docRef.delete();
      }
    } catch (e) {
      debugPrint('Erreur modification favori : $e');
      if (mounted) {
        setState(() => _isFavorite = !newState);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Erreur lors de la mise à jour des favoris')),
        );
      }
    }
  }

  bool _readingRegistered = false;

  Future<void> _registerReading(SettingsModel settings) async {
    if (_readingRegistered) return;

    _readingRegistered = true;

    try {
      await _settingsService.registerReading(
        _uid,
        widget.profile.id,
        // Toujours `default` : écrire sur un ancien identifiant le recréerait
        // juste après sa migration
        settings,
      );
    } catch (e) {
      _readingRegistered = false;
      debugPrint('Erreur enregistrement lecture : $e');
    }
  }

  @override
  void dispose() {
    PaintingBinding.instance.systemFonts.removeListener(_onSystemFontsChanged);
    _audioBackgroundService.stop();
    _readingSaveTimer?.cancel();
    _readingTimer.stop();
    _saveReadingTime();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isProgressLoaded) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return StreamBuilder<QuerySnapshot>(
      stream: _settingsStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Scaffold(
            backgroundColor: Colors.white,
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final settingsDoc = snapshot.data!.docs.first;
        final settings = SettingsModel.fromMap(
          settingsDoc.data() as Map<String, dynamic>,
          settingsDoc.id,
        );

        _registerReading(settings);
        _initializeAudio(settings);

        final storyParams = StoryViewParams(
          document: _document,
          anchorWord: _anchorWord,
          paginate: _paginate,
          currentPageIndex: _currentPageIndex,
          totalPages: _pagination?.pages.length ?? 1,
          isFavorite: _isFavorite,
          isAudio: _isAudio,
          isPlaying: _isPlaying,
          isLoading: _isLoading,
          audioPosition: _audioPosition,
          audioDuration: _audioDuration,
          fontSize: settings.fontSize.toDouble(),
          isDyslexia: settings.dyslexia,
          image: _getCalculatedImageUrl(),
          cover: widget.story.image,
          onBack: () => Navigator.pop(context),
          onToggleFavorite: () => _toggleFavorite(),
          onRestart: _restartStory,
          onNextPage: _goToNextPage,
          onPreviousPage: _goToPreviousPage,
          onToggleAudio: _toggleAudio,
          onSeekAudioChanged: _onSeekAudioChanged,
          onSeekAudio: _seekAudio,
          onRewind: _onRewind,
          onFastForward: _onFastForward,
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
