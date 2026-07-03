import 'package:flutter/material.dart';
import 'package:lumiconte/models/story_model.dart';
import 'package:lumiconte/widget/b2_audio.dart';
import 'package:lumiconte/widget/b2_image.dart';
import 'package:flutter_tts/flutter_tts.dart';

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

  late final B2Audio _audio;
  late final FlutterTts _flutterTts;

  @override
  void initState() {
    super.initState();
    _flutterTts = FlutterTts();
    _flutterTts.setLanguage("fr-FR");
    _flutterTts.setSpeechRate(0.42);
    _flutterTts.setPitch(1.05);
    _flutterTts.setVolume(1.0);
    _useGoogleEngineIfAvailable();
    _selectBestFrenchVoice();

    // Remet l'icône sur "play" quand la lecture se termine toute seule
    _flutterTts.setCompletionHandler(() {
      if (mounted) setState(() => _isPlaying = false);
    });
    _flutterTts.setCancelHandler(() {
      if (mounted) setState(() => _isPlaying = false);
    });
    _flutterTts.setErrorHandler((msg) {
      if (mounted) setState(() => _isPlaying = false);
    });
  }

  Future<void> _toggleAudio(String text) async {
    if (_isPlaying) {
      await _flutterTts.stop();
      setState(() => _isPlaying = false);
    } else {
      setState(() => _isPlaying = true);
      await _flutterTts
          .speak(text.replaceAll('.', '.  ').replaceAll(',', ',  '));
    }
  }

  Future<void> _selectBestFrenchVoice() async {
    final voices = await _flutterTts.getVoices;
    if (voices == null) return;

    final frenchVoices = (voices as List)
        .cast<Map>()
        .where((v) => (v['locale'] as String?)?.startsWith('fr') ?? false)
        .toList();

    if (frenchVoices.isEmpty) return;

    // Sur Android, 'quality' existe (souvent 300/400/500+, plus haut = mieux)
    frenchVoices.sort((a, b) {
      final qa = int.tryParse(a['quality']?.toString() ?? '0') ?? 0;
      final qb = int.tryParse(b['quality']?.toString() ?? '0') ?? 0;
      return qb.compareTo(qa);
    });

    await _flutterTts.setVoice({
      "name": frenchVoices.first['name'],
      "locale": frenchVoices.first['locale'],
    });
  }

  Future<void> _useGoogleEngineIfAvailable() async {
    final engines = await _flutterTts.getEngines;
    if (engines != null &&
        (engines as List).contains("com.google.android.tts")) {
      await _flutterTts.setEngine("com.google.android.tts");
    }
  }

  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                        child: AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 200),
                          style: TextStyle(
                            fontSize: _fontSize,
                            height: 1.7,
                            color: Colors.black87,
                          ),
                          child: Text(
                            widget.story.content.replaceAll(r'\n', '\n'),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: _BottomControls(
                        isPlaying: _isPlaying,
                        onDecreaseText: () => setState(
                          () => _fontSize = (_fontSize - 2).clamp(18, 34),
                        ),
                        onIncreaseText: () => setState(
                          () => _fontSize = (_fontSize + 2).clamp(18, 34),
                        ),
                        onToggleAudio: () => _toggleAudio(widget.story.content),
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
  final bool isPlaying;
  final VoidCallback onDecreaseText;
  final VoidCallback onIncreaseText;
  final VoidCallback onToggleAudio;

  const _BottomControls({
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
