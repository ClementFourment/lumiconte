import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:audio_service/audio_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:lumiconte/widget/b2_image.dart';
import 'package:lumiconte/models/profile_model.dart';
import 'package:lumiconte/models/story_model.dart';
import 'package:lumiconte/models/settings_model.dart';
import 'package:lumiconte/pages/story/story_classic_view.dart';
import 'package:lumiconte/pages/story/story_immersive_view.dart';
import 'package:lumiconte/pages/story/story_manuscript_view.dart';
import 'package:lumiconte/pages/story/story_text.dart';
import 'package:lumiconte/pages/story/story_view_params.dart';
import 'package:lumiconte/services/reading_progress_service.dart';
import 'package:lumiconte/services/settings_service.dart';
import 'package:lumiconte/services/audio_background_service.dart';
import 'package:lumiconte/services/story_queue.dart';
import 'package:lumiconte/services/story_queue_player.dart';
import 'package:lumiconte/services/story_sync_service.dart';

/// Page de lecture d'une histoire. L'audio passe toujours par la file de
/// lecture ([StoryQueuePlayer]) : le bouton lecture crée une file d'une
/// histoire, qui continue quand on quitte la page.
class StoryPage extends StatefulWidget {
  final StoryModel story;
  final ProfileModel profile;

  const StoryPage({super.key, required this.story, required this.profile});

  @override
  State<StoryPage> createState() => _StoryPageState();
}

class _StoryPageState extends State<StoryPage> {
  /// Histoire affichée : suit la file quand elle passe à la suivante.
  late StoryModel _story;
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
  Duration _audioPosition = Duration.zero;
  Duration _audioDuration = Duration.zero;
  bool _isProgressLoaded = false;

  /// Voix dont les mots minutés sont affichés.
  AudioVoiceData? _voice;

  /// La page suit la file : elle affiche l'histoire en cours d'écoute et passe
  /// à la suivante avec elle.
  bool _followsQueue = false;

  late final String _uid;
  late final CollectionReference _settingsCollection;
  // Créé une seule fois : un nouvel abonnement à chaque build relançait des rebuilds complets
  late final Stream<QuerySnapshot> _settingsStream;
  late final CollectionReference _favoritesCollection;

  final ReadingProgressService _readingProgressService =
      ReadingProgressService();
  final AudioBackgroundService _audioBackgroundService =
      AudioBackgroundService();
  final List<StreamSubscription> _audioSubscriptions = [];
  final StoryQueue _queue = StoryQueue();
  final StoryQueuePlayer _queuePlayer = StoryQueuePlayer();

  final SettingsService _settingsService = SettingsService();
  final Stopwatch _readingTimer = Stopwatch();
  Timer? _readingSaveTimer;
  int _savedReadingSeconds = 0;

  /// L'histoire affichée est celle qu'on écoute.
  bool get _isCurrent => _queuePlayer.currentStory?.id == _story.id;

  @override
  void initState() {
    super.initState();
    _story = widget.story;
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

    // Rouverte depuis le mini-lecteur : la page reprend l'écoute en cours
    _followsQueue = _isCurrent;
    if (_followsQueue) {
      _isAudio = true;
      _voice = _queuePlayer.currentVoice;
    }
    _document = _documentFor(_story, _voice);

    _queue.addListener(_onQueueChanged);
    _queuePlayer.addListener(_onQueueChanged);
    _listenToAudio();

    // Une police chargée après coup (Google Fonts) change les mesures du texte
    PaintingBinding.instance.systemFonts.addListener(_onSystemFontsChanged);
    _loadReadingProgress();
    _loadFavoriteStatus();

    _updateReadingTimer();
    _readingSaveTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _saveReadingTime(),
    );
  }

  /// Le temps passé sur la page compte comme lecture, sauf pendant l'écoute :
  /// StoryQueuePlayer compte déjà ce temps.
  void _updateReadingTimer() {
    if (_isCurrent && _isPlaying) {
      _readingTimer.stop();
    } else {
      _readingTimer.start();
    }
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
    final storyId = _story.id;
    try {
      final doc = await _favoritesCollection.doc(storyId).get();
      if (mounted && storyId == _story.id) {
        setState(() {
          _isFavorite = doc.exists;
        });
      }
    } catch (e) {
      debugPrint('Erreur chargement favori : $e');
    }
  }

  /// L'état du lecteur n'est affiché que si l'histoire de la page est celle
  /// qu'on écoute.
  Future<void> _listenToAudio() async {
    try {
      await _audioBackgroundService.init();
      if (!mounted) return;
      final player = _audioBackgroundService.audioPlayer;

      _audioSubscriptions
          .add(_audioBackgroundService.playbackState.listen((playbackState) {
        if (!mounted || !_isCurrent) return;
        setState(() {
          _isPlaying = playbackState.playing;
          _isLoading = playbackState.processingState ==
                  AudioProcessingState.loading ||
              playbackState.processingState == AudioProcessingState.buffering;
        });
        _updateReadingTimer();
      }));

      _audioSubscriptions.add(player.positionStream.listen((position) {
        if (!mounted || _isSeeking || !_isCurrent) return;
        setState(() => _audioPosition = position);
        _checkPageChangeForAudio(position);
      }));

      _audioSubscriptions.add(player.durationStream.listen((duration) {
        if (!mounted || !_isCurrent) return;
        setState(() => _audioDuration = duration ?? Duration.zero);
      }));
    } catch (e) {
      debugPrint('Erreur initialisation service audio: $e');
    }
  }

  void _onQueueChanged() {
    if (!mounted) return;
    final previousStoryId = _story.id;
    setState(_applyQueueState);
    if (_story.id != previousStoryId) _loadFavoriteStatus();
    _updateReadingTimer();
  }

  /// Aligne la page sur la file. Une page qui suit la file passe à l'histoire
  /// suivante avec elle ; à la fin de la file, la dernière histoire reste affichée.
  void _applyQueueState() {
    final current = _queuePlayer.currentStory;
    if (current == null || (current.id != _story.id && !_followsQueue)) {
      _followsQueue = false;
      _resetAudioState();
      return;
    }

    final voice = _queuePlayer.currentVoice;
    if (current.id != _story.id) {
      _story = current;
      _isFavorite = false;
      _anchorWord = 0;
      _resetAudioState();
      _voice = voice;
      _replaceDocument(_documentFor(current, voice));
    } else if (voice != null && !identical(voice, _voice)) {
      _voice = voice;
      _replaceDocument(_documentFor(current, voice));
    }
    _followsQueue = true;
    _isAudio = true;
  }

  void _resetAudioState() {
    _isPlaying = false;
    _isLoading = false;
    _audioPosition = Duration.zero;
    _audioDuration = Duration.zero;
  }

  /// Avec l'audio, on affiche les mots minutés de la voix pour pouvoir les surligner.
  StoryDocument _documentFor(StoryModel story, AudioVoiceData? voice) {
    if (voice != null) {
      final audioWords = storyWordsFromSegments(
        StorySyncService.parseSegments(voice.audioTimes),
      );
      if (audioWords.isNotEmpty) return StoryDocument(audioWords);
    }
    return StoryDocument(storyWordsFromText(story.content));
  }

  /// Voix choisie dans les paramètres. Pendant l'écoute, c'est la voix jouée
  /// qui compte : un changement de voix vaut pour la prochaine écoute.
  void _applySettingsVoice(SettingsModel settings) {
    if (_isCurrent) return;
    final voice = _story.voiceFor(settings.voiceGender);
    _isAudio = voice != null;
    if (identical(voice, _voice)) return;
    _voice = voice;

    // Appelé pendant le build : le document est remplacé après la frame
    final story = _story;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _story.id != story.id || !identical(_voice, voice)) {
        return;
      }
      setState(() => _replaceDocument(_documentFor(story, voice)));
    });
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

    final spokenWord = _document.wordAtTime(position.inMilliseconds / 1000.0);
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
        storyId: _story.id,
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
        storyId: _story.id,
        progress: progress,
      );
    } catch (e) {
      debugPrint('Erreur update progress : $e');
    }
  }

  String? _getCalculatedImageUrl([int? pageIndex]) {
    final illustrationsPath = _story.illustrations;

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

    return _story.image;
  }

  /// Lance l'écoute de l'histoire affichée, depuis le début de la page affichée.
  Future<void> _startListening() async {
    final pagination = _pagination;
    final pageStart = pagination == null
        ? _anchorWord
        : pagination.pages[_currentPageIndex].start;
    final wordStart = pageStart > 0 ? _document.words[pageStart].start : null;
    final readFraction = _document.fractionBefore(pageStart);

    setState(() {
      _followsQueue = true;
      _resetAudioState();
      _isLoading = true;
    });
    await _queuePlayer.playStory(
      widget.profile,
      _story,
      startAt: pageStart <= 0
          ? null
          : (duration) => wordStart != null
              ? Duration(milliseconds: (wordStart * 1000).round())
              // Sans minutage, on se place au prorata du texte déjà lu
              : duration * readFraction,
    );
  }

  void _onSeekAudioChanged(double value) {
    if (!_isCurrent) return;
    setState(() {
      _isSeeking = true;
      _audioPosition = Duration(seconds: value.toInt());
    });
  }

  Future<void> _seekAudio(double value) async {
    if (!_isCurrent) return;
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
    if (_isCurrent) _audioBackgroundService.rewind();
  }

  void _onFastForward() {
    if (_isCurrent) _audioBackgroundService.fastForward();
  }

  Future<void> _toggleAudio() async {
    if (!_isCurrent) {
      await _startListening();
      return;
    }

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

  void _toggleQueue() {
    if (_queue.contains(_story.id)) {
      _queue.remove(_story.id);
    } else if (!_queue.add(_story)) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(
          content: Text(
              'La file est pleine : ${StoryQueue.maxLength} histoires maximum'),
        ));
    }
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
    final seekAudio = _isCurrent;

    // _isSeeking empêche la synchro audio de ramener la page d'avant pendant le seek
    setState(() {
      _isSeeking = seekAudio;
      _anchorWord = 0;
      _audioPosition = Duration.zero;
    });
    _updateReadingProgress(_calculateProgress());
    _precacheIllustration(1);

    if (!seekAudio) return;
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
      final storyId = _story.id;
      final docRef = _favoritesCollection.doc(storyId);
      if (newState) {
        await docRef.set({
          'storyId': storyId,
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
    // L'écoute continue quand on quitte la page : le mini-lecteur prend le relais
    for (final subscription in _audioSubscriptions) {
      subscription.cancel();
    }
    _queue.removeListener(_onQueueChanged);
    _queuePlayer.removeListener(_onQueueChanged);
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
        _applySettingsVoice(settings);

        final isCurrent = _isCurrent;
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
          cover: _story.image,
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
          onSkipToPrevious: isCurrent && _queuePlayer.hasPrevious
              ? () => _queuePlayer.skipToPrevious()
              : null,
          onSkipToNext: isCurrent && _queuePlayer.hasNext
              ? () => _queuePlayer.skipToNext()
              : null,
          // Pas de "+" pour l'histoire qu'on écoute déjà
          isInQueue: StoryQueue.canQueue(_story) && !isCurrent
              ? _queue.contains(_story.id)
              : null,
          onToggleQueue: _toggleQueue,
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
