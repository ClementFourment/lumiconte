import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:lumiconte/theme/app_theme.dart';

/// Le lapin mascotte de Lumiconte, qui se balance doucement.
/// Avec [message], il parle à l'enfant dans une bulle.
class Mascot extends StatefulWidget {
  final String? message;
  final double size;

  const Mascot({super.key, this.message, this.size = 72});

  @override
  State<Mascot> createState() => _MascotState();
}

class _MascotState extends State<Mascot> with SingleTickerProviderStateMixin {
  late final AnimationController _bob = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2400),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _bob.stop();
    } else if (!_bob.isAnimating) {
      _bob.repeat();
    }
  }

  @override
  void dispose() {
    _bob.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final rabbit = AnimatedBuilder(
      animation: _bob,
      builder: (context, child) {
        final t = _bob.value * 2 * math.pi;
        return Transform.translate(
          offset: Offset(0, -math.sin(t).abs() * 5),
          child: Transform.rotate(angle: math.sin(t) * 0.05, child: child),
        );
      },
      child: Image.asset(
        'assets/images/mascot_rabbit.png',
        height: widget.size,
        filterQuality: FilterQuality.medium,
      ),
    );

    if (widget.message == null) return rabbit;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        rabbit,
        const SizedBox(width: 4),
        Flexible(
          child: Padding(
            padding: EdgeInsets.only(bottom: widget.size * 0.35),
            child: _SpeechBubble(text: widget.message!),
          ),
        ),
      ],
    );
  }
}

class _SpeechBubble extends StatelessWidget {
  final String text;

  const _SpeechBubble({required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bubbleColor = isDark ? AppTheme.darkCard : Colors.white;

    return CustomPaint(
      painter: _BubbleTailPainter(bubbleColor),
      child: Container(
        margin: const EdgeInsets.only(left: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: AppTheme.accentColor.withValues(alpha: 0.35),
          ),
        ),
        child: Text(
          text,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            height: 1.3,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}

/// Petite pointe de la bulle, dirigée vers le lapin (en bas à gauche).
class _BubbleTailPainter extends CustomPainter {
  final Color color;

  _BubbleTailPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(10, size.height - 20)
      ..lineTo(0, size.height - 6)
      ..lineTo(18, size.height - 12)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _BubbleTailPainter oldDelegate) =>
      oldDelegate.color != color;
}
