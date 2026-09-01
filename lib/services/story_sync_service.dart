import 'dart:convert';
import 'package:lumiconte/models/story_model.dart'; // Votre modèle existant
import 'package:lumiconte/models/audio_sync_model.dart';

class StorySyncService {
  List<StorySyncPage> pages = [];

  void initializeFromStory(StoryModel story, {int maxCharsPerPage = 150}) {
    pages.clear();

    if (story.audioTimes == null || story.audioTimes!.isEmpty) {
      return;
    }

    try {
      final Map<String, dynamic> data = jsonDecode(story.audioTimes!);
      final List rawSegments = data['segments'] as List? ?? [];
      final segments =
          rawSegments.map((s) => SegmentTiming.fromJson(s)).toList();

      List<SegmentTiming> currentSegments = [];
      int currentLength = 0;

      for (var segment in segments) {
        final textLength = segment.text.length;

        // Si ajouter ce segment dépasse la limite, on valide la page actuelle
        if (currentSegments.isNotEmpty &&
            (currentLength + textLength > maxCharsPerPage)) {
          pages.add(
            StorySyncPage(
              pageIndex: pages.length,
              segments: List.from(currentSegments),
            ),
          );
          currentSegments.clear();
          currentLength = 0;
        }

        currentSegments.add(segment);
        currentLength += textLength;
      }

      // Ajouter les derniers segments restants
      if (currentSegments.isNotEmpty) {
        pages.add(
          StorySyncPage(
            pageIndex: pages.length,
            segments: currentSegments,
          ),
        );
      }
    } catch (e) {
      print('Erreur lors du parsing de audioTimes: $e');
    }
  }

  int getPageIndexForTime(double currentTimeInSeconds) {
    if (pages.isEmpty) return 0;

    for (int i = 0; i < pages.length; i++) {
      if (currentTimeInSeconds >= pages[i].start &&
          currentTimeInSeconds <= pages[i].end) {
        return i;
      }
    }

    for (int i = 0; i < pages.length - 1; i++) {
      if (currentTimeInSeconds > pages[i].end &&
          currentTimeInSeconds < pages[i + 1].start) {
        return i;
      }
    }

    return currentTimeInSeconds >= pages.last.end ? pages.length - 1 : 0;
  }
}