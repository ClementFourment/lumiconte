import 'dart:async';
import 'dart:math' as math;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lumiconte/models/badge_model.dart';
import 'package:lumiconte/models/story_model.dart';
import 'package:lumiconte/services/badge_service.dart';
import 'package:lumiconte/theme/app_theme.dart';
import 'package:lumiconte/widget/badge_medal.dart';
import 'package:lumiconte/widget/mascot.dart';

/// Surveille les badges du profil et fête chaque nouveau badge dès qu'il est
/// gagné, quel que soit l'écran affiché (y compris pendant une histoire).
class BadgeWatcher extends StatefulWidget {
  final String profileId;
  final List<StoryModel> stories;
  final Widget child;

  const BadgeWatcher({
    super.key,
    required this.profileId,
    required this.stories,
    required this.child,
  });

  @override
  State<BadgeWatcher> createState() => _BadgeWatcherState();
}

class _BadgeWatcherState extends State<BadgeWatcher> {
  final BadgeService _badgeService = BadgeService();
  final String? _uid = FirebaseAuth.instance.currentUser?.uid;
  StreamSubscription<BadgeProgress>? _subscription;

  /// Badges déjà connus (enregistrés ou déjà fêtés) : ils ne sont pas refêtés.
  Set<String>? _known;
  final List<BadgeModel> _queue = [];
  bool _showing = false;

  @override
  void initState() {
    super.initState();
    final uid = _uid;
    if (uid == null) return;

    _subscription = _badgeService
        .watch(uid, widget.profileId, widget.stories)
        .listen(_onProgress,
            onError: (e) => debugPrint('Erreur suivi badges : $e'));
  }

  void _onProgress(BadgeProgress progress) {
    // Copie : `known` est modifié plus bas, `progress.stored` doit rester intact
    final known = _known ??= {...progress.stored};
    final newIds = progress.earned.difference(known);
    if (newIds.isEmpty) return;

    known.addAll(newIds);
    final toStore = newIds.difference(progress.stored);
    if (toStore.isNotEmpty) {
      _badgeService.award(_uid!, widget.profileId, toStore);
    }

    // Ordre de la liste des badges, pour une célébration prévisible
    _queue.addAll(BadgeModel.all.where((b) => newIds.contains(b.id)));
    _showNext();
  }

  Future<void> _showNext() async {
    if (_showing || _queue.isEmpty || !mounted) return;
    _showing = true;
    final badge = _queue.removeAt(0);
    await showBadgeCelebration(context, badge);
    _showing = false;
    _showNext();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

/// Affiche un badge en grand. Avec [celebrate], c'est la fête du déblocage.
Future<void> showBadgeCelebration(
  BuildContext context,
  BadgeModel badge, {
  bool celebrate = true,
}) {
  return showGeneralDialog(
    context: context,
    useRootNavigator: true,
    barrierDismissible: true,
    barrierLabel: 'Fermer',
    barrierColor: Colors.black.withValues(alpha: 0.6),
    transitionDuration: const Duration(milliseconds: 250),
    pageBuilder: (context, _, __) =>
        _BadgeCelebrationDialog(badge: badge, celebrate: celebrate),
    transitionBuilder: (context, animation, _, child) =>
        FadeTransition(opacity: animation, child: child),
  );
}

class _BadgeCelebrationDialog extends StatefulWidget {
  final BadgeModel badge;
  final bool celebrate;

  const _BadgeCelebrationDialog({required this.badge, required this.celebrate});

  @override
  State<_BadgeCelebrationDialog> createState() =>
      _BadgeCelebrationDialogState();
}

class _BadgeCelebrationDialogState extends State<_BadgeCelebrationDialog>
    with TickerProviderStateMixin {
  late final AnimationController _pop = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );
  late final AnimationController _sparkle = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 3000),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context) || !widget.celebrate) {
      _pop.value = 1;
      _sparkle.stop();
    } else if (!_pop.isAnimating && _pop.value == 0) {
      _pop.forward();
      _sparkle.repeat();
    }
  }

  @override
  void dispose() {
    _pop.dispose();
    _sparkle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;
    final badge = widget.badge;

    final scale = CurvedAnimation(parent: _pop, curve: Curves.elasticOut);
    final medal = ScaleTransition(
      scale: scale,
      child: BadgeMedal(badge: badge, earned: true, size: 128),
    );

    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Material(
            color: AppTheme.getCardColor(context),
            borderRadius: BorderRadius.circular(28),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.celebrate)
                    Text(
                      'Nouveau badge !',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: AppTheme.accentColor,
                        letterSpacing: 0.5,
                      ),
                    ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: 200,
                    height: 180,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        if (widget.celebrate)
                          Positioned.fill(
                            child: CustomPaint(
                              painter: _SparklePainter(
                                animation: _sparkle,
                                color: badge.color,
                              ),
                            ),
                          ),
                        medal,
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    badge.name,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall
                        ?.copyWith(color: onSurface),
                  ),
                  const SizedBox(height: 16),
                  Mascot(
                    size: 64,
                    message: widget.celebrate
                        ? 'Bravo ! ${badge.earnedText}'
                        : badge.earnedText,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppTheme.accentColor,
                        foregroundColor: const Color(0xFF1E1B29),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      child: Text(
                        widget.celebrate ? 'Super !' : 'Fermer',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: const Color(0xFF1E1B29),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Étoiles qui scintillent en tournant doucement autour de la médaille.
class _SparklePainter extends CustomPainter {
  final Animation<double> animation;
  final Color color;

  _SparklePainter({required this.animation, required this.color})
      : super(repaint: animation);

  static const int _count = 10;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final t = animation.value;
    final paint = Paint();

    for (var i = 0; i < _count; i++) {
      final angle = (i / _count + t * 0.15) * 2 * math.pi;
      final radius = size.shortestSide * (i.isEven ? 0.46 : 0.38);
      final twinkle = (math.sin((t * 2 + i / _count) * 2 * math.pi) + 1) / 2;
      final starSize = 3.0 + twinkle * 4;

      paint.color = (i.isEven ? AppTheme.accentColor : color)
          .withValues(alpha: 0.35 + twinkle * 0.65);
      _drawStar(
        canvas,
        center + Offset(math.cos(angle), math.sin(angle)) * radius,
        starSize,
        paint,
      );
    }
  }

  void _drawStar(Canvas canvas, Offset c, double r, Paint paint) {
    final path = Path();
    for (var i = 0; i < 8; i++) {
      final a = i * math.pi / 4 - math.pi / 2;
      final d = i.isEven ? r : r * 0.35;
      final p = c + Offset(math.cos(a), math.sin(a)) * d;
      i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
    }
    canvas.drawPath(path..close(), paint);
  }

  @override
  bool shouldRepaint(covariant _SparklePainter oldDelegate) =>
      oldDelegate.color != color;
}
