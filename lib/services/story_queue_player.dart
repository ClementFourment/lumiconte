import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart' show ProcessingState;
import 'package:lumiconte/models/app_language.dart';
import 'package:lumiconte/models/badge_model.dart';
import 'package:lumiconte/models/profile_model.dart';
import 'package:lumiconte/models/settings_model.dart';
import 'package:lumiconte/models/story_model.dart';
import 'package:lumiconte/services/audio_background_service.dart';
import 'package:lumiconte/services/badge_service.dart';
import 'package:lumiconte/services/reading_progress_service.dart';
import 'package:lumiconte/services/settings_service.dart';
import 'package:lumiconte/services/story_queue.dart';

/// Écoute de la file de lecture, indépendante de la page d'histoire : on peut
/// quitter la page, la file continue. Enchaîne les histoires, les marque
/// terminées et compte le temps d'écoute.
class StoryQueuePlayer extends ChangeNotifier {
  static final StoryQueuePlayer _instance = StoryQueuePlayer._internal();

  factory StoryQueuePlayer() => _instance;

  StoryQueuePlayer._internal();

  final StoryQueue _queue = StoryQueue();
  final AudioBackgroundService _audio = AudioBackgroundService();
  final ReadingProgressService _readingProgressService =
      ReadingProgressService();
  final SettingsService _settingsService = SettingsService();

  String? _uid;
  String? _profileId;
  AudioVoiceData? _currentVoice;
  final List<StreamSubscription> _subscriptions = [];

  /// Incrémenté à chaque chargement : un chargement dépassé ne lance rien.
  int _loadGeneration = 0;

  bool _firstListenAwarded = false;

  final Stopwatch _listening = Stopwatch();
  int _savedListeningSeconds = 0;
  Timer? _saveTimer;

  bool get isActive => _profileId != null && _queue.isPlaying;
  StoryModel? get currentStory => isActive ? _queue.current : null;
  bool get hasPrevious => isActive && _queue.hasPrevious;
  bool get hasNext => isActive && _queue.hasNext;

  /// Voix de l'histoire en cours, null tant que son audio n'est pas choisi.
  AudioVoiceData? get currentVoice => _currentVoice;

  StreamSubscription? _languageSubscription;
  String? _languageProfileId;

  /// Donne à la file et aux textes des histoires la langue du profil, et la
  /// suit quand un parent la change.
  void followLanguage(ProfileModel profile) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null || _languageProfileId == profile.id) return;
    _languageSubscription?.cancel();
    _languageProfileId = profile.id;
    _languageSubscription =
        _settingsService.getSettingsStream(uid, profile.id).listen(
              (settings) => applyLanguage(
                  settings?.language ?? SettingsModel.defaultLanguage),
              onError: (e) => debugPrint('Erreur langue de la file : $e'),
            );
  }

  /// Langue de lecture du profil : la file s'y conforme, et les histoires
  /// affichent leurs textes dans cette langue.
  void applyLanguage(String language) {
    AppLanguage.select(language);
    _queue.language = language;
  }

  /// Écoute la file préparée, depuis la première histoire.
  Future<void> start(ProfileModel profile) async {
    final first = _changeStory(_queue.start);
    if (first == null) return;
    await _activate(profile);
    await _load(first);
  }

  /// Écoute une histoire tout de suite (bouton lecture de la page d'histoire).
  /// [startAt] donne la position de départ à partir de la durée de l'audio.
  Future<void> playStory(
    ProfileModel profile,
    StoryModel story, {
    Duration Function(Duration duration)? startAt,
  }) async {
    if (!_queue.canQueue(story)) return;
    _changeStory(() => _queue.playNow(story));
    await _activate(profile);
    await _load(story, startAt: startAt);
  }

  Future<void> _activate(ProfileModel profile) async {
    if (_profileId == profile.id && _subscriptions.isNotEmpty) return;
    _detach();
    _uid = FirebaseAuth.instance.currentUser?.uid;
    _profileId = profile.id;

    await _audio.init();
    _audio.onSkipToPrevious = skipToPrevious;
    _audio.onSkipToNext = skipToNext;
    _updateQueueControls();
    _queue.addListener(_onQueueChanged);

    final player = _audio.audioPlayer;
    var previousState = player.processingState;
    _subscriptions.add(player.processingStateStream.listen((state) {
      if (state == ProcessingState.completed &&
          previousState != ProcessingState.completed) {
        _onStoryCompleted();
      }
      previousState = state;
    }));
    _subscriptions.add(player.playingStream.listen((playing) {
      playing ? _listening.start() : _listening.stop();
    }));
    _saveTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _saveListeningTime(),
    );

    notifyListeners();
  }

  /// Reprend l'histoire précédente depuis le début.
  Future<void> skipToPrevious() async {
    if (!isActive) return;
    final previous = _changeStory(_queue.previous);
    if (previous != null) await _load(previous);
  }

  /// Sans histoire suivante, ne fait rien : l'écoute ne doit pas s'arrêter
  /// sur un appui.
  Future<void> skipToNext() async {
    if (!isActive || !_queue.hasNext) return;
    await _advance();
  }

  /// Histoire suivante ; après la dernière, next() vide la file et
  /// _onQueueChanged termine l'écoute.
  Future<void> _advance() async {
    final next = _changeStory(_queue.next);
    if (next != null) await _load(next);
  }

  void _updateQueueControls() {
    _audio.setQueueControls(
      hasPrevious: _queue.hasPrevious,
      hasNext: _queue.hasNext,
    );
  }

  /// La voix de l'histoire précédente ne doit pas être prise pour celle de la
  /// nouvelle : elle est oubliée avant que la file prévienne les pages.
  T _changeStory<T>(T Function() change) {
    _currentVoice = null;
    return change();
  }

  /// Arrête l'écoute et vide la file.
  Future<void> stop() async {
    if (!isActive) return;
    _queue.clear();
    await _audio.stop();
  }

  Future<void> _load(
    StoryModel story, {
    Duration Function(Duration duration)? startAt,
  }) async {
    final generation = ++_loadGeneration;
    _currentVoice = null;
    notifyListeners();

    // Relu à chaque histoire : un changement de voix vaut pour la suivante
    final settings = await _settings();
    final voice = story.voiceFor(settings?.language, settings?.voiceGender);
    if (generation != _loadGeneration) return;
    if (voice == null) {
      await _advance();
      return;
    }
    _currentVoice = voice;
    notifyListeners();

    await _audio.setStory(story, voice.url.trim());
    if (generation != _loadGeneration) return;
    final position = startAt?.call(_audio.duration) ?? Duration.zero;
    if (position > Duration.zero) await _audio.seek(position);
    if (generation != _loadGeneration) return;
    unawaited(_audio.play());
    _awardFirstListen();
    _readingProgressService
        .ensureExists(profileId: _profileId!, storyId: story.id)
        .catchError((e) => debugPrint('Erreur progression : $e'));
  }

  Future<SettingsModel?> _settings() async {
    final uid = _uid;
    final profileId = _profileId;
    if (uid == null || profileId == null) return null;
    try {
      return await _settingsService.getSettings(uid, profileId);
    } catch (e) {
      debugPrint('Erreur paramètres de voix : $e');
      return null;
    }
  }

  void _onStoryCompleted() {
    final story = currentStory;
    final profileId = _profileId;
    if (story == null || profileId == null) return;

    _readingProgressService
        .markFinished(profileId: profileId, storyId: story.id)
        .catchError((e) => debugPrint('Erreur fin d\'histoire : $e'));
    _advance();
  }

  void _onQueueChanged() {
    if (_profileId == null) return;
    if (_queue.isPlaying) {
      _updateQueueControls();
      notifyListeners();
      return;
    }
    // File terminée ou vidée : l'audio s'arrête et la notification disparaît
    _detach();
    _audio.stop();
  }

  /// La première écoute n'est visible dans aucune donnée : le badge est
  /// enregistré directement, et fêté par le BadgeWatcher.
  void _awardFirstListen() {
    final uid = _uid;
    final profileId = _profileId;
    if (_firstListenAwarded || uid == null || profileId == null) return;
    _firstListenAwarded = true;
    BadgeService().award(uid, profileId, const [BadgeModel.firstListenId]);
  }

  void _detach() {
    if (_profileId == null) return;
    _saveListeningTime();
    _listening
      ..stop()
      ..reset();
    _savedListeningSeconds = 0;
    _saveTimer?.cancel();
    _saveTimer = null;
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear();
    _queue.removeListener(_onQueueChanged);
    if (_audio.onSkipToPrevious == skipToPrevious) {
      _audio.onSkipToPrevious = null;
    }
    if (_audio.onSkipToNext == skipToNext) _audio.onSkipToNext = null;
    _audio.setQueueControls(hasPrevious: false, hasNext: false);
    _loadGeneration++;
    _profileId = null;
    _currentVoice = null;
    notifyListeners();
  }

  void _saveListeningTime() {
    final uid = _uid;
    final profileId = _profileId;
    if (uid == null || profileId == null) return;
    final total = _listening.elapsed.inSeconds;
    final seconds = total - _savedListeningSeconds;
    if (seconds <= 0) return;
    _savedListeningSeconds = total;
    _settingsService
        .incrementTotalReadingTime(uid, profileId, seconds)
        .catchError((e) => debugPrint('Erreur temps d\'écoute : $e'));
  }
}
