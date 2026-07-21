import 'package:flutter/material.dart';
import 'package:lumiconte/main.dart'; // Pour accéder à appSettings.isDarkMode

class TermsOfServicePage extends StatelessWidget {
  const TermsOfServicePage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = appSettings.isDarkMode;

    final backgroundColor =
        isDark ? const Color(0xFF1E1B29) : const Color(0xFFF8F9FA);
    final cardColor = isDark ? const Color(0xFF2D283E) : Colors.white;
    final textColor = isDark ? Colors.white70 : Colors.black87;
    final titleColor = isDark ? Colors.white : Colors.black87;
    const accentColor = Color(0xFFFDB833); // Doré Lumiconte

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Conditions Générales',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: isDark ? Colors.white : Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Conditions Générales d\'Utilisation (CGU)',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: titleColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'En vigueur au 18 juillet 2026',
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.grey.shade500 : Colors.grey.shade600,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 20),
            _buildSection(
              title: '1. Objet et Acceptation des CGU',
              content:
                  'Les présentes Conditions Générales d\'Utilisation ont pour objet de définir les modalités de mise à disposition et d\'utilisation de l\'application mobile Lumiconte. L\'accès et l\'utilisation de l\'application entraînent l\'acceptation expresse et sans réserve des présentes CGU par l\'utilisateur.',
              cardColor: cardColor,
              titleColor: accentColor,
              textColor: textColor,
            ),
            _buildSection(
              title: '2. Accès au Service et Responsabilité Parentale',
              content:
                  'L\'application Lumiconte est destinée à un public d\'enfants, mais sa configuration, la création du compte utilisateur et la souscription aux éventuels services payants doivent obligatoirement être effectuées par un adulte majeur (parent ou représentant légal).\n\nLe titulaire du compte s\'engage à superviser l\'utilisation de l\'application par les mineurs sous sa responsabilité et se porte garant du respect des présentes conditions.',
              cardColor: cardColor,
              titleColor: accentColor,
              textColor: textColor,
            ),
            _buildSection(
              title: '3. Propriété Intellectuelle',
              content:
                  'L\'ensemble des éléments constituant l\'application Lumiconte (notamment les textes des histoires, les illustrations originales, la musique, les fichiers audios, les logos, le design et le code source) est la propriété exclusive de Lumiconte et est protégé par les lois internationales sur le droit d\'auteur et la propriété intellectuelle.\n\nToute reproduction, représentation, modification ou adaptation totale ou partielle de ces contenus, par quelque procédé que ce soit, sans autorisation écrite préalable, est strictly interdite et constitue une contrefaçon.',
              cardColor: cardColor,
              titleColor: accentColor,
              textColor: textColor,
            ),
            _buildSection(
              title: '4. Abonnements, Tarifs et Rétractation',
              content:
                  'L\'accès à l\'intégralité du catalogue d\'histoires peut être soumis à la souscription d\'un abonnement payant. Les tarifs en vigueur sont ceux indiqués directement sur les boutiques d\'applications.\n\nTous les achats, facturations, renouvellements automatiques et demandes de remboursement sont gérés de manière exclusive par les plateformes tierces Apple App Store ou Google Play Store. Conformément aux règles de ces plateformes et à la législation sur les contenus numériques, l\'exécution immédiate du service après paiement entraîne la renonciation au droit de rétractation standard.',
              cardColor: cardColor,
              titleColor: accentColor,
              textColor: textColor,
            ),
            _buildSection(
              title: '5. Protection des Données Personnelles (RGPD)',
              content:
                  'Lumiconte s\'engage à respecter la vie privée de ses utilisateurs et la confidentialité des données, conformément au Règlement Général sur la Protection des Données (RGPD). Les seules données collectées sont celles strictement nécessaires au bon fonctionnement de l\'application (création du compte parent, pseudonymes et âges des profils enfants pour adapter les lectures, statistiques de progression de lecture).\n\nAucune donnée personnelle n\'est vendue ou transmise à des tiers. Pour en savoir plus, l\'utilisateur est invité à consulter notre Politique de Confidentialité.',
              cardColor: cardColor,
              titleColor: accentColor,
              textColor: textColor,
            ),
            _buildSection(
              title: '6. Limitation de Responsabilité',
              content:
                  'Lumiconte met en œuvre tous les moyens raisonnables pour assurer un accès continu et de qualité à l\'application. Cependant, l\'éditeur ne peut être tenu responsable des interruptions de service dues à des opérations de maintenance, à des pannes de réseau internet, ou à des incompatibilités matérielles liées à l\'appareil de l\'utilisateur.\n\nDe plus, la gestion des temps d\'écran de l\'enfant reste sous la responsabilité exclusive du parent.',
              cardColor: cardColor,
              titleColor: accentColor,
              textColor: textColor,
            ),
            _buildSection(
              title: '7. Modification des CGU et Droit Applicable',
              content:
                  'Lumiconte se réserve le droit de modifier les présentes CGU à tout moment afin de les adapter aux évolutions de l\'application ou de la législation. L\'utilisation continue de l\'application après modification vaut acceptation des nouvelles CGU.\n\nLes présentes conditions sont régies par le droit français. En cas de litige et à défaut d\'accord amiable, les tribunaux français seront seuls compétents.',
              cardColor: cardColor,
              titleColor: accentColor,
              textColor: textColor,
            ),
            const SizedBox(height: 20),
            Center(
              child: Text(
                'Contact support : support@lumiconte.com',
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? Colors.grey.shade500 : Colors.grey.shade600,
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
    required String title,
    required String content,
    required Color cardColor,
    required Color titleColor,
    required Color textColor,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.015),
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
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: titleColor,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            content,
            style: TextStyle(
              fontSize: 13.5,
              color: textColor,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}