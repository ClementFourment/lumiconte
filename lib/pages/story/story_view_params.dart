import 'package:flutter/material.dart';

class StoryViewParams {
  final String currentPageText;
  final int currentPageIndex;
  final int totalPages;
  final bool isFavorite;
  final bool isAudio;
  final bool isPlaying;
  final bool isLoading;
  final Duration audioPosition;
  final Duration audioDuration;
  final dynamic themeColors;
  final double fontSize;
  final bool isDyslexia;
  final String? image;
  final String? illustrationsPath;
  final VoidCallback onBack;
  final VoidCallback onToggleFavorite;
  final VoidCallback onNextPage;
  final VoidCallback onPreviousPage;
  final VoidCallback onToggleAudio;
  final ValueChanged<double> onSeekAudio;
  final TextSpan Function({
    required String text,
    required double baseFontSize,
    required Color defaultTextColor,
    required bool isDyslexiaEnabled,
  }) buildColorizedText;

  StoryViewParams({
    required this.currentPageText,
    required this.currentPageIndex,
    required this.totalPages,
    required this.isFavorite,
    required this.isAudio,
    required this.isPlaying,
    required this.isLoading,
    required this.audioPosition,
    required this.audioDuration,
    required this.themeColors,
    required this.fontSize,
    required this.isDyslexia,
    required this.image,
    required this.illustrationsPath,
    required this.onBack,
    required this.onToggleFavorite,
    required this.onNextPage,
    required this.onPreviousPage,
    required this.onToggleAudio,
    required this.onSeekAudio,
    required this.buildColorizedText,
  });
}
