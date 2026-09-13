import 'package:flutter/material.dart';
import 'package:lumiconte/pages/story/story_text.dart';

class StoryViewParams {
  final StoryDocument document;

  /// Premier mot de la page courante ; la page affichée est celle qui le contient.
  final int anchorWord;
  final StoryPagination Function(StoryLayoutRequest request) paginate;
  final int currentPageIndex;
  final int totalPages;
  final bool isFavorite;
  final bool isAudio;
  final bool isPlaying;
  final bool isLoading;
  final Duration audioPosition;
  final Duration audioDuration;
  final double fontSize;
  final bool isDyslexia;
  final String? image;
  final VoidCallback onBack;
  final VoidCallback onToggleFavorite;
  final VoidCallback onRestart;
  final VoidCallback onNextPage;
  final VoidCallback onPreviousPage;
  final VoidCallback onToggleAudio;
  final ValueChanged<double> onSeekAudioChanged;
  final ValueChanged<double> onSeekAudio;
  final VoidCallback onRewind;
  final VoidCallback onFastForward;

  bool get isAtStart =>
      currentPageIndex == 0 && audioPosition == Duration.zero;

  StoryViewParams({
    required this.document,
    required this.anchorWord,
    required this.paginate,
    required this.currentPageIndex,
    required this.totalPages,
    required this.isFavorite,
    required this.isAudio,
    required this.isPlaying,
    required this.isLoading,
    required this.audioPosition,
    required this.audioDuration,
    required this.fontSize,
    required this.isDyslexia,
    required this.image,
    required this.onBack,
    required this.onToggleFavorite,
    required this.onRestart,
    required this.onNextPage,
    required this.onPreviousPage,
    required this.onToggleAudio,
    required this.onSeekAudioChanged,
    required this.onSeekAudio,
    required this.onRewind,
    required this.onFastForward,
  });
}
