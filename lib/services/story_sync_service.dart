import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:lumiconte/models/audio_sync_model.dart';

class StorySyncService {
  /// Lit les segments minutés du JSON `audioTimes` de la voix active.
  static List<SegmentTiming> parseSegments(String? audioTimes) {
    if (audioTimes == null || audioTimes.trim().isEmpty) return [];

    try {
      final data = jsonDecode(audioTimes) as Map<String, dynamic>;
      final rawSegments = data['segments'] as List? ?? [];
      return rawSegments
          .map((s) => SegmentTiming.fromJson(s as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Erreur lors du parsing de audioTimes: $e');
      return [];
    }
  }
}
