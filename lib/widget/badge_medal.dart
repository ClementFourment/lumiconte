import 'package:flutter/material.dart';
import 'package:lumiconte/models/badge_model.dart';

/// Médaille d'un badge : colorée une fois gagnée, silhouette mystère sinon.
class BadgeMedal extends StatelessWidget {
  final BadgeModel badge;
  final bool earned;
  final double size;

  const BadgeMedal({
    super.key,
    required this.badge,
    required this.earned,
    this.size = 76,
  });

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;

    if (!earned) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: onSurface.withValues(alpha: 0.06),
          border: Border.all(
            color: badge.color.withValues(alpha: 0.35),
            width: 2,
          ),
        ),
        child: Icon(
          Icons.question_mark_rounded,
          size: size * 0.45,
          color: badge.color.withValues(alpha: 0.55),
        ),
      );
    }

    final light = Color.lerp(badge.color, Colors.white, 0.35)!;
    final dark = Color.lerp(badge.color, Colors.black, 0.15)!;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [light, dark],
        ),
        border: Border.all(color: Colors.white.withValues(alpha: 0.7), width: 3),
        boxShadow: [
          BoxShadow(
            color: badge.color.withValues(alpha: 0.45),
            blurRadius: size * 0.25,
          ),
        ],
      ),
      child: Icon(badge.icon, size: size * 0.5, color: Colors.white),
    );
  }
}
