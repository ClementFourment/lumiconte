import 'package:audioplayers/audioplayers.dart';

class B2Audio {
  final String objectKey;
  final AudioPlayer _player = AudioPlayer();

  bool _prepared = false;

  B2Audio({
    required this.objectKey,
  });

  String get url => 'https://lumiconte-cdn.clementfourment.fr/$objectKey';

  Future<void> preload() async {
    if (_prepared) return;

    await _player.setReleaseMode(ReleaseMode.stop);

    await _player.setSourceUrl(url);

    _prepared = true;
  }

  Future<void> play() async {
    if (!_prepared) {
      await preload();
    }

    await _player.resume();
  }

  Future<void> resume() => _player.resume();

  Future<void> pause() => _player.pause();

  Future<void> stop() => _player.stop();

  Future<void> seek(Duration position) => _player.seek(position);

  Future<void> seekToStart() => seek(Duration.zero);

  Future<void> dispose() => _player.dispose();

  Stream<void> get onComplete => _player.onPlayerComplete;

  Stream<Duration> get onPositionChanged => _player.onPositionChanged;

  Stream<Duration> get onDurationChanged => _player.onDurationChanged;

  Stream<PlayerState> get onPlayerStateChanged => _player.onPlayerStateChanged;
}
