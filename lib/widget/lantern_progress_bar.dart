import 'package:flutter/material.dart';

class LanternProgressBar extends StatelessWidget {
  final double progress; // 0.0 -> 1.0

  const LanternProgressBar({
    super.key,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    const int totalMainDots = 4;
    const int dashesBetweenDots = 3;

    final int totalSteps = totalMainDots * (dashesBetweenDots + 1);
    final int currentStep =
        (progress * totalSteps).round().clamp(0, totalSteps);

    final bool isSunActive = progress >= 0.95;

    return Row(
      children: [
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(totalMainDots, (dotIndex) {
              final int mainDotStep = dotIndex * (dashesBetweenDots + 1) + 1;
              final bool isDotActive = currentStep >= mainDotStep;

              return Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDotActive
                            ? const Color(0xFFFFC107)
                            : Colors.white.withAlpha(50),
                        boxShadow: isDotActive
                            ? const [
                                BoxShadow(
                                  color: Color(0xFFFFB300),
                                  blurRadius: 4,
                                  spreadRadius: 1,
                                ),
                              ]
                            : null,
                      ),
                    ),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(dashesBetweenDots, (dashIndex) {
                          final int dashStep = mainDotStep + dashIndex + 1;
                          final bool isDashActive = currentStep >= dashStep;

                          return Container(
                            width: 2,
                            height: 2,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isDashActive
                                  ? const Color(0xFFFFC107)
                                  : Colors.white.withAlpha(40),
                            ),
                          );
                        }),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
        const SizedBox(width: 2),
        _GlowingLantern(isActive: isSunActive),
      ],
    );
  }
}

class _GlowingLantern extends StatelessWidget {
  final bool isActive;

  const _GlowingLantern({
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: isActive
          ? const BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Color(0xFFFFB300),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ],
            )
          : null,
      child: Icon(
        Icons.light_mode_rounded,
        size: 18,
        color: isActive ? const Color(0xFFFFE082) : Colors.white.withAlpha(80),
      ),
    );
  }
}
