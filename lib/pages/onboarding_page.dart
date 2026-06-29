import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

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
      duration: const Duration(seconds: 100),
    )..repeat();

    // Child floating animation
    _childFloatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 100), //4
    )..repeat(reverse: true);

    // Rabbit bouncing animation
    _rabbitBounceController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 100),
    )..repeat(reverse: true);

    // Glow pulse effect
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);

    // Particles floating
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 100),
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
              Positioned(
                top: -10,
                right: 15,
                child: _MoonSection(),
              ),
              const Positioned(
                top: 150,
                left: 0,
                right: 0,
                child: _TitleSection(),
              ),
              // Hero illustration with assets
              Positioned(
                bottom: 40,
                left: 0,
                right: 0,
                child: _HeroAssetsSection(
                  childFloatValue: _childFloatController.value,
                  rabbitBounceValue: _rabbitBounceController.value,
                  glowValue: _glowController.value,
                ),
              ),
              // CTA BUTTON
              Positioned(
                bottom: 40,
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
            "Lumiconte",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: -1.2,
              height: 1.0,
            ),
          ),
          const SizedBox(height: 30),
          Text(
            "Des histoires magiques\npour les petits rêveurs",
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
class _MoonSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/moon.png',
      width: 220,
      height: 220,
      fit: BoxFit.cover,
    );
  }
}

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
      height: 450,
      width: 6000,
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
                      spreadRadius: 10,
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
                scale: 1.3,
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
                    ),
                  ),
                ),
              ),
            ),
          ),

          // RABBIT IMAGE - BOUNCING + HORIZONTAL SWAY
          Positioned(
            right: 10,
            bottom: 150 - rabbitBounceOffset,
            child: Transform.translate(
              offset: Offset(rabbitBounceX, 0),
              child: Transform.scale(
                scale: 3.0, // Slight rotation with sway
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
                    ),
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
      final p = stars[i];
      final twinkle = (math.sin(t * 3.5 + i * 0.4) + 1) / 2;

      // Star core
      final paint = Paint()
        ..color = Colors.white.withOpacity(0.25 + twinkle * 0.55);

      final radius = (i % 4 == 0) ? 1.8 : 0.95;
      canvas.drawCircle(p, radius, paint);

      // Star glow
      if (twinkle > 0.6) {
        final glowPaint = Paint()
          ..color = Colors.white.withOpacity((twinkle - 0.6) * 0.3)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
        canvas.drawCircle(p, radius * 3, glowPaint);
      }
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
        // Top-left purple glow moon
        Positioned(
          top: 95,
          right: 120,
          child: Transform.scale(
            scale: pulseScale,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                Container(
                  width: 2,
                  height: 2,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF7B68EE).withOpacity(0.25),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF7B68EE).withOpacity(0.3),
                        blurRadius: 40,
                        spreadRadius: 60,
                      ),
                    ],
                  ),
                ),
              ],
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
        // Clouds
        Positioned(
          bottom: 100,
          left: -30 + (math.sin(t * 2 * math.pi) * 40),
          child: Image.asset(
            'assets/images/cloud1.png',
            width: 220,
            height: 220,
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          bottom: 200,
          left: 80 + (math.cos((t - 1) * 2 * math.pi) * 30),
          child: Image.asset(
            'assets/images/cloud5.png',
            width: 220,
            height: 220,
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          bottom: 280,
          left: 80 + (math.sin((t + 0.5) * 2 * math.pi) * 35),
          child: Image.asset(
            'assets/images/cloud3.png',
            width: 220,
            height: 220,
            fit: BoxFit.cover,
          ),
        ),

        Positioned(
          bottom: 150,
          right: -50 + (math.cos(t * 2 * math.pi) * 50),
          child: Image.asset(
            'assets/images/cloud2.png',
            width: 220,
            height: 220,
            fit: BoxFit.cover,
          ),
        ),

        Positioned(
          bottom: 280,
          right: 80 + (math.cos((t + 0.5) * 2 * math.pi) * 35),
          child: Image.asset(
            'assets/images/cloud4.png',
            width: 220,
            height: 220,
            fit: BoxFit.cover,
          ),
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

class _PremiumButtonState extends State<_PremiumButton> {
  void _handleTap() {
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: Container(
        height: 62,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFDB833),
              Color(0xFFFFC94A),
            ],
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0xFFFDB833),
              blurRadius: 2,
              offset: Offset(0, 3),
            ),
            BoxShadow(
              color: Color(0xFFFFC94A),
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Center(
          child: Text(
            'Commencer',
            textAlign: TextAlign.center,
            style: GoogleFonts.nunito(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: Colors.black87,
              letterSpacing: 1.0,
            ),
          ),
        ),
      ),
    );
  }
}
