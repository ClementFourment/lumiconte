import 'package:audioplayers/audioplayers.dart';
import 'package:lumiconte/services/storage_service.dart';

/// Lecteur audio pour un fichier stocké sur B2, en streaming via une URL
/// pré-signée (au lieu de charger tout le fichier en mémoire avant de jouer).
class B2Audio {
  final String objectKey;
  final AudioPlayer _player = AudioPlayer();
  late final Future<String> _urlFuture;
  bool _prepared = false;

  B2Audio({required this.objectKey}) {
    _urlFuture = StorageService.getPresignedUrl(objectKey);
  }

  /// À appeler tôt (ex: initState) pour commencer à bufferiser en tâche de
  /// fond, avant même que l'utilisateur n'appuie sur lecture.
  Future<void> preload() async {
    if (_prepared) return;
    // Important : par défaut audioplayers utilise ReleaseMode.release, qui
    // libère complètement la source à la fin de la lecture. Résultat : un
    // seek() ou resume() après la fin ne fait plus rien (source absente).
    // ReleaseMode.stop garde la source chargée, seule la lecture s'arrête.
    await _player.setReleaseMode(ReleaseMode.stop);
    final url = await _urlFuture;
    await _player.setSourceUrl(url);
    _prepared = true;
  }

  /// Joue (ou reprend) la lecture. Si [preload] n'a pas encore été appelé,
  /// le fait à la volée.
  Future<void> play() async {
    if (!_prepared) {
      await preload();
    }
    await _player.resume();
  }

  /// Reprend la lecture après une pause.
  Future<void> resume() => _player.resume();

  /// Déplace la tête de lecture à une position donnée.
  Future<void> seek(Duration position) => _player.seek(position);

  /// Repart du début (utile après la fin de la lecture).
  Future<void> seekToStart() => seek(Duration.zero);

  Future<void> pause() => _player.pause();
  Future<void> stop() => _player.stop();
  Future<void> dispose() => _player.dispose();

  Stream<void> get onComplete => _player.onPlayerComplete;
  Stream<Duration> get onPositionChanged => _player.onPositionChanged;
  Stream<Duration> get onDurationChanged => _player.onDurationChanged;
  Stream<PlayerState> get onPlayerStateChanged => _player.onPlayerStateChanged;
}
