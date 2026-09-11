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
  static const String _cdnBaseUrl = 'https://lumiconte-cdn.clementfourment.fr/';

  // Helper pour mettre à jour l'état avec les contrôles toujours présents
  void _updateState({
    bool? playing,
    AudioProcessingState? processingState,
    Duration? updatePosition,
    Duration? bufferedPosition,
  }) {
    playbackState.add(
      playbackState.value.copyWith(
        playing: playing ?? playbackState.value.playing,
        processingState: processingState ?? playbackState.value.processingState,
        updatePosition: updatePosition ?? playbackState.value.updatePosition,
        bufferedPosition:
            bufferedPosition ?? playbackState.value.bufferedPosition,
        controls: [
          MediaControl.rewind,
          MediaControl.play,
          MediaControl.pause,
          MediaControl.fastForward,
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

    // Initialiser l'état de lecture
    _updateState(processingState: AudioProcessingState.idle);

    _isInitialized = true;
  }

  /// Configurer l'audio pour une histoire spécifique
  Future<void> setStory(StoryModel story, String objectKey) async {
    if (!_isInitialized) await init();

    final url = '$_cdnBaseUrl$objectKey';

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
        title: story.name,
        artUri: Uri.parse(story.image != null && story.image!.startsWith('http')
            ? story.image!
            : '$_cdnBaseUrl${story.image ?? 'assets/default_story.webp'}'),
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
      playbackState.add(
        playbackState.value.copyWith(
          playing: true,
          processingState: AudioProcessingState.ready,
        ),
      );
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
  Future<void> pause() async {
    try {
      playbackState.add(
        playbackState.value.copyWith(
          playing: false,
        ),
      );
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

  /// Fermer le service
  Future<void> dispose() async {
    await _audioPlayer.dispose();
  }
}
