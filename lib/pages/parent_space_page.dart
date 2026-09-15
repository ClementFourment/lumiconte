import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:lumiconte/main.dart';
import 'package:lumiconte/models/profile_model.dart';
import 'package:lumiconte/models/reading_progress_model.dart';
import 'package:lumiconte/models/settings_model.dart';
import 'package:lumiconte/pages/feedback_page.dart';
import 'package:lumiconte/pages/manage_profiles_page.dart';
import 'package:lumiconte/pages/privacy_page.dart';
import 'package:lumiconte/pages/settings_page.dart';
import 'package:lumiconte/pages/terms_page.dart';
import 'package:lumiconte/services/auth_service.dart';
import 'package:lumiconte/theme/app_theme.dart';
import 'package:lumiconte/utils/reading_stats.dart';

/// Espace réservé aux adultes, ouvert uniquement après le contrôle parental
/// (voir `showParentalGate`). Regroupe le suivi, les réglages, le compte et
/// tout ce qui sort du parcours de lecture de l'enfant.
class ParentSpacePage extends StatefulWidget {
  final String profileId;

  const ParentSpacePage({
    super.key,
    required this.profileId,
  });

  @override
  State<ParentSpacePage> createState() => _ParentSpacePageState();
}

class _ParentSpacePageState extends State<ParentSpacePage> {
  final AuthService _authService = AuthService();
  final String? _uid = FirebaseAuth.instance.currentUser?.uid;

  late final DocumentReference _profileDoc;
  late final CollectionReference _settingsCollection;
  late final Stream<DocumentSnapshot> _profileStream;
  late final Stream<QuerySnapshot> _progressStream;
  late final Stream<QuerySnapshot> _settingsStream;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (_uid == null) return;

    _profileDoc = FirebaseFirestore.instance
        .collection('users')
        .doc(_uid)
        .collection('profiles')
        .doc(widget.profileId);
    _settingsCollection = _profileDoc.collection('settings');

    _profileStream = _profileDoc.snapshots();
    _progressStream = _profileDoc.collection('readingProgress').snapshots();
    _settingsStream = _settingsCollection.snapshots();
  }

  Future<void> _updateSetting(String docId, String key, dynamic value) async {
    try {
      await _settingsCollection.doc(docId).update({key: value});
    } catch (e) {
      debugPrint("Erreur lors de la mise à jour du setting: $e");
    }
  }

  Future<void> _toggleNotifications(bool value) async {
    // La demande d'autorisation système se fait ici, côté parent, et non
    // sur l'écran d'accueil de l'enfant
    if (value) await appSettings.requestNotificationPermissions();
    await appSettings.toggleNotifications(value);
  }

  Future<void> _handleSignOut() async {
    setState(() => _isLoading = true);
    try {
      await _authService.signOut();
      if (mounted) Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur : $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleDeleteAccount() async {
    // Vérifié AVANT d'effacer quoi que ce soit : sinon Firebase refuserait de
    // supprimer le compte après que les données ont déjà disparu
    if (!_authService.canDeleteAccountNow) {
      final reconnect = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Reconnexion nécessaire'),
          content: const Text(
            'Par sécurité, la suppression du compte demande une connexion '
            'récente. Vous allez être déconnecté : reconnectez-vous, puis '
            'revenez ici pour supprimer le compte.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Se déconnecter'),
            ),
          ],
        ),
      );
      if (reconnect == true) await _handleSignOut();
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer le compte ?'),
        content: const Text(
          'Tous les profils, la progression, les récompenses et les réglages '
          'seront définitivement effacés. Cette action est irréversible.\n\n'
          'Si vous avez un abonnement, pensez à le résilier depuis '
          'l\'App Store ou Google Play : supprimer le compte ne l\'arrête pas.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Supprimer définitivement'),
          ),
        ],
      ),
    );
    if (confirm != true || !mounted) return;

    setState(() => _isLoading = true);
    try {
      await _authService.deleteAccount();
      if (mounted) Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la suppression : $e')),
        );
      }
    }
  }

  void _push(Widget page) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Espace parents'),
      ),
      body: _uid == null
          ? Center(
              child: Text('Utilisateur non connecté.',
                  style: TextStyle(color: theme.colorScheme.onSurface)),
            )
          : _isLoading
              ? Center(
                  child: CircularProgressIndicator(
                      color: theme.colorScheme.primary),
                )
              : _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    final theme = Theme.of(context);

    return StreamBuilder<DocumentSnapshot>(
      stream: _profileStream,
      builder: (context, profileSnapshot) {
        final profileData =
            profileSnapshot.data?.data() as Map<String, dynamic>?;
        final String? profileName = profileData == null
            ? null
            : ProfileModel.fromMap(profileData, profileSnapshot.data!.id, _uid!)
                .name;

        return StreamBuilder<QuerySnapshot>(
          stream: _progressStream,
          builder: (context, progressSnapshot) {
            final int storiesReadCount = progressSnapshot.hasData
                ? progressSnapshot.data!.docs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>?;
                    // Une histoire est lue quand sa morale a été débloquée
                    return data != null &&
                        ReadingProgressModel.moraleUnlockedFrom(data);
                  }).length
                : 0;

            return StreamBuilder<QuerySnapshot>(
              stream: _settingsStream,
              builder: (context, settingsSnapshot) {
                String currentLangCode = 'fr';
                String settingsDocId = '';
                String timeDisplay = '0 min';
                int streak = 0;

                if (settingsSnapshot.hasData &&
                    settingsSnapshot.data!.docs.isNotEmpty) {
                  final settingsDoc = settingsSnapshot.data!.docs.first;
                  settingsDocId = settingsDoc.id;
                  final settings = SettingsModel.fromMap(
                    settingsDoc.data() as Map<String, dynamic>? ?? {},
                    settingsDoc.id,
                  );
                  currentLangCode = settings.language;
                  timeDisplay = formatReadingTime(settings.totalReadingTime);
                  streak = currentStreak(settings);
                }

                return ListView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
                  children: [
                    // Section Suivi
                    _buildSectionTitle(
                      context,
                      profileName == null
                          ? 'Suivi de lecture'
                          : 'Suivi de lecture de $profileName',
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _buildStatCard(
                            context, 'Histoires\nlues', '$storiesReadCount'),
                        _buildStatCard(
                            context, 'Temps de\nlecture', timeDisplay),
                        _buildStatCard(
                          context,
                          'Lecture\nd\'affilée',
                          formatStreak(streak),
                          icon: Icons.local_fire_department_rounded,
                          iconColor: streak == 0
                              ? theme.colorScheme.onSurface
                                  .withValues(alpha: 0.3)
                              : Colors.deepOrange,
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),

                    // Section Préférences
                    _buildSectionTitle(context, 'Préférences'),
                    const SizedBox(height: 8),
                    _buildCard(context, [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 4.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Langue',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                            DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: currentLangCode,
                                icon: Icon(
                                  Icons.arrow_forward_ios,
                                  size: 14,
                                  color: theme.colorScheme.onSurface
                                      .withValues(alpha: 0.4),
                                ),
                                style: TextStyle(
                                  fontSize: 14,
                                  color: theme.colorScheme.onSurface,
                                ),
                                dropdownColor: AppTheme.getCardColor(context),
                                onChanged: (String? newValue) {
                                  if (newValue != null &&
                                      settingsDocId.isNotEmpty) {
                                    _updateSetting(
                                        settingsDocId, 'language', newValue);
                                  }
                                },
                                items: const [
                                  DropdownMenuItem(
                                      value: 'fr', child: Text('Français  ')),
                                  DropdownMenuItem(
                                      value: 'en', child: Text('English  ')),
                                  DropdownMenuItem(
                                      value: 'es', child: Text('Español  ')),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      ValueListenableBuilder<bool>(
                        valueListenable: appSettings.notificationsNotifier,
                        builder: (context, isNotificationsEnabled, child) {
                          return _buildSwitchTile(
                            context,
                            'Rappels de lecture',
                            value: isNotificationsEnabled,
                            onChanged: _toggleNotifications,
                          );
                        },
                      ),
                      ValueListenableBuilder<bool>(
                        valueListenable: appSettings.themeNotifier,
                        builder: (context, isDarkMode, child) {
                          return _buildSwitchTile(
                            context,
                            'Mode nuit',
                            value: isDarkMode,
                            onChanged: (newValue) => appSettings.toggleDarkMode(
                                widget.profileId, newValue),
                          );
                        },
                      ),
                    ]),
                    const SizedBox(height: 24),

                    // Section Profils & lecture
                    _buildSectionTitle(context, 'Profils et lecture'),
                    const SizedBox(height: 8),
                    _buildCard(context, [
                      _buildListTile(
                        context,
                        'Gérer les profils',
                        icon: Icons.people_outline,
                        onTap: () =>
                            _push(const ManageProfilesPage(editMode: true)),
                      ),
                      _buildListTile(
                        context,
                        'Paramètres de lecture',
                        icon: Icons.menu_book_outlined,
                        onTap: () =>
                            _push(SettingsPage(profileId: widget.profileId)),
                      ),
                    ]),
                    const SizedBox(height: 24),

                    // Section Assistance
                    _buildSectionTitle(context, 'Assistance et informations'),
                    const SizedBox(height: 8),
                    _buildCard(context, [
                      _buildListTile(
                        context,
                        'Envoyer un commentaire',
                        icon: Icons.chat_bubble_outline,
                        onTap: () =>
                            _push(FeedbackPage(profileId: widget.profileId)),
                      ),
                      _buildListTile(
                        context,
                        "Conditions Générales d'Utilisation",
                        icon: Icons.description_outlined,
                        onTap: () => _push(const TermsOfServicePage()),
                      ),
                      _buildListTile(
                        context,
                        'Politique de Confidentialité',
                        icon: Icons.lock_outline,
                        onTap: () => _push(const PrivacyPolicyPage()),
                      ),
                    ]),
                    const SizedBox(height: 32),

                    // Bouton Déconnexion
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.red.shade400),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _handleSignOut,
                      icon: Icon(Icons.logout,
                          color: Colors.red.shade400, size: 20),
                      label: Text(
                        'Se déconnecter',
                        style: TextStyle(
                          color: Colors.red.shade400,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: _handleDeleteAccount,
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.red.shade400,
                      ),
                      child: const Text('Supprimer mon compte'),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.onSurface,
      ),
    );
  }

  /// Carte arrondie contenant des lignes séparées par un trait fin.
  Widget _buildCard(BuildContext context, List<Widget> children) {
    final dividerColor =
        Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.08);

    return Material(
      color: AppTheme.getCardColor(context),
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (int i = 0; i < children.length; i++) ...[
            if (i > 0)
              Divider(
                  height: 1, indent: 16, endIndent: 16, color: dividerColor),
            children[i],
          ],
        ],
      ),
    );
  }

  Widget _buildSwitchTile(
    BuildContext context,
    String title, {
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
      value: value,
      onChanged: onChanged,
      activeColor: AppTheme.accentColor,
    );
  }

  Widget _buildStatCard(BuildContext context, String label, String value,
      {IconData? icon, Color? iconColor}) {
    final theme = Theme.of(context);
    final valueText = Text(
      value,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppTheme.accentColor,
      ),
      textAlign: TextAlign.center,
    );

    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: AppTheme.getCardColor(context),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            if (icon == null)
              valueText
            else
              // Réduit l'ensemble si « 12 jours » + icône ne tient pas dans la carte
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, size: 20, color: iconColor),
                    const SizedBox(width: 2),
                    valueText,
                  ],
                ),
              ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListTile(BuildContext context, String title,
      {required IconData icon, required VoidCallback onTap}) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Icon(icon,
          size: 22, color: theme.colorScheme.onSurface.withValues(alpha: 0.8)),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: theme.colorScheme.onSurface,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 14,
        color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
      ),
      onTap: onTap,
    );
  }
}
