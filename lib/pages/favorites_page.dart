import 'package:flutter/material.dart';
import 'package:lumiconte/theme/app_theme.dart';

class FavoritesPage extends StatelessWidget {
  final String? profileId;

  const FavoritesPage({
    super.key,
    this.profileId,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardColor = AppTheme.getCardColor(context);
    final subtitleColor = theme.colorScheme.onSurface.withValues(alpha: 0.6);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Mes Favoris',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: profileId == null || profileId!.isEmpty
            ? Center(
                child: Text(
                  'Aucun profil sélectionné.',
                  style: TextStyle(color: subtitleColor, fontSize: 16),
                ),
              )
            : CustomScrollView(
                slivers: [
                  // État par défaut : Aucun favori enregistré pour le moment
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: cardColor,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.bookmark_border_rounded,
                                size: 48,
                                color: AppTheme.accentColor, // Doré Lumiconte
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'Pas encore de favoris',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Enregistrez vos histoires préférées pour les retrouver facilement ici !',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: subtitleColor,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}