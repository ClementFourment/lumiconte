import 'package:flutter/material.dart';
import 'package:lumiconte/services/auth_service.dart';
import 'package:lumiconte/services/profile_service.dart';
import 'package:go_router/go_router.dart';
import 'dart:math' as math;
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io' show Platform;

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  final AuthService _authService = AuthService();
  final ProfileService _profileService = ProfileService();
  bool _isLoading = false;
  late AnimationController _mainController;
  late AnimationController _particleController;
  bool get canUseAppleSignIn {
    return Platform.isIOS || Platform.isMacOS;
  }

  bool _isLoginMode = true;
  late AnimationController _glowController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 100),
    )..repeat();

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);

    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 100),
    )..repeat();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _mainController.dispose();
    _particleController.dispose();
    _glowController.dispose();

    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Redirige l'utilisateur vers la création ou la sélection de profil
  Future<void> _handleProfileRouting(String uid) async {
    final profiles = await _profileService.getUserProfiles(uid);
    if (!mounted) return;

    if (profiles.isEmpty) {
      context.go('/create-profile');
    } else {
      context.go('/manage-profiles');
    }
  }

  // ---------------------------------------------------------------------------
  // CONNEXION GOOGLE
  // ---------------------------------------------------------------------------
  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      final userModel = await _authService.signInWithGoogle();
      final uid = userModel?.uid ?? FirebaseAuth.instance.currentUser?.uid;

      if (uid != null) {
        await _handleProfileRouting(uid);
      }
    } catch (e) {
      debugPrint("Erreur Google Sign In : $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Échec de la connexion avec Google")),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // ---------------------------------------------------------------------------
  // CONNEXION APPLE
  // ---------------------------------------------------------------------------
  Future<void> _signInWithApple() async {
    setState(() => _isLoading = true);
    try {
      final userModel = await _authService.signInWithApple();
      final uid = userModel?.uid ?? FirebaseAuth.instance.currentUser?.uid;

      if (uid != null) {
        await _handleProfileRouting(uid);
      }
    } catch (e) {
      debugPrint("Erreur Apple Sign In : $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Échec de la connexion avec Apple")),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // ---------------------------------------------------------------------------
  // CONNEXION EMAIL
  // ---------------------------------------------------------------------------
  Future<void> _signInWithEmail() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final userModel = await _authService.signInWithEmail(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      final uid = userModel?.uid ?? FirebaseAuth.instance.currentUser?.uid;

      if (uid != null) {
        await _handleProfileRouting(uid);
      }
    } on FirebaseAuthException catch (e) {
      String message;

      switch (e.code) {
        case 'user-not-found':
          message = "Aucun compte avec cet email";
          break;
        case 'wrong-password':
          message = "Mot de passe incorrect";
          break;
        case 'invalid-email':
          message = "Email invalide";
          break;
        default:
          message = "Erreur de connexion";
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // ---------------------------------------------------------------------------
  // INSCRIPTION EMAIL
  // ---------------------------------------------------------------------------
  Future<void> _signUpWithEmail() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final user = await _authService.signUpWithEmail(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      debugPrint("Compte créé : ${user?.email}");

      if (mounted) {
        context.go('/create-profile');
      }
    } catch (e) {
      debugPrint("Erreur inscription : $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Échec de l'inscription")),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _glowController,
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
                _AnimatedStarsLayer(t: _mainController.value),
                _ParticlesLayer(t: _particleController.value),
                Center(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Transform.scale(
                            scale: 0.8 + (_glowController.value * 0.1),
                            child: Container(
                              width: 70,
                              height: 70,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFFFDB833),
                                    Color(0xFFFFC94A),
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFFDB833)
                                        .withValues(alpha: 0.5),
                                    blurRadius: 30,
                                    spreadRadius: 8,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.auto_stories_rounded,
                                size: 35,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),
                          const Text(
                            "Lumiconte",
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: -0.8,
                            ),
                          ),
                          const SizedBox(height: 32),
                          _buildToggleButton(),
                          const SizedBox(height: 32),
                          if (_isLoading)
                            Column(
                              children: [
                                const CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Color(0xFFFDB833),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  _isLoginMode
                                      ? "Connexion en cours..."
                                      : "Inscription en cours...",
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.7),
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            )
                          else
                            Form(
                              key: _formKey,
                              child: Column(
                                children: [
                                  _buildEmailInput(),
                                  const SizedBox(height: 16),
                                  _buildPasswordInput(),
                                  const SizedBox(height: 32),
                                  _buildPrimaryButton(
                                    label: _isLoginMode
                                        ? 'Se connecter'
                                        : 'S\'inscrire',
                                    onPressed: _isLoginMode
                                        ? _signInWithEmail
                                        : _signUpWithEmail,
                                  ),
                                  const SizedBox(height: 32),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Container(
                                          height: 1,
                                          color: Colors.white.withValues(alpha: 0.1),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12),
                                        child: Text(
                                          'ou',
                                          style: TextStyle(
                                            fontSize: 13,
                                            color:
                                                Colors.white.withValues(alpha: 0.5),
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Container(
                                          height: 1,
                                          color: Colors.white.withValues(alpha: 0.1),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 32),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      if (_authService
                                          .getInstance()
                                          .supportsAuthenticate())
                                        _buildSocialIconButton(
                                          type: 'google',
                                          text: 'Continuer avec Google',
                                          onPressed: _signInWithGoogle,
                                        ),
                                      const SizedBox(height: 12),
                                      if (canUseAppleSignIn)
                                        _buildSocialIconButton(
                                          type: 'apple',
                                          text: 'Continuer avec Apple',
                                          onPressed: _signInWithApple,
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          const SizedBox(height: 48),
                          Text(
                            'En continuant, tu acceptes nos conditions\nd\'utilisation et notre politique de confidentialité',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.white.withValues(alpha: 0.4),
                              height: 1.5,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildToggleButton() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _isLoginMode = true),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: _isLoginMode
                      ? const Color(0xFFFDB833).withValues(alpha: 0.2)
                      : Colors.transparent,
                ),
                child: Text(
                  'Se connecter',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _isLoginMode
                        ? const Color(0xFFFDB833)
                        : Colors.white.withValues(alpha: 0.5),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _isLoginMode = false),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: !_isLoginMode
                      ? const Color(0xFFFDB833).withValues(alpha: 0.2)
                      : Colors.transparent,
                ),
                child: Text(
                  'S\'inscrire',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: !_isLoginMode
                        ? const Color(0xFFFDB833)
                        : Colors.white.withValues(alpha: 0.5),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmailInput() {
    return TextFormField(
      controller: _emailController,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 15,
      ),
      decoration: InputDecoration(
        hintText: 'Email',
        hintStyle: TextStyle(
          color: Colors.white.withValues(alpha: 0.4),
          fontSize: 15,
        ),
        prefixIcon: Icon(
          Icons.mail_outline_rounded,
          color: Colors.white.withValues(alpha: 0.5),
          size: 20,
        ),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.08),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Colors.white.withValues(alpha: 0.15),
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Colors.white.withValues(alpha: 0.15),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFFFDB833),
            width: 1.5,
          ),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      keyboardType: TextInputType.emailAddress,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Email requis';
        }
        if (!value.contains('@')) {
          return 'Email invalide';
        }
        return null;
      },
    );
  }

  Widget _buildPasswordInput() {
    return TextFormField(
      controller: _passwordController,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 15,
      ),
      obscureText: true,
      decoration: InputDecoration(
        hintText: 'Mot de passe',
        hintStyle: TextStyle(
          color: Colors.white.withValues(alpha: 0.4),
          fontSize: 15,
        ),
        prefixIcon: Icon(
          Icons.lock_outline_rounded,
          color: Colors.white.withValues(alpha: 0.5),
          size: 20,
        ),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.08),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Colors.white.withValues(alpha: 0.15),
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Colors.white.withValues(alpha: 0.15),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFFFDB833),
            width: 1.5,
          ),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Mot de passe requis';
        }
        if (value.length < 6) {
          return 'Au minimum 6 caractères';
        }
        return null;
      },
    );
  }

  Widget _buildPrimaryButton({
    required String label,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: double.infinity,
      height: 52,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFFDB833),
            Color(0xFFFFC94A),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFDB833).withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Center(
            child: Text(
              label.toUpperCase(),
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w900,
                color: Colors.black87,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSocialIconButton({
    required String type,
    required String text,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: 220,
      child: Material(
        color: Colors.transparent,
        child: OutlinedButton.icon(
          onPressed: onPressed,
          icon: Image.asset(
            'assets/images/${type}_logo.png',
            height: 18,
          ),
          label: Text(text),
        ),
      ),
    );
  }
}

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
      40,
      (i) => Offset(
        (math.sin(i * 2.7) * 0.5 + 0.5) * size.width,
        (math.cos(i * 3.3) * 0.5 + 0.35) * size.height,
      ),
    );

    for (int i = 0; i < stars.length; i++) {
      final p = stars[i];
      final twinkle = (math.sin(t * 3.5 + i * 0.4) + 1) / 2;

      final paint = Paint()
        ..color = Colors.white.withValues(alpha: 0.25 + twinkle * 0.55);

      final radius = (i % 4 == 0) ? 1.8 : 0.95;
      canvas.drawCircle(p, radius, paint);

      if (twinkle > 0.6) {
        final glowPaint = Paint()
          ..color = Colors.white.withValues(alpha: (twinkle - 0.6) * 0.3)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
        canvas.drawCircle(p, radius * 3, glowPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
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
      15,
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

      y = y + (math.sin(t * speed * 2 * math.pi) * 15);

      final opacity = 0.3 + (math.sin(t * speed * 3 + y) + 1) / 2 * 0.4;

      final paint = Paint()..color = Colors.white.withValues(alpha: opacity * 0.6);

      canvas.drawCircle(Offset(x, y), 1.5, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}