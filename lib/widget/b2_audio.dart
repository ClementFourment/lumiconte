import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:lumiconte/services/storage_service.dart';

/// Lecteur audio pour un fichier stocké sur B2 (même logique que B2Image).
class B2Audio {
  final String objectKey;
  final AudioPlayer _player = AudioPlayer();

  B2Audio({required this.objectKey});

  Future<void> play() async {
    final Uint8List bytes = await StorageService.fetchObjectCached(objectKey);
    await _player.play(BytesSource(bytes));
  }

  Future<void> pause() => _player.pause();
  Future<void> stop() => _player.stop();
  Future<void> dispose() => _player.dispose();

  Stream<void> get onComplete => _player.onPlayerComplete;
}
