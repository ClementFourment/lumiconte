import 'package:flutter/material.dart';
import 'package:lumiconte/theme/app_theme.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardColor = AppTheme.getCardColor(context);
    final subtitleColor = theme.colorScheme.onSurface.withValues(alpha: 0.6);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Confidentialité',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Politique de Confidentialité',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Dernière mise à jour : Juillet 2026',
              style: TextStyle(
                fontSize: 13,
                color: subtitleColor,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 20),
            _buildSection(
              context: context,
              title: '1. Collecte des Données (Compte Parent)',
              content:
                  'Lors de la création de votre compte, nous collectons uniquement les informations nécessaires à l\'authentification et à la sécurisation de votre accès :\n• Votre adresse e-mail.\n• Un mot de passe (crypté et invisible pour nous).\n\nCes données permettent de synchroniser vos profils et abonnements sur vos différents appareils.',
              cardColor: cardColor,
            ),
            _buildSection(
              context: context,
              title: '2. Protection des Profils Enfants',
              content:
                  'Lumiconte est conçu pour préserver l\'anonymat complet des enfants. Pour créer un profil enfant, nous demandons uniquement :\n• Un prénom ou un pseudonyme (au choix du parent).\n• Un âge (pour suggérer du contenu adapté).\n\nNous ne collectons aucune donnée d\'identité réelle, aucune donnée de géolocalisation, et aucun identifiant publicitaire sur les profils enfants.',
              cardColor: cardColor,
            ),
            _buildSection(
              context: context,
              title: '3. Données de Progression (Firestore)',
              content:
                  'Pour offrir une expérience de lecture continue, l\'application enregistre l\'historique d\'utilisation des profils (histoires lues, temps de lecture, badges obtenus, séries en cours). Ces données sont stockées de manière sécurisée sur les serveurs de notre hébergeur (Firebase/Google Cloud) situé au sein de l\'Union Européenne.',
              cardColor: cardColor,
            ),
            _buildSection(
              context: context,
              title: '4. Non-partage et Tiers',
              content:
                  'La règle est simple : nous ne vendons, n\'échangeons et ne transférons aucune donnée personnelle à des sociétés tierces.\n\nL\'application n\'intègre aucune régie publicitaire commerciale, évitant ainsi tout traçage publicitaire comportemental de vos enfants.',
              cardColor: cardColor,
            ),
            _buildSection(
              context: context,
              title: '5. Vos Droits (RGPD)',
              content:
                  'Conformément à la réglementation européenne (RGPD), vous disposez d\'un droit d\'accès, de rectification et d\'effacement complet de vos données personnelles. Vous pouvez demander la suppression définitive de votre compte et de l\'ensemble des profils associés à tout moment, directement depuis les réglages de l\'application ou en contactant notre support.',
              cardColor: cardColor,
            ),
            _buildSection(
              context: context,
              title: '6. Sécurité des Données',
              content:
                  'Nous appliquons des mesures de sécurité strictes (protocoles de cryptage de flux, règles d\'accès Firestore restrictives) pour protéger vos données contre tout accès, modification ou divulgation non autorisés.',
              cardColor: cardColor,
            ),
            const SizedBox(height: 20),
            Center(
              child: Text(
                'Contact délégué protection des données : privacy@lumiconte.com',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: subtitleColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required BuildContext context,
    required String title,
    required String content,
    required Color cardColor,
  }) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.accentColor, // Doré Lumiconte
            ),
          ),
          const SizedBox(height: 10),
          Text(
            content,
            style: TextStyle(
              fontSize: 13.5,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.85),
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}