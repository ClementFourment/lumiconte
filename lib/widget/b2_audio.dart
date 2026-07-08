import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';
import 'package:lumiconte/services/storage_service.dart';

/// Lecteur audio pour un fichier stocké sur B2 (même logique que B2Image).
class B2Audio {
  final String objectKey;
  final AudioPlayer _player = AudioPlayer();
  Uint8List? _cachedBytes;

  B2Audio({required this.objectKey});

  /// Télécharge (une seule fois, mis en cache) et joue le fichier depuis le début.
  Future<void> play() async {
    _cachedBytes ??= await StorageService.fetchObjectCached(objectKey);
    await _player.play(BytesSource(_cachedBytes!));
  }

  /// Reprend la lecture après une pause, sans re-télécharger le fichier.
  Future<void> resume() => _player.resume();

  Future<void> pause() => _player.pause();
  Future<void> stop() => _player.stop();
  Future<void> dispose() => _player.dispose();

  Stream<void> get onComplete => _player.onPlayerComplete;
  Stream<Duration> get onPositionChanged => _player.onPositionChanged;
  Stream<Duration> get onDurationChanged => _player.onDurationChanged;
  Stream<PlayerState> get onPlayerStateChanged => _player.onPlayerStateChanged;
}
