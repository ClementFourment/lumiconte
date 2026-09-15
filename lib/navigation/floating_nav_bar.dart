import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:lumiconte/theme/app_theme.dart';

class FloatingNavItem {
  final String label;
  final IconData? icon;

  /// Image ronde (avatar de l'enfant) affichée à la place de l'icône.
  final ImageProvider? avatar;

  const FloatingNavItem({required this.label, this.icon, this.avatar})
      : assert(icon != null || avatar != null);
}

/// Barre de navigation en forme de pilule qui flotte au-dessus du contenu.
/// À utiliser avec `Scaffold(extendBody: true)` : les pages reçoivent alors
/// la hauteur de la barre dans `MediaQuery.paddingOf(context).bottom`.
class FloatingNavBar extends StatelessWidget {
  final List<FloatingNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  const FloatingNavBar({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final barColor = (isDark ? AppTheme.darkCard : Colors.white)
        .withValues(alpha: isDark ? 0.82 : 0.88);

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.12),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(32),
            child: BackdropFilter(
              // Le ciel reste deviné derrière la barre
              filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
              child: Container(
                height: 72,
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: barColor,
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(
                    color: AppTheme.accentColor.withValues(alpha: 0.18),
                  ),
                ),
                child: Row(
                  children: [
                    for (int i = 0; i < items.length; i++)
                      Expanded(
                        child: _NavButton(
                          item: items[i],
                          selected: i == currentIndex,
                          onTap: () => onTap(i),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final FloatingNavItem item;
  final bool selected;
  final VoidCallback onTap;

  const _NavButton({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final color =
        selected ? AppTheme.accentColor : onSurface.withValues(alpha: 0.6);

    final Widget visual = item.avatar != null
        ? AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: selected ? AppTheme.accentColor : Colors.transparent,
            ),
            // 2 + 24 + 2 = 28 px, comme les icônes : libellés alignés
            child: CircleAvatar(radius: 12, backgroundImage: item.avatar),
          )
        : Icon(item.icon, size: 28, color: color);

    return Semantics(
      selected: selected,
      button: true,
      label: item.label,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            color: selected
                ? AppTheme.accentColor.withValues(alpha: 0.16)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(26),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Petit rebond de l'onglet choisi
              AnimatedScale(
                scale: selected ? 1.12 : 1.0,
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutBack,
                child: visual,
              ),
              const SizedBox(height: 3),
              Text(
                item.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
