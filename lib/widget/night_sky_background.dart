import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Fond d'ambiance Lumiconte, partagé par les écrans de l'enfant.
/// Mode nuit : ciel étoilé qui scintille doucement et nuages.
/// Mode jour : ciel pastel avec quelques nuages.
class NightSkyBackground extends StatefulWidget {
  final Widget child;

  const NightSkyBackground({super.key, required this.child});

  @override
  State<NightSkyBackground> createState() => _NightSkyBackgroundState();
}

class _NightSkyBackgroundState extends State<NightSkyBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _twinkle = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 8),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Respecte le réglage système « réduire les animations »
    if (MediaQuery.disableAnimationsOf(context)) {
      _twinkle.stop();
    } else if (!_twinkle.isAnimating) {
      _twinkle.repeat();
    }
  }

  @override
  void dispose() {
    _twinkle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: isDark
                  ? const [
                      Color(0xFF0E1033),
                      Color(0xFF1B1840),
                      Color(0xFF1E1B29)
                    ]
                  : const [
                      Color(0xFFDCE8FF),
                      Color(0xFFF3EEFF),
                      Color(0xFFFFF8EE)
                    ],
              stops: const [0.0, 0.45, 1.0],
            ),
          ),
        ),
        if (isDark)
          RepaintBoundary(
            child: CustomPaint(painter: _StarsPainter(_twinkle)),
          ),
        Positioned(
          top: 90,
          left: -110,
          child: _Cloud(
              asset: 'assets/images/cloud1.png', opacity: isDark ? 0.18 : 0.55),
        ),
        Positioned(
          top: 360,
          right: -130,
          child: _Cloud(
              asset: 'assets/images/cloud3.png', opacity: isDark ? 0.12 : 0.45),
        ),
        widget.child,
      ],
    );
  }
}

class _Cloud extends StatelessWidget {
  final String asset;
  final double opacity;

  const _Cloud({required this.asset, required this.opacity});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Opacity(
        opacity: opacity,
        child: Image.asset(asset, width: 320),
      ),
    );
  }
}

class _Star {
  final Offset position; // Coordonnées relatives (0..1)
  final double radius;
  final double phase;

  const _Star(this.position, this.radius, this.phase);
}

class _StarsPainter extends CustomPainter {
  final Animation<double> animation;

  // Positions fixes (graine constante) : le ciel ne change pas d'un écran à l'autre
  static final List<_Star> _stars = () {
    final random = math.Random(42);
    return List.generate(70, (i) {
      // Plus d'étoiles en haut de l'écran qu'en bas
      final y = math.pow(random.nextDouble(), 1.6).toDouble();
      final big = random.nextDouble() < 0.12;
      return _Star(
        Offset(random.nextDouble(), y),
        big ? 1.7 : 0.6 + random.nextDouble() * 0.6,
        random.nextDouble() * 2 * math.pi,
      );
    });
  }();

  _StarsPainter(this.animation) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final t = animation.value * 2 * math.pi;
    final paint = Paint();
    final glowPaint = Paint()
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

    for (final star in _stars) {
      final twinkle = (math.sin(t + star.phase) + 1) / 2;
      final center =
          Offset(star.position.dx * size.width, star.position.dy * size.height);

      paint.color = Colors.white.withValues(alpha: 0.25 + twinkle * 0.6);
      canvas.drawCircle(center, star.radius, paint);

      // Halo doré uniquement sur les grosses étoiles
      if (star.radius > 1.5) {
        glowPaint.color =
            const Color(0xFFFDE68A).withValues(alpha: 0.15 + twinkle * 0.35);
        canvas.drawCircle(center, star.radius * 3, glowPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _StarsPainter oldDelegate) => false;
}
