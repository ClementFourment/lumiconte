import 'package:audio_service/audio_service.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:lumiconte/models/story_model.dart';

/// Service pour gérer la lecture audio en arrière-plan
/// Permet la lecture continue même quand l'app est fermée ou l'écran verrouillé
class AudioBackgroundService extends BaseAudioHandler with QueueHandler, SeekHandler {
  static final AudioBackgroundService _instance = AudioBackgroundService._internal();

  factory AudioBackgroundService() {
    return _instance;
  }

  AudioBackgroundService._internal();

  late AudioPlayer _audioPlayer;
  bool _isInitialized = false;
  static const String _cdnBaseUrl = 'https://lumiconte-cdn.clementfourment.fr/';

  Future<void> init() async {
    if (_isInitialized) return;

    _audioPlayer = AudioPlayer();

    // Écouter les changements de position
    _audioPlayer.positionStream.listen((position) {
      playbackState.add(
        playbackState.value.copyWith(
          updatePosition: position,
          bufferedPosition: _audioPlayer.bufferedPosition,
        ),
      );
    });

    // Écouter les changements de durée
    _audioPlayer.durationStream.listen((duration) {
      if (duration != null) {
        // Mettre à jour le MediaItem pour que la notification sache la durée totale
        final currentItem = mediaItem.value;
        if (currentItem != null) {
          mediaItem.add(currentItem.copyWith(duration: duration));
        }

        playbackState.add(
          playbackState.value.copyWith(
            updatePosition: _audioPlayer.position,
            bufferedPosition: _audioPlayer.bufferedPosition,
          ),
        );
      }
    });

    // Écouter l'état de lecture
    _audioPlayer.playingStream.listen((isPlaying) {
      playbackState.add(
        playbackState.value.copyWith(
          playing: isPlaying,
          processingState: isPlaying
              ? AudioProcessingState.ready
              : playbackState.value.processingState,
        ),
      );
    });

    // Initialiser l'état de lecture
    playbackState.add(
      PlaybackState(
        playing: false,
        processingState: AudioProcessingState.idle,
        speed: 1.0,
        updatePosition: Duration.zero,
      ),
    );

    _isInitialized = true;
  }

  /// Configurer l'audio pour une histoire spécifique
  Future<void> setStory(StoryModel story, String objectKey) async {
    if (!_isInitialized) await init();

    final url = '$_cdnBaseUrl$objectKey';

    // Mise à jour des métadonnées pour la notification système
    mediaItem.add(MediaItem(
      id: story.id,
      album: 'Lumiconte',
      title: story.name,
      artUri: Uri.parse(story.image ?? 'https://lumiconte-cdn.clementfourment.fr/assets/default_story.webp'),
    ));

    try {
      await _audioPlayer.setUrl(url);
      playbackState.add(
        playbackState.value.copyWith(
          processingState: AudioProcessingState.ready,
        ),
      );
    } catch (e) {
      debugPrint('Erreur chargement audio: $e');
      playbackState.add(
        playbackState.value.copyWith(
          processingState: AudioProcessingState.error,
        ),
      );
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
