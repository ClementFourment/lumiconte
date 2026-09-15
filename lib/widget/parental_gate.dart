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
  static const _digitWords = [
    'zéro',
    'un',
    'deux',
    'trois',
    'quatre',
    'cinq',
    'six',
    'sept',
    'huit',
    'neuf',
  ];
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
              'Réservé aux parents',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Pour continuer, touchez ces chiffres dans l\'ordre :',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _challenge.map((d) => _digitWords[d]).join('  ·  '),
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
                        'Ce n\'est pas ça. Nouveau code ci-dessus.',
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
                'Annuler',
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
