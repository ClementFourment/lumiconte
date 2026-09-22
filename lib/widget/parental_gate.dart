import 'package:lumiconte/l10n/app_localizations.dart';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:lumiconte/theme/app_theme.dart';

/// Contrôle parental exigé par les stores (Apple Kids Category, Google
/// Familles) avant tout accès aux réglages, au compte, aux achats ou aux
/// actions sensibles.
///
/// L'adulte doit taper trois chiffres écrits en toutes lettres : un jeune
/// enfant qui ne sait pas encore bien lire ne peut pas le passer par hasard.
/// Retourne `true` si le contrôle est réussi.
Future<bool> showParentalGate(BuildContext context) async {
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (_) => const _ParentalGateDialog(),
  );
  return result ?? false;
}

class _ParentalGateDialog extends StatefulWidget {
  const _ParentalGateDialog();

  @override
  State<_ParentalGateDialog> createState() => _ParentalGateDialogState();
}

class _ParentalGateDialogState extends State<_ParentalGateDialog> {
  /// Le chiffre écrit en toutes lettres, dans la langue du parent : la porte
  /// ne s'ouvre qu'à quelqu'un qui sait lire la consigne.
  static String _digitWord(AppLocalizations l10n, int digit) => switch (digit) {
        0 => l10n.digitZero,
        1 => l10n.digitOne,
        2 => l10n.digitTwo,
        3 => l10n.digitThree,
        4 => l10n.digitFour,
        5 => l10n.digitFive,
        6 => l10n.digitSix,
        7 => l10n.digitSeven,
        8 => l10n.digitEight,
        _ => l10n.digitNine,
      };
  static const _codeLength = 3;

  final Random _random = Random();
  late List<int> _challenge;
  final List<int> _input = [];
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _newChallenge();
  }

  void _newChallenge() {
    _challenge = List.generate(_codeLength, (_) => _random.nextInt(10));
    _input.clear();
  }

  void _onDigit(int digit) {
    if (_input.length >= _codeLength) return;
    setState(() {
      _hasError = false;
      _input.add(digit);
    });

    if (_input.length == _codeLength) {
      final success =
          List.generate(_codeLength, (i) => _input[i] == _challenge[i])
              .every((ok) => ok);
      if (success) {
        Navigator.of(context).pop(true);
      } else {
        // Nouveau code à chaque erreur pour empêcher les essais au hasard
        setState(() {
          _hasError = true;
          _newChallenge();
        });
      }
    }
  }

  void _onBackspace() {
    if (_input.isEmpty) return;
    setState(() => _input.removeLast());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;

    return Dialog(
      backgroundColor: AppTheme.getCardColor(context),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.lock_rounded,
                size: 36, color: AppTheme.accentColor),
            const SizedBox(height: 12),
            Text(
              l10n.parentsOnly,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.parentalGateInstruction,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _challenge.map((d) => _digitWord(l10n, d)).join('  ·  '),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppTheme.accentColor,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_codeLength, (i) {
                final filled = i < _input.length;
                return Container(
                  width: 14,
                  height: 14,
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: filled
                        ? AppTheme.accentColor
                        : onSurface.withValues(alpha: 0.15),
                  ),
                );
              }),
            ),
            SizedBox(
              height: 28,
              child: Center(
                child: _hasError
                    ? Text(
                        l10n.parentalGateWrong,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.red.shade400,
                        ),
                      )
                    : null,
              ),
            ),
            _buildKeypad(onSurface),
            const SizedBox(height: 4),
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                l10n.cancel,
                style: TextStyle(color: onSurface.withValues(alpha: 0.7)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKeypad(Color onSurface) {
    Widget key({required Widget child, VoidCallback? onTap}) {
      return Padding(
        padding: const EdgeInsets.all(5),
        child: Material(
          color: onSurface.withValues(alpha: onTap == null ? 0 : 0.07),
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onTap,
            child: SizedBox(width: 60, height: 60, child: Center(child: child)),
          ),
        ),
      );
    }

    Widget digitKey(int digit) => key(
          onTap: () => _onDigit(digit),
          child: Text(
            '$digit',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: onSurface,
            ),
          ),
        );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final row in const [
          [1, 2, 3],
          [4, 5, 6],
          [7, 8, 9],
        ])
          Row(
            mainAxisSize: MainAxisSize.min,
            children: row.map(digitKey).toList(),
          ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            key(child: const SizedBox.shrink()),
            digitKey(0),
            key(
              onTap: _onBackspace,
              child: Icon(Icons.backspace_outlined, color: onSurface),
            ),
          ],
        ),
      ],
    );
  }
}
