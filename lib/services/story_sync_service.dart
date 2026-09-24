import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:lumiconte/models/audio_sync_model.dart';
import 'package:lumiconte/services/audio_background_service.dart';

class StorySyncService {
  /// Segments déjà téléchargés, par chemin `audioTimes`.
  static final Map<String, List<SegmentTiming>> _cache = {};

  /// Téléchargements en cours : une même voix n'est demandée qu'une fois.
  static final Map<String, Future<List<SegmentTiming>>> _pending = {};

  /// Segments de la voix s'ils sont déjà chargés, sinon `null`.
  static List<SegmentTiming>? cachedSegments(String? audioTimes) {
    final path = audioTimes?.trim() ?? '';
    if (path.isEmpty) return const [];
    // Ancien format : le JSON est directement dans la base
    if (path.startsWith('{')) return parseSegments(path);
    return _cache[path];
  }

  /// Télécharge sur le CDN les segments minutés de la voix, dont `audioTimes`
  /// donne le chemin (ex: `fr_audioTimes/Peter_Pan_et_Wendy_F.txt`).
  static Future<List<SegmentTiming>> loadSegments(String? audioTimes) {
    final cached = cachedSegments(audioTimes);
    if (cached != null) return Future.value(cached);

    final path = audioTimes!.trim();
    // Bloc sans valeur de retour : renvoyer le Future retiré ferait attendre
    // whenComplete sur lui-même, et le chargement ne finirait jamais
    return _pending[path] ??= _download(path).whenComplete(() {
      _pending.remove(path);
    });
  }

  static Future<List<SegmentTiming>> _download(String path) async {
    final url = Uri.parse('${AudioBackgroundService.cdnBaseUrl}$path');
    try {
      final response = await http.get(url);
      if (response.statusCode != 200) {
        debugPrint('audioTimes $url : HTTP ${response.statusCode}');
        return const [];
      }
      final segments = parseSegments(utf8.decode(response.bodyBytes));
      _cache[path] = segments;
      return segments;
    } catch (e) {
      debugPrint('Téléchargement de audioTimes $url : $e');
      return const [];
    }
  }

  /// Lit les segments minutés du JSON `audioTimes`.
  static List<SegmentTiming> parseSegments(String? json) {
    if (json == null || json.trim().isEmpty) return [];

    try {
      final data = jsonDecode(json) as Map<String, dynamic>;
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
