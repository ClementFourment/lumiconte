import 'package:flutter/material.dart';
import 'package:lumiconte/models/story_model.dart';
import 'package:lumiconte/widget/b2_audio.dart';
import 'package:lumiconte/widget/b2_image.dart';

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

  late final B2Audio _audio;

  @override
  void initState() {
    super.initState();
    final test = widget.story.audio[1]['harry'] ?? '';
    // NB : widget.story.audio doit contenir la clé de l'objet mp3 sur B2
    // (même principe que widget.story.image pour B2Image).
    _audio = B2Audio(objectKey: test);

    // Démarre le buffering en arrière-plan dès l'ouverture de la page,
    // pendant que l'utilisateur lit le texte : au moment où il appuie sur
    // lecture, le flux est déjà prêt (ou bien avancé).
    _audio.preload();

    _audio.onComplete.listen((_) async {
      await _audio.seekToStart();
      if (mounted) setState(() => _isPlaying = false);
    });
  }

  Future<void> _toggleAudio() async {
    if (_isPlaying) {
      await _audio.pause();
      setState(() => _isPlaying = false);
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _audio.play();
      if (mounted) setState(() => _isPlaying = true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur audio: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _audio.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final text = widget.story.content
        .replaceAll(r'\n', '\n\n')
        .replaceAll(RegExp(r'[ \t]+'), ' ')
        .trim();

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
                          child: Text(text),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: _BottomControls(
                        storyId: widget.story.id,
                        isPlaying: _isPlaying,
                        isLoading: _isLoading,
                        onDecreaseText: () => setState(
                          () => _fontSize = (_fontSize - 2).clamp(18, 34),
                        ),
                        onIncreaseText: () => setState(
                          () => _fontSize = (_fontSize + 2).clamp(18, 34),
                        ),
                        onToggleAudio: _toggleAudio,
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
  final bool isLoading;
  final VoidCallback onDecreaseText;
  final VoidCallback onIncreaseText;
  final VoidCallback onToggleAudio;

  const _BottomControls({
    required this.storyId,
    required this.isPlaying,
    required this.isLoading,
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
          if (isLoading)
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else
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
