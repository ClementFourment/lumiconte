import 'package:lumiconte/models/app_language.dart';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:lumiconte/models/story_model.dart';

/// Service pour gérer la lecture audio en arrière-plan
/// Permet la lecture continue même quand l'app est fermée ou l'écran verrouillé
class AudioBackgroundService extends BaseAudioHandler
    with QueueHandler, SeekHandler {
  static final AudioBackgroundService _instance =
      AudioBackgroundService._internal();

  factory AudioBackgroundService() {
    return _instance;
  }

  AudioBackgroundService._internal();

  late AudioPlayer _audioPlayer;
  bool _isInitialized = false;
  int? _lastPositionUpdate;
  static const String cdnBaseUrl = 'https://lumiconte-cdn.clementfourment.fr/';

  /// Histoires avant / après dans la file de lecture : boutons "précédent" et
  /// "suivant" affichés sur l'écran verrouillé et dans la notification.
  bool _hasPrevious = false;
  bool _hasNext = false;

  /// Appelés par les boutons "précédent" et "suivant" de la file.
  Future<void> Function()? onSkipToPrevious;
  Future<void> Function()? onSkipToNext;

  /// Boutons grisés qui ne font rien, affichés à la place de "précédent" ou
  /// "suivant" quand il n'y a pas d'histoire avant ou après. Ce sont des
  /// actions personnalisées : Android 13+ les place dans les emplacements
  /// laissés libres par "précédent" et "suivant", dans cet ordre.
  // Hors de l'arbre des widgets : les libellés suivent la langue du profil
  static MediaControl get _previousDisabled => MediaControl(
        androidIcon: 'drawable/ic_skip_previous_disabled',
        label: AppLanguage.texts.noPreviousStory,
        action: MediaAction.custom,
        customAction: const CustomMediaAction(name: 'previous_disabled'),
      );
  static MediaControl get _nextDisabled => MediaControl(
        androidIcon: 'drawable/ic_skip_next_disabled',
        label: AppLanguage.texts.noNextStory,
        action: MediaAction.custom,
        customAction: const CustomMediaAction(name: 'next_disabled'),
      );

  void setQueueControls({required bool hasPrevious, required bool hasNext}) {
    if (_hasPrevious == hasPrevious && _hasNext == hasNext) return;
    _hasPrevious = hasPrevious;
    _hasNext = hasNext;
    _updateState();
  }

  // Helper pour mettre à jour l'état avec les contrôles toujours présents
  void _updateState({
    bool? playing,
    AudioProcessingState? processingState,
    Duration? updatePosition,
    Duration? bufferedPosition,
  }) {
    final isPlaying = playing ?? playbackState.value.playing;
    // Pas de ±10 s : depuis Android 13, le système placerait ces boutons à la
    // place d'un "précédent" ou "suivant" absent. On avance ou recule avec la
    // barre de progression de la notification (action seek).
    final controls = [
      _hasPrevious ? MediaControl.skipToPrevious : _previousDisabled,
      isPlaying ? MediaControl.pause : MediaControl.play,
      _hasNext ? MediaControl.skipToNext : _nextDisabled,
    ];
    // Avant Android 13, les actions personnalisées ne sont pas dans la
    // notification : la vue réduite ne compte que les autres boutons
    final notificationButtons =
        controls.where((control) => control.customAction == null).length;

    playbackState.add(
      playbackState.value.copyWith(
        playing: isPlaying,
        processingState: processingState ?? playbackState.value.processingState,
        updatePosition: updatePosition ?? playbackState.value.updatePosition,
        bufferedPosition:
            bufferedPosition ?? playbackState.value.bufferedPosition,
        controls: controls,
        // Barre de progression déplaçable dans la notification et sur l'écran verrouillé
        systemActions: const {MediaAction.seek},
        androidCompactActionIndices: [
          for (var i = 0; i < notificationButtons; i++) i,
        ],
      ),
    );
  }

  Future<void> init() async {
    if (_isInitialized) return;

    _audioPlayer = AudioPlayer();

    // Écouter les changements de position
    _audioPlayer.positionStream.listen((position) {
      final now = DateTime.now().millisecondsSinceEpoch;
      if (_lastPositionUpdate == null || now - _lastPositionUpdate! > 500) {
        _lastPositionUpdate = now;
        _updateState(
            updatePosition: position,
            bufferedPosition: _audioPlayer.bufferedPosition);
      }
    });

    // Écouter les changements de durée
    _audioPlayer.durationStream.listen((duration) {
      if (duration != null) {
        final currentItem = mediaItem.value;
        debugPrint(currentItem.toString());
        if (currentItem != null) {
          mediaItem.add(currentItem.copyWith(duration: duration));
        }
        _updateState(
            updatePosition: _audioPlayer.position,
            bufferedPosition: _audioPlayer.bufferedPosition);
      }
    });

    // Écouter l'état de lecture
    _audioPlayer.playingStream.listen((isPlaying) {
      _updateState(
        playing: isPlaying,
        processingState: isPlaying
            ? AudioProcessingState.ready
            : playbackState.value.processingState,
      );
    });

    // Écouter l'état de traitement (loading, buffering, etc.)
    _audioPlayer.processingStateStream.listen((state) {
      _updateState(
        processingState: _mapProcessingState(state),
      );
    });

    // Initialiser l'état de lecture
    _updateState(processingState: AudioProcessingState.idle);

    _isInitialized = true;
  }

  AudioProcessingState _mapProcessingState(ProcessingState state) {
    switch (state) {
      case ProcessingState.idle:
        return AudioProcessingState.idle;
      case ProcessingState.loading:
        return AudioProcessingState.loading;
      case ProcessingState.buffering:
        return AudioProcessingState.buffering;
      case ProcessingState.ready:
        return AudioProcessingState.ready;
      case ProcessingState.completed:
        return AudioProcessingState.completed;
    }
  }

  /// Configurer l'audio pour une histoire spécifique
  Future<void> setStory(StoryModel story, String objectKey) async {
    if (!_isInitialized) await init();

    final url = '$cdnBaseUrl$objectKey';

    try {
      // 1. Charger l'URL
      await _audioPlayer.setUrl(url);

      // 2. ATTENTE CRITIQUE : On attend que la durée soit réellement disponible
      // Android désactive le curseur si la durée est nulle au moment du passage à "ready"
      int retryCount = 0;
      while (_audioPlayer.duration == null && retryCount < 15) {
        await Future.delayed(const Duration(milliseconds: 200));
        retryCount++;
      }
      final duration = _audioPlayer.duration;

      // 3. Envoyer le MediaItem COMPLET AVANT l'état "ready"
      mediaItem.add(MediaItem(
        id: story.id,
        album: 'Lumiconte',
        title: story.displayName,
        artUri: Uri.parse(story.image != null && story.image!.startsWith('http')
            ? story.image!
            : '$cdnBaseUrl${story.image ?? 'assets/default_story.webp'}'),
        duration: duration,
      ));

      // 4. Passer l'état à READY avec les contrôles
      _updateState(processingState: AudioProcessingState.ready);
    } catch (e) {
      debugPrint('Erreur chargement audio: $e');
      _updateState(processingState: AudioProcessingState.error);
    }
  }

  @override
  Future<void> play() async {
    try {
      _updateState(playing: true, processingState: AudioProcessingState.ready);
      await _audioPlayer.play();
    } catch (e) {
      debugPrint('Erreur play: $e');
      playbackState.add(
        playbackState.value.copyWith(
          processingState: AudioProcessingState.error,
        ),
      );
    }
  }

  @override
  Future<void> rewind() async {
    final newPosition = _audioPlayer.position - const Duration(seconds: 10);
    await seek(newPosition < Duration.zero ? Duration.zero : newPosition);
  }

  @override
  Future<void> fastForward() async {
    final newPosition = _audioPlayer.position + const Duration(seconds: 10);
    await seek(newPosition > _audioPlayer.duration!
        ? _audioPlayer.duration!
        : newPosition);
  }

  @override
  Future<void> skipToPrevious() async {
    await onSkipToPrevious?.call();
  }

  @override
  Future<void> skipToNext() async {
    await onSkipToNext?.call();
  }

  @override
  Future<void> pause() async {
    try {
      _updateState(playing: false);
      await _audioPlayer.pause();
    } catch (e) {
      debugPrint('Erreur pause: $e');
    }
  }

  @override
  Future<void> seek(Duration position) async {
    try {
      // 1. On demande au lecteur de changer de position
      await _audioPlayer.seek(position);

      // 2. On force la mise à jour immédiate de l'état pour la notification
      // On utilise updatePosition pour notifier le système nativement
      playbackState.add(
        playbackState.value.copyWith(
          updatePosition: position,
        ),
      );
    } catch (e) {
      debugPrint('Erreur seek: $e');
    }
  }

  @override
  Future<void> stop() async {
    try {
      await _audioPlayer.stop();
      playbackState.add(
        playbackState.value.copyWith(
          playing: false,
          processingState: AudioProcessingState.idle,
        ),
      );
    } catch (e) {
      debugPrint('Erreur stop: $e');
    }
  }

  /// Obtenir le lecteur audio pour accéder à des propriétés
  AudioPlayer get audioPlayer => _audioPlayer;

  /// Vérifier si l'audio est en cours de lecture
  bool get isPlaying => _audioPlayer.playing;

  /// Obtenir la position actuelle
  Duration get position => _audioPlayer.position;

  /// Obtenir la durée totale
  Duration get duration => _audioPlayer.duration ?? Duration.zero;

  /// Durées déjà connues, par chemin du fichier audio.
  static final Map<String, Duration> _durations = {};
  static final Map<String, Future<Duration?>> _pendingDurations = {};

  /// Durée d'un audio sans le lire, pour l'afficher avant la lecture.
  static Future<Duration?> durationOf(String objectKey) {
    final key = objectKey.trim();
    if (key.isEmpty) return Future.value(null);
    final known = _durations[key];
    if (known != null) return Future.value(known);
    return _pendingDurations[key] ??= _probeDuration(key).whenComplete(() {
      _pendingDurations.remove(key);
    });
  }

  /// Un lecteur à part lit l'en-tête du fichier : l'écoute en cours n'est pas
  /// interrompue et la session audio n'est pas réclamée.
  static Future<Duration?> _probeDuration(String key) async {
    final player = AudioPlayer(
      handleAudioSessionActivation: false,
      handleInterruptions: false,
    );
    try {
      final duration = await player.setUrl('$cdnBaseUrl$key');
      if (duration != null) _durations[key] = duration;
      return duration;
    } catch (e) {
      debugPrint('Durée de $key : $e');
      return null;
    } finally {
      await player.dispose();
    }
  }

  /// Fermer le service
  Future<void> dispose() async {
    await _audioPlayer.dispose();
  }
}
