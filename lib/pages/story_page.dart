import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lumiconte/models/story_model.dart';
import 'package:lumiconte/widget/b2_audio.dart';
import 'package:lumiconte/widget/b2_image.dart';
import 'package:lumiconte/services/audio_generation_service.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:edge_tts/edge_tts.dart';
import 'package:audioplayers/audioplayers.dart';

class StoryPage extends StatefulWidget {
  final StoryModel story;

  const StoryPage({super.key, required this.story});

  @override
  State<StoryPage> createState() => _StoryPageState();
}

class _StoryPageState extends State<StoryPage> {
  double _fontSize = 22;
  bool _isFavorite = false;
  bool _isPlaying = false;
  bool _isLoading = false;
  bool _hasAudio = false;
  final _player = AudioPlayer();

  final Set<String> punctuation = {
    '.', ',', ';', ':', '!', '?', '…', '(', ')', '[', ']',
    '{', '}', '"', '«', '»', '|', '*', '^', '~', '/', '\\',
    "'", "’", '-', '_' //a
  };
  List<_WordTiming> _wordTimings = [];
  int _currentWordIndex = -1;

  @override
  void initState() {
    super.initState();

    // Ces listeners sont posés UNE SEULE FOIS, pas à chaque lecture
    _player.onPositionChanged.listen((position) {
      final ms = position.inMilliseconds;
      final index = _wordTimings.lastIndexWhere((w) => w.offsetMs <= ms);
      if (index != _currentWordIndex && mounted) {
        setState(() => _currentWordIndex = index);
      }
    });

    _player.onPlayerComplete.listen((_) {
      if (mounted) {
        setState(() {
          _isPlaying = false;
          _currentWordIndex = -1;
        });
      }
    });
  }

  Future<void> _generateAndPlay() async {
    setState(() {
      _isLoading = true;
      _wordTimings = [];
      _currentWordIndex = -1;
    });

    try {
      final tts = Communicate(
        text: widget.story.content.replaceAll(
            r'\n', '. '), //permet de respecter les intonnations de poesie
        voice: 'fr-FR-DeniseNeural',
        rate: '-10%', // légèrement ralenti, adapté conte du soir
        wordBoundary: true,
      );

      final audioChunks = <int>[];

      await for (final event in tts.stream()) {
        if (event is AudioDataEvent) {
          audioChunks.addAll(event.data);
        } else if (event is WordBoundaryEvent) {
          _wordTimings.add(_WordTiming(
            text: event.text,
            offsetMs: event.offset ~/
                10000, // conversion ticks -> ms, à ajuster selon l'unité réelle
          ));
        }
      }

      await _player.play(BytesSource(Uint8List.fromList(audioChunks)));
      _hasAudio = true; // <-- on retient qu'on a déjà l'audio
      setState(() => _isPlaying = true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleAudio() async {
    if (_isPlaying) {
      await _player.pause();
      setState(() => _isPlaying = false);
      return;
    }

    if (_hasAudio) {
      await _player.resume();
      setState(() => _isPlaying = true);
      return;
    }

    await _generateAndPlay();
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final text = widget.story.content
        .replaceAll(r'\n', ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    final List<String> _words = text.split(' ');

    print(_words);

    final String textToDisplay = _words
        .map((w) => punctuation.contains(w) ? '' : w)
        .join(' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    final wordsToDisplay =
        textToDisplay.split(' '); //.replaceAll(r'\n', ' ').split(' ');
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Image de fond, fixe
          Positioned.fill(
            child: Hero(
              tag: widget.story.image,
              child: B2Image(
                objectKey: widget.story.image,
                fit: BoxFit.cover,
              ),
            ),
          ),

          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(.45),
                    Colors.transparent,
                    Colors.transparent,
                    Colors.black.withOpacity(.6),
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _TopBar(
                isFavorite: _isFavorite,
                onBack: () => Navigator.pop(context),
                onFavorite: () => setState(() => _isFavorite = !_isFavorite),
              ),
            ),
          ),

          // Le panneau texte, redimensionnable via la tirette
          DraggableScrollableSheet(
            initialChildSize: 0.42,
            minChildSize: 0.2,
            maxChildSize: 0.88,
            snap: true,
            snapSizes: const [0.2, 0.42, 0.88],
            builder: (context, scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(36)),
                ),
                child: Column(
                  children: [
                    const _DragHandle(),
                    Expanded(
                      child: SingleChildScrollView(
                        controller: scrollController,
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                        child: Wrap(
                          children: List.generate(wordsToDisplay.length, (i) {
                            final isCurrent = i == _currentWordIndex;
                            return Container(
                              margin:
                                  const EdgeInsets.only(right: 4, bottom: 4),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 2),
                              decoration: BoxDecoration(
                                color: isCurrent ? Colors.amber.shade200 : null,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                wordsToDisplay[i],
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: isCurrent
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            );
                          }),
                        ),

                        // AnimatedDefaultTextStyle(
                        //   duration: const Duration(milliseconds: 200),
                        //   style: TextStyle(
                        //     fontSize: _fontSize,
                        //     height: 1.7,
                        //     color: Colors.black87,
                        //   ),
                        //   child: Text(wordsToDisplay[i]),
                        // ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: _BottomControls(
                        storyId: widget.story.id,
                        isPlaying: _isPlaying,
                        onDecreaseText: () => setState(
                          () => _fontSize = (_fontSize - 2).clamp(18, 34),
                        ),
                        onIncreaseText: () => setState(
                          () => _fontSize = (_fontSize + 2).clamp(18, 34),
                        ),
                        onToggleAudio: () => _toggleAudio(),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _DragHandle extends StatelessWidget {
  const _DragHandle();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Container(
        width: 44,
        height: 5,
        decoration: BoxDecoration(
          color: Colors.black12,
          borderRadius: BorderRadius.circular(50),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final bool isFavorite;
  final VoidCallback onBack;
  final VoidCallback onFavorite;

  const _TopBar({
    required this.isFavorite,
    required this.onBack,
    required this.onFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          _CircleButton(icon: Icons.arrow_back, onPressed: onBack),
          const Spacer(),
          _CircleButton(
            icon: isFavorite ? Icons.favorite : Icons.favorite_border,
            color: isFavorite ? Colors.red : Colors.white,
            onPressed: onFavorite,
          ),
        ],
      ),
    );
  }
}

class _BottomControls extends StatelessWidget {
  final String storyId;
  final bool isPlaying;
  final VoidCallback onDecreaseText;
  final VoidCallback onIncreaseText;
  final VoidCallback onToggleAudio;

  const _BottomControls({
    required this.storyId,
    required this.isPlaying,
    required this.onDecreaseText,
    required this.onIncreaseText,
    required this.onToggleAudio,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.deepPurple.shade50,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          _ControlButton(icon: Icons.remove, onPressed: onDecreaseText),
          _ControlButton(icon: Icons.add, onPressed: onIncreaseText),
          const Spacer(),
          _ControlButton(
            icon: isPlaying ? Icons.pause : Icons.volume_up,
            onPressed: onToggleAudio,
          ),
        ],
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  const _CircleButton({
    required this.icon,
    required this.onPressed,
    this.color = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black38,
      shape: const CircleBorder(),
      child: InkWell(
        borderRadius: BorderRadius.circular(100),
        onTap: onPressed,
        child: SizedBox(
          width: 48,
          height: 48,
          child: Icon(icon, color: color),
        ),
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _ControlButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return IconButton(onPressed: onPressed, icon: Icon(icon));
  }
}

class _WordTiming {
  final String text;
  final int offsetMs;
  _WordTiming({required this.text, required this.offsetMs});
}
