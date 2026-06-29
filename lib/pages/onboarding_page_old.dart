import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:go_router/go_router.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: OnboardingScreen(),
    );
  }
}

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: _PetitesHistoiresHero(),
    );
  }
}

class _PetitesHistoiresHero extends StatefulWidget {
  const _PetitesHistoiresHero();

  @override
  State<_PetitesHistoiresHero> createState() => _PetitesHistoiresHeroState();
}

class _PetitesHistoiresHeroState extends State<_PetitesHistoiresHero>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _childFloatController;
  late AnimationController _rabbitBounceController;
  late AnimationController _glowController;
  late AnimationController _particleController;

  @override
  void initState() {
    super.initState();

    // Main background animations (stars, clouds)
    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    // Child floating animation
    _childFloatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    // Rabbit bouncing animation
    _rabbitBounceController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    // Glow pulse effect
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    // Particles floating
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
  }

  @override
  void dispose() {
    _mainController.dispose();
    _childFloatController.dispose();
    _rabbitBounceController.dispose();
    _glowController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _mainController,
        _childFloatController,
        _rabbitBounceController,
        _glowController,
        _particleController,
      ]),
      builder: (context, _) {
        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF0B0E27),
                Color(0xFF1A1A4D),
                Color(0xFF2A1B5A),
              ],
            ),
          ),
          child: Stack(
            children: [
              // BACKGROUND LAYERS

              // Animated stars background
              _AnimatedStarsLayer(t: _mainController.value),

              // Glow blobs background
              _GlowBlobsLayer(t: _glowController.value),

              // Animated clouds
              _CloudsLayer(t: _mainController.value),

              // Floating particles
              _ParticlesLayer(t: _particleController.value),

              // MAIN CONTENT
              Positioned.fill(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Header spacing
                    const SizedBox(height: 40),

                    // Title section
                    const _TitleSection(),

                    // Hero illustration with assets
                    _HeroAssetsSection(
                      childFloatValue: _childFloatController.value,
                      rabbitBounceValue: _rabbitBounceController.value,
                      glowValue: _glowController.value,
                    ),

                    const SizedBox(height: 60),
                  ],
                ),
              ),

              // CTA BUTTON
              Positioned(
                bottom: 50,
                left: 24,
                right: 24,
                child: _PremiumButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Adventure starts! 🎉')),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ============================================================================
// TITLE SECTION
// ============================================================================

class _TitleSection extends StatelessWidget {
  const _TitleSection();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const Text(
            "Petites Histoires",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: -1.2,
              height: 1.0,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "Des histoires magiques pour\nles petits rêveurs",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 17,
              color: Colors.white.withOpacity(0.78),
              height: 1.6,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// HERO ASSETS SECTION - Avec animations et effects
// ============================================================================

class _HeroAssetsSection extends StatelessWidget {
  final double childFloatValue;
  final double rabbitBounceValue;
  final double glowValue;

  const _HeroAssetsSection({
    required this.childFloatValue,
    required this.rabbitBounceValue,
    required this.glowValue,
  });

  @override
  Widget build(BuildContext context) {
    // Sine wave animation for floating
    final childFloatOffset = math.sin(childFloatValue * 2 * math.pi) * 18;

    // Bounce animation (parabolic)
    final rabbitBounceOffset = (rabbitBounceValue - 0.5).abs() * 40;
    final rabbitBounceX = math.sin(rabbitBounceValue * 2 * math.pi) * 12;

    // Glow pulse
    final glowScale = 0.8 + (glowValue * 0.4);
    final glowOpacity = 0.4 + (glowValue * 0.3);

    return SizedBox(
      height: 340,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // GLOW EFFECT BEHIND
          Positioned(
            child: Transform.scale(
              scale: glowScale,
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFFFDB833).withOpacity(glowOpacity * 0.6),
                      const Color(0xFF7B68EE).withOpacity(glowOpacity * 0.3),
                      Colors.transparent,
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFDB833)
                          .withOpacity(glowOpacity * 0.4),
                      blurRadius: 60,
                      spreadRadius: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // CHILD IMAGE - FLOATING
          Positioned(
            child: Transform.translate(
              offset: Offset(0, childFloatOffset),
              child: Transform.scale(
                scale: 1.0,
                child: // Shadow drop
                    Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(80),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.25),
                        blurRadius: 40,
                        offset: const Offset(0, 20),
                      ),
                      BoxShadow(
                        color: const Color(0xFFFDB833).withOpacity(0.2),
                        blurRadius: 30,
                        offset: const Offset(0, 15),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(80),
                    child: Image.asset(
                      'assets/images/boy.png',
                      width: 220,
                      height: 220,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 220,
                          height: 220,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(80),
                          ),
                          child: const Center(
                            child: Text('Add asset:\nboy.png'),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),

          // RABBIT IMAGE - BOUNCING + HORIZONTAL SWAY
          Positioned(
            right: 30,
            bottom: 10 - rabbitBounceOffset,
            child: Transform.translate(
              offset: Offset(rabbitBounceX, 0),
              child: Transform.rotate(
                angle: rabbitBounceX * 0.05, // Slight rotation with sway
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 25,
                        offset: const Offset(0, 12),
                      ),
                      BoxShadow(
                        color: const Color(0xFFFFB6D9).withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: Image.asset(
                      'assets/images/rabbit.png',
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: const Center(
                            child: Text('Add asset:\nrabbit.png'),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),

          // SHINE/LIGHT EFFECT on child
          Positioned(
            child: Transform.translate(
              offset: Offset(0, childFloatOffset),
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(80),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withOpacity(0.15),
                      Colors.transparent,
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// BACKGROUND LAYERS - ANIMATIONS
// ============================================================================

class _AnimatedStarsLayer extends StatelessWidget {
  final double t;

  const _AnimatedStarsLayer({required this.t});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _StarsPainter(t),
      child: const SizedBox.expand(),
    );
  }
}

class _StarsPainter extends CustomPainter {
  final double t;

  _StarsPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final List<Offset> stars = List.generate(
      60,
      (i) => Offset(
        (math.sin(i * 2.7) * 0.5 + 0.5) * size.width,
        (math.cos(i * 3.3) * 0.5 + 0.35) * size.height,
      ),
    );

    for (int i = 0; i < stars.length; i++) {
      // final p = stars[i];
      // final twinkle = (math.sin(t * 3.5 + i * 0.4) + 1) / 2;

      // // Star core
      // final paint = Paint()
      //   ..color = Colors.white.withOpacity(0.25 + twinkle * 0.55);

      // final radius = (i % 4 == 0) ? 1.8 : 0.95;
      // canvas.drawCircle(p, radius, paint);

      // Star glow
      // if (twinkle > 0.6) {
      //   final glowPaint = Paint()
      //     ..color = Colors.white.withOpacity((twinkle - 0.6) * 0.3)
      //     ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      //   canvas.drawCircle(p, radius * 3, glowPaint);
      // }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _GlowBlobsLayer extends StatelessWidget {
  final double t;

  const _GlowBlobsLayer({required this.t});

  @override
  Widget build(BuildContext context) {
    final pulseScale = 0.9 + (math.sin(t * 2 * math.pi) * 0.15);

    return Stack(
      children: [
        // Top-left purple glow
        Positioned(
          top: 80,
          left: 20,
          child: Transform.scale(
            scale: pulseScale,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF7B68EE).withOpacity(0.25),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF7B68EE).withOpacity(0.3),
                    blurRadius: 100,
                    spreadRadius: 40,
                  ),
                ],
              ),
            ),
          ),
        ),

        // Bottom-right yellow glow
        Positioned(
          bottom: 100,
          right: 10,
          child: Transform.scale(
            scale: pulseScale * 1.1,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFFFC048).withOpacity(0.2),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFFC048).withOpacity(0.25),
                    blurRadius: 90,
                    spreadRadius: 30,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CloudsLayer extends StatelessWidget {
  final double t;

  const _CloudsLayer({required this.t});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Cloud 1
        Positioned(
          bottom: 200,
          left: -30 + (math.sin(t * 2 * math.pi) * 40),
          child: const _CloudShape(size: 140, opacity: 0.5),
        ),

        // Cloud 2
        Positioned(
          bottom: 150,
          right: -50 + (math.cos(t * 2 * math.pi) * 50),
          child: const _CloudShape(size: 110, opacity: 0.35),
        ),

        // Cloud 3
        Positioned(
          bottom: 280,
          left: 80 + (math.sin((t + 0.5) * 2 * math.pi) * 35),
          child: const _CloudShape(size: 95, opacity: 0.25),
        ),
      ],
    );
  }
}

class _CloudShape extends StatelessWidget {
  final double size;
  final double opacity;

  const _CloudShape({
    required this.size,
    required this.opacity,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size * 0.6),
      painter: _CloudPainter(opacity: opacity),
    );
  }
}

class _CloudPainter extends CustomPainter {
  final double opacity;

  _CloudPainter({required this.opacity});

  @override
  void paint(Canvas canvas, Size size) {
    final cloudPaint = Paint()
      ..color = const Color(0xFF7B68EE).withOpacity(opacity * 0.65)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(size.width * 0.2, size.height * 0.5),
      size.height * 0.45,
      cloudPaint,
    );

    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.3),
      size.height * 0.5,
      cloudPaint,
    );

    canvas.drawCircle(
      Offset(size.width * 0.8, size.height * 0.5),
      size.height * 0.45,
      cloudPaint,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, size.height * 0.25, size.width, size.height * 0.5),
        Radius.circular(size.height * 0.25),
      ),
      cloudPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ParticlesLayer extends StatelessWidget {
  final double t;

  const _ParticlesLayer({required this.t});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _ParticlesPainter(t),
      child: const SizedBox.expand(),
    );
  }
}

class _ParticlesPainter extends CustomPainter {
  final double t;

  _ParticlesPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final particles = List.generate(
      20,
      (i) => {
        'x': (math.sin(i * 1.5) * 0.5 + 0.5) * size.width,
        'y': (math.cos(i * 2.3) * 0.4 + 0.6) * size.height,
        'speed': 0.5 + (i % 3) * 0.3,
      },
    );

    for (final particle in particles) {
      final x = particle['x'] as double;
      var y = particle['y'] as double;
      final speed = particle['speed'] as double;

      // Floating animation
      y = y + (math.sin(t * speed * 2 * math.pi) * 15);

      // Opacity based on position
      final opacity = 0.3 + (math.sin(t * speed * 3 + y) + 1) / 2 * 0.4;

      final paint = Paint()..color = Colors.white.withOpacity(opacity * 0.6);

      canvas.drawCircle(Offset(x, y), 1.5, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// ============================================================================
// CTA BUTTON - PREMIUM
// ============================================================================

class _PremiumButton extends StatefulWidget {
  final VoidCallback onPressed;

  const _PremiumButton({required this.onPressed});

  @override
  State<_PremiumButton> createState() => _PremiumButtonState();
}

class _PremiumButtonState extends State<_PremiumButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    _controller.forward().then((_) {
      _controller.reverse();
      widget.onPressed();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: ScaleTransition(
        scale: Tween<double>(begin: 1.0, end: 0.94).animate(
          CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
        ),
        child: Container(
          height: 62,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFFDB833), Color(0xFFFFC94A)],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFDB833).withOpacity(0.6),
                blurRadius: 25,
                offset: const Offset(0, 12),
              ),
              BoxShadow(
                color: const Color(0xFFFFC94A).withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: ElevatedButton(
              onPressed: () {
                context.go('/login');
              },
              child: const Text(
                "Commencer",
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1A1A4D),
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
