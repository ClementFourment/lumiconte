import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:lumiconte/main.dart';
import 'package:lumiconte/models/profile_model.dart';
import 'package:lumiconte/models/settings_model.dart';
import 'package:lumiconte/pages/feedback_page.dart';
import 'package:lumiconte/pages/manage_profiles_page.dart';
import 'package:lumiconte/pages/privacy_page.dart';
import 'package:lumiconte/pages/rewards_page.dart';
import 'package:lumiconte/pages/settings_page.dart';
import 'package:lumiconte/pages/terms_page.dart';
import 'package:lumiconte/services/auth_service.dart';
import 'package:lumiconte/theme/app_theme.dart';

class ProfilePage extends StatefulWidget {
  final String profileId;

  const ProfilePage({
    super.key,
    required this.profileId,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final AuthService _authService = AuthService();
  final String? _uid = FirebaseAuth.instance.currentUser?.uid;

  late final DocumentReference _profileDoc;
  late final CollectionReference _readingProgressCollection;
  late final CollectionReference _settingsCollection;

  StreamSubscription? _progressSubscription;
  StreamSubscription? _settingsSubscription;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    if (_uid != null) {
      _profileDoc = FirebaseFirestore.instance
          .collection('users')
          .doc(_uid)
          .collection('profiles')
          .doc(widget.profileId);

      _readingProgressCollection = _profileDoc.collection('readingProgress');
      _settingsCollection = _profileDoc.collection('settings');

      // À chaque changement de progression dans ce profil, on redemande à appSettings
      // de re-vérifier globalement la planification des rappels
      _progressSubscription =
          _readingProgressCollection.snapshots().listen((_) {
        if (mounted && appSettings.isNotificationsEnabled) {
          appSettings.scheduleReadingReminder();
        }
      });

      // Sync du mode sombre du profil avec appSettings
      _settingsSubscription =
          _settingsCollection.snapshots().listen((snapshot) {
        if (mounted && snapshot.docs.isNotEmpty) {
          final rawData =
              snapshot.docs.first.data() as Map<String, dynamic>? ?? {};
          final isDark = rawData['isDarkMode'] ??
              rawData['darkMode'] ??
              appSettings.isDarkMode;

          if (appSettings.isDarkMode != isDark) {
            appSettings.toggleDarkMode(widget.profileId, isDark);
          }
        }
      });
    }
  }

  @override
  void dispose() {
    _progressSubscription?.cancel();
    _settingsSubscription?.cancel();
    super.dispose();
  }

  Future<void> _updateSetting(String docId, String key, dynamic value) async {
    try {
      await _settingsCollection.doc(docId).update({key: value});
    } catch (e) {
      debugPrint("Erreur lors de la mise à jour du setting: $e");
    }
  }

  Future<void> _handleSignOut() async {
    setState(() => _isLoading = true);
    try {
      await _authService.signOut();
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_uid == null) {
      return Scaffold(
        body: Center(
          child: Text('Utilisateur non connecté.',
              style: TextStyle(color: theme.colorScheme.onSurface)),
        ),
      );
    }

    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: theme.colorScheme.primary),
        ),
      );
    }

    return Scaffold(
      body: StreamBuilder<DocumentSnapshot>(
        stream: _profileDoc.snapshots(),
        builder: (context, profileSnapshot) {
          if (profileSnapshot.connectionState == ConnectionState.waiting) {
            return Center(
                child: CircularProgressIndicator(
                    color: theme.colorScheme.primary));
          }
          if (profileSnapshot.hasError) {
            return Center(
                child: Text('Erreur : ${profileSnapshot.error}',
                    style: TextStyle(color: theme.colorScheme.onSurface)));
          }
          if (!profileSnapshot.hasData || !profileSnapshot.data!.exists) {
            return Center(
                child: Text('Profil introuvable.',
                    style: TextStyle(color: theme.colorScheme.onSurface)));
          }

          final profileData =
              profileSnapshot.data!.data() as Map<String, dynamic>? ?? {};
          final profile = ProfileModel.fromMap(
              profileData, profileSnapshot.data!.id, _uid!);

          return StreamBuilder<QuerySnapshot>(
            stream: _readingProgressCollection.snapshots(),
            builder: (context, progressSnapshot) {
              final int storiesReadCount =
                  progressSnapshot.hasData ? progressSnapshot.data!.docs.length : 0;

              return StreamBuilder<QuerySnapshot>(
                stream: _settingsCollection.snapshots(),
                builder: (context, settingsSnapshot) {
                  String currentLangCode = 'fr';
                  String settingsDocId = '';
                  String timeDisplay = '0 min';
                  String streakDisplay = '0 jour';

                  if (settingsSnapshot.hasData &&
                      settingsSnapshot.data!.docs.isNotEmpty) {
                    final settingsDoc = settingsSnapshot.data!.docs.first;
                    settingsDocId = settingsDoc.id;

                    final settings = SettingsModel.fromMap(
                      settingsDoc.data() as Map<String, dynamic>? ?? {},
                      settingsDoc.id,
                    );

                    currentLangCode = settings.langage;

                    // Calcul du temps de lecture
                    final int totalMinutes = settings.totalReadingTime;
                    if (totalMinutes < 60) {
                      timeDisplay = '$totalMinutes min';
                    } else {
                      final hours = totalMinutes ~/ 60;
                      final minutes = totalMinutes % 60;
                      timeDisplay =
                          minutes > 0 ? '${hours}h $minutes' : '${hours}h';
                    }

                    // Calcul de la série de jours (Streak)
                    if (settings.stopRead != null) {
                      final DateTime lastReadDate = settings.stopRead!;
                      final DateTime now = DateTime.now();
                      final DateTime today =
                          DateTime(now.year, now.month, now.day);
                      final DateTime lastReadDay = DateTime(
                          lastReadDate.year,
                          lastReadDate.month,
                          lastReadDate.day);
                      final int daysDifference =
                          today.difference(lastReadDay).inDays;

                      if (daysDifference > 1) {
                        if (settings.streak != 0) {
                          Future.microtask(() =>
                              _updateSetting(settingsDocId, 'streak', 0));
                        }
                        streakDisplay = '0 jour';
                      } else {
                        streakDisplay =
                            '${settings.streak} ${settings.streak > 1 ? 'jours' : 'jour'}';
                      }
                    }
                  }

                  return ListenableBuilder(
                    listenable: appSettings,
                    builder: (context, child) {
                      return SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header Profil
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.only(
                                  top: 60, bottom: 24, left: 24, right: 24),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: theme.brightness == Brightness.dark
                                      ? [
                                          AppTheme.darkCard,
                                          theme.scaffoldBackgroundColor
                                        ]
                                      : [
                                          AppTheme.accentColor
                                              .withValues(alpha: 0.15),
                                          theme.scaffoldBackgroundColor
                                        ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 40,
                                    backgroundColor: theme.colorScheme.primary
                                        .withValues(alpha: 0.2),
                                    backgroundImage: const AssetImage(
                                        'assets/images/boy.png'),
                                  ),
                                  const SizedBox(width: 20),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        profile.name,
                                        style: TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                          color: theme.colorScheme.onSurface,
                                        ),
                                      ),
                                      Text(
                                        '${profile.age} ans',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: theme.colorScheme.onSurface
                                              .withValues(alpha: 0.6),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Section Statistiques
                                  Text(
                                    'Statistiques',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: theme.colorScheme.onSurface,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      _buildStatCard(
                                          context,
                                          'Histoires\nlues',
                                          '$storiesReadCount'),
                                      _buildStatCard(context,
                                          'Temps de\nlecture', timeDisplay),
                                      _buildStatCard(context,
                                          'Série en\ncours', streakDisplay),
                                    ],
                                  ),
                                  const SizedBox(height: 28),

                                  // Section Préférences
                                  Text(
                                    'Préférences',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: theme.colorScheme.onSurface,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Material(
                                    color: AppTheme.getCardColor(context),
                                    borderRadius: BorderRadius.circular(16),
                                    clipBehavior: Clip.antiAlias,
                                    child: Column(
                                      children: [
                                        // Langue
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16.0, vertical: 4.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                'Langue',
                                                style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w500,
                                                  color: theme
                                                      .colorScheme.onSurface,
                                                ),
                                              ),
                                              DropdownButtonHideUnderline(
                                                child: DropdownButton<String>(
                                                  value: currentLangCode,
                                                  icon: Icon(
                                                    Icons.arrow_forward_ios,
                                                    size: 14,
                                                    color: theme
                                                        .colorScheme.onSurface
                                                        .withValues(
                                                            alpha: 0.4),
                                                  ),
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: theme
                                                        .colorScheme.onSurface,
                                                  ),
                                                  dropdownColor:
                                                      AppTheme.getCardColor(
                                                          context),
                                                  onChanged:
                                                      (String? newValue) {
                                                    if (newValue != null &&
                                                        settingsDocId
                                                            .isNotEmpty) {
                                                      _updateSetting(
                                                          settingsDocId,
                                                          'langage',
                                                          newValue);
                                                    }
                                                  },
                                                  items: const [
                                                    DropdownMenuItem(
                                                        value: 'fr',
                                                        child: Text(
                                                            'Français  ')),
                                                    DropdownMenuItem(
                                                        value: 'en',
                                                        child:
                                                            Text('English  ')),
                                                    DropdownMenuItem(
                                                        value: 'es',
                                                        child:
                                                            Text('Español  ')),
                                                  ],
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                        Divider(
                                          height: 1,
                                          indent: 16,
                                          endIndent: 16,
                                          color: theme.colorScheme.onSurface
                                              .withValues(alpha: 0.08),
                                        ),
                                        // Rappels de lecture (Branché sur le toggleNotifications(bool) global)
                                        SwitchListTile(
                                          title: Text(
                                            'Rappels de lecture',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                              color:
                                                  theme.colorScheme.onSurface,
                                            ),
                                          ),
                                          value:
                                              appSettings.isNotificationsEnabled,
                                          onChanged: (bool newValue) {
                                            appSettings
                                                .toggleNotifications(newValue);
                                          },
                                          activeColor: AppTheme.accentColor,
                                        ),
                                        Divider(
                                          height: 1,
                                          indent: 16,
                                          endIndent: 16,
                                          color: theme.colorScheme.onSurface
                                              .withValues(alpha: 0.08),
                                        ),
                                        // Mode Nuit (Inchangé : prend le profileId + la valeur bool)
                                        SwitchListTile(
                                          title: Text(
                                            'Mode nuit',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                              color:
                                                  theme.colorScheme.onSurface,
                                            ),
                                          ),
                                          value: appSettings.isDarkMode,
                                          onChanged: (bool newValue) {
                                            appSettings.toggleDarkMode(
                                                widget.profileId, newValue);
                                            if (settingsDocId.isNotEmpty) {
                                              _updateSetting(settingsDocId,
                                                  'isDarkMode', newValue);
                                            }
                                          },
                                          activeColor: AppTheme.accentColor,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 24),

                                  // Section Mon Compte
                                  Text(
                                    'Mon Compte',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: theme.colorScheme.onSurface,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Material(
                                    color: AppTheme.getCardColor(context),
                                    borderRadius: BorderRadius.circular(16),
                                    clipBehavior: Clip.antiAlias,
                                    child: Column(
                                      children: [
                                        _buildListTile(
                                          context,
                                          'Gérer mes profils',
                                          icon: Icons.people_outline,
                                          onTap: () {
                                            Navigator.of(context).push(
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      const ManageProfilesPage()),
                                            );
                                          },
                                        ),
                                        Divider(
                                          height: 1,
                                          indent: 16,
                                          endIndent: 16,
                                          color: theme.colorScheme.onSurface
                                              .withValues(alpha: 0.08),
                                        ),
                                        _buildListTile(
                                          context,
                                          'Mes Récompenses',
                                          icon: Icons.emoji_events_outlined,
                                          onTap: () {
                                            Navigator.of(context).push(
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    RewardsPage(
                                                  userId: _uid ?? '',
                                                  profileId: widget.profileId,
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                        Divider(
                                          height: 1,
                                          indent: 16,
                                          endIndent: 16,
                                          color: theme.colorScheme.onSurface
                                              .withValues(alpha: 0.08),
                                        ),
                                        _buildListTile(
                                          context,
                                          'Paramètres de lecture',
                                          icon: Icons.menu_book_outlined,
                                          onTap: () {
                                            Navigator.of(context).push(
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    SettingsPage(
                                                        profileId:
                                                            widget.profileId),
                                              ),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 24),

                                  // Section Assistance
                                  Text(
                                    'Assistance et Informations',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: theme.colorScheme.onSurface,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Material(
                                    color: AppTheme.getCardColor(context),
                                    borderRadius: BorderRadius.circular(16),
                                    clipBehavior: Clip.antiAlias,
                                    child: Column(
                                      children: [
                                        _buildListTile(
                                          context,
                                          'Envoyer un commentaire',
                                          icon: Icons.chat_bubble_outline,
                                          onTap: () {
                                            Navigator.of(context).push(
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    FeedbackPage(
                                                        profileId:
                                                            widget.profileId),
                                              ),
                                            );
                                          },
                                        ),
                                        Divider(
                                          height: 1,
                                          indent: 16,
                                          endIndent: 16,
                                          color: theme.colorScheme.onSurface
                                              .withValues(alpha: 0.08),
                                        ),
                                        _buildListTile(
                                          context,
                                          "Conditions Générales d'Utilisation",
                                          icon: Icons.description_outlined,
                                          onTap: () {
                                            Navigator.of(context).push(
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      const TermsOfServicePage()),
                                            );
                                          },
                                        ),
                                        Divider(
                                          height: 1,
                                          indent: 16,
                                          endIndent: 16,
                                          color: theme.colorScheme.onSurface
                                              .withValues(alpha: 0.08),
                                        ),
                                        _buildListTile(
                                          context,
                                          'Politique de Confidentialité',
                                          icon: Icons.lock_outline,
                                          onTap: () {
                                            Navigator.of(context).push(
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      const PrivacyPolicyPage()),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 32),

                                  // Bouton Déconnexion
                                  SizedBox(
                                    width: double.infinity,
                                    child: OutlinedButton.icon(
                                      style: OutlinedButton.styleFrom(
                                        side: BorderSide(
                                            color: Colors.red.shade400),
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 14),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
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
                                  ),
                                  const SizedBox(height: 40),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
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
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.accentColor,
              ),
              textAlign: TextAlign.center,
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
      hoverColor: theme.colorScheme.primary.withValues(alpha: 0.05),
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