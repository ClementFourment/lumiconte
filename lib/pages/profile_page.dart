import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lumiconte/services/auth_service.dart';
import 'package:lumiconte/pages/settings_page.dart';
import 'package:lumiconte/main.dart'; 
import 'dart:async';

import 'package:lumiconte/pages/manage_profiles_page.dart';
import 'package:lumiconte/pages/rewards_page.dart';
import 'package:lumiconte/pages/feedback_page.dart';
import 'package:lumiconte/pages/terms_page.dart';
import 'package:lumiconte/pages/privacy_page.dart';

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
  static const _gold = Color(0xFFFDB833);
  static const _purpleBg = Color(0xFFE8E5F7);
  static const _darkPurpleBg = Color(0xFF231F32);

  final AuthService _authService = AuthService();
  final String _uid = FirebaseAuth.instance.currentUser!.uid;
  
  late final DocumentReference _profileDoc;
  late final CollectionReference _readingProgressCollection;
  late final CollectionReference _settingsCollection;
  bool _isLoading = false;
  
  Timer? _dailyReminderTimer;

  @override
  void initState() {
    super.initState();
    _profileDoc = FirebaseFirestore.instance
        .collection('users')
        .doc(_uid)
        .collection('profiles')
        .doc(widget.profileId);

    _readingProgressCollection = _profileDoc.collection('readingProgress');
    _settingsCollection = _profileDoc.collection('settings');
  }

  @override
  void dispose() {
    _dailyReminderTimer?.cancel();
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

  void _manageReadingReminders(List<QueryDocumentSnapshot> docs) {
    _dailyReminderTimer?.cancel();

    if (!appSettings.isNotificationsEnabled) {
      appSettings.cancelReadingReminder();
      return;
    }

    bool hasUnfinishedStory = false;
    for (var doc in docs) {
      final data = doc.data() as Map<String, dynamic>;
      final int progress = (data['progress'] as num?)?.toInt() ?? 0;
      
      if (progress < 100) {
        hasUnfinishedStory = true;
        break;
      }
    }

    if (hasUnfinishedStory) {
      appSettings.scheduleReadingReminder(widget.profileId);

      final now = DateTime.now();
      var scheduledTime = DateTime(now.year, now.month, now.day, 18, 0, 0);

      if (now.isAfter(scheduledTime)) {
        scheduledTime = scheduledTime.add(const Duration(days: 1));
      }

      final durationUntil18h = scheduledTime.difference(now);

      _dailyReminderTimer = Timer(durationUntil18h, () {
        _manageReadingReminders(docs);
      });
    } else {
      appSettings.cancelReadingReminder();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = appSettings.isDarkMode;

    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : StreamBuilder<DocumentSnapshot>(
              stream: _profileDoc.snapshots(),
              builder: (context, profileSnapshot) {
                if (profileSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!profileSnapshot.hasData || !profileSnapshot.data!.exists) {
                  return const Center(child: Text('Profil introuvable.'));
                }

                final profileData = profileSnapshot.data!.data() as Map<String, dynamic>;
                final String name = profileData['name'] ?? 'Inconnu';
                final int age = profileData['age'] ?? 0;

                return StreamBuilder<QuerySnapshot>(
                  stream: _readingProgressCollection.snapshots(),
                  builder: (context, progressSnapshot) {
                    int storiesReadCount = 0;
                    if (progressSnapshot.hasData) {
                      storiesReadCount = progressSnapshot.data!.docs.length;

                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        _manageReadingReminders(progressSnapshot.data!.docs);
                      });
                    }

                    return StreamBuilder<QuerySnapshot>(
                      stream: _settingsCollection.snapshots(),
                      builder: (context, settingsSnapshot) {
                        String currentLangCode = 'fr';
                        String settingsDocId = '';
                        String timeDisplay = '0 min';
                        String streakDisplay = '0 jour';

                        if (settingsSnapshot.hasData && settingsSnapshot.data!.docs.isNotEmpty) {
                          final settingsDoc = settingsSnapshot.data!.docs.first;
                          settingsDocId = settingsDoc.id;
                          final settingsData = settingsDoc.data() as Map<String, dynamic>;
                          currentLangCode = settingsData['langage'] ?? 'fr';

                          final int totalMinutes = settingsData['totalReadingTime'] ?? 0;
                          if (totalMinutes < 60) {
                            timeDisplay = '$totalMinutes min';
                          } else {
                            final hours = totalMinutes ~/ 60;
                            final minutes = totalMinutes % 60;
                            timeDisplay = minutes > 0 ? '${hours}h $minutes' : '${hours}h';
                          }

                          final Timestamp? stopRead = settingsData['stopread'] as Timestamp?;
                          final int savedStreak = settingsData['streak'] ?? 0;

                          if (stopRead != null) {
                            final DateTime lastReadDate = stopRead.toDate();
                            final DateTime now = DateTime.now();
                            final DateTime today = DateTime(now.year, now.month, now.day);
                            final DateTime lastReadDay = DateTime(lastReadDate.year, lastReadDate.month, lastReadDate.day);
                            final int daysDifference = today.difference(lastReadDay).inDays;

                            if (daysDifference > 1) {
                              streakDisplay = '0 jour';
                              if (settingsData['streak'] != 0) {
                                _updateSetting(settingsDocId, 'streak', 0);
                              }
                            } else {
                              streakDisplay = '$savedStreak ${savedStreak > 1 ? 'jours' : 'jour'}';
                            }
                          }
                        }

                        return ListenableBuilder(
                          listenable: appSettings,
                          builder: (context, child) {
                            final currentCardColor = Theme.of(context).cardColor;
                            final dividerColor = isDark ? Colors.grey.shade800 : Colors.grey.shade100;

                            return SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.only(top: 60, bottom: 30, left: 24, right: 24),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: isDark 
                                            ? [_darkPurpleBg, Theme.of(context).scaffoldBackgroundColor] 
                                            : [_purpleBg, Colors.white],
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        const CircleAvatar(
                                          radius: 40,
                                          backgroundColor: Colors.transparent,
                                          backgroundImage: AssetImage('assets/images/boy.png'),
                                        ),
                                        const SizedBox(width: 20),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              name,
                                              style: TextStyle(
                                                fontSize: 22,
                                                fontWeight: FontWeight.bold,
                                                color: isDark ? Colors.white : Colors.black,
                                              ),
                                            ),
                                            Text(
                                              '$age ans',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),

                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 20),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        _buildSectionTitle('Statistiques'),
                                        const SizedBox(height: 12),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            _buildStatCard('Histoires\nlues', '$storiesReadCount'),
                                            _buildStatCard('Temps de\nlecture', timeDisplay),
                                            _buildStatCard('Série en\ncours', streakDisplay),
                                          ],
                                        ),

                                        const SizedBox(height: 28),
                                        _buildSectionTitle('Préférences'),
                                        const SizedBox(height: 8),
                                        Card(
                                          color: currentCardColor,
                                          elevation: 0,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                            side: BorderSide(color: dividerColor),
                                          ),
                                          child: Column(
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Text(
                                                      'Langue',
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        fontWeight: FontWeight.w500,
                                                        color: isDark ? Colors.white70 : Colors.black87,
                                                      ),
                                                    ),
                                                    DropdownButtonHideUnderline(
                                                      child: DropdownButton<String>(
                                                        value: currentLangCode,
                                                        icon: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                                                        style: TextStyle(
                                                          fontSize: 14,
                                                          color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                                                          fontWeight: FontWeight.w500,
                                                        ),
                                                        dropdownColor: currentCardColor,
                                                        onChanged: (String? newValue) {
                                                          if (newValue != null && settingsDocId.isNotEmpty) {
                                                            _updateSetting(settingsDocId, 'langage', newValue);
                                                          }
                                                        },
                                                        items: const [
                                                          DropdownMenuItem(value: 'fr', child: Text('Français  ')),
                                                          DropdownMenuItem(value: 'en', child: Text('English  ')),
                                                          DropdownMenuItem(value: 'es', child: Text('Español  ')),
                                                        ],
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ),
                                              Divider(height: 1, indent: 16, endIndent: 16, color: dividerColor),
                                              _buildListTileWithSwitch(
                                                'Rappels de lecture',
                                                value: appSettings.isNotificationsEnabled,
                                                onChanged: (bool newValue) {
                                                  appSettings.toggleNotifications(widget.profileId, newValue);
                                                },
                                              ),
                                              Divider(height: 1, indent: 16, endIndent: 16, color: dividerColor),
                                              _buildListTileWithSwitch(
                                                'Mode nuit',
                                                value: appSettings.isDarkMode,
                                                onChanged: (bool newValue) {
                                                  appSettings.toggleDarkMode(widget.profileId, newValue);
                                                },
                                              ),
                                            ],
                                          ),
                                        ),

                                        const SizedBox(height: 24),
                                        _buildSectionTitle('Mon Compte'),
                                        const SizedBox(height: 8),
                                        Card(
                                          color: currentCardColor,
                                          elevation: 0,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                            side: BorderSide(color: dividerColor),
                                          ),
                                          child: Column(
                                            children: [
                                              _buildListTile(
                                                'Gérer mes profils',
                                                icon: Icons.people_outline,
                                                onTap: () {
                                                  Navigator.of(context).push(
                                                    MaterialPageRoute(builder: (context) => const ManageProfilesPage()),
                                                  );
                                                },
                                              ),
                                              Divider(height: 1, indent: 16, endIndent: 16, color: dividerColor),
                                              _buildListTile(
                                                'Mes Récompenses',
                                                icon: Icons.emoji_events_outlined,
                                                onTap: () {
                                                  Navigator.of(context).push(
                                                    MaterialPageRoute(
                                                      builder: (context) => RewardsPage(
                                                        userId: FirebaseAuth.instance.currentUser?.uid ?? '',
                                                        profileId: widget.profileId,
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                              Divider(height: 1, indent: 16, endIndent: 16, color: dividerColor),
                                              _buildListTile(
                                                'Paramètres de lecture',
                                                icon: Icons.menu_book_outlined,
                                                onTap: () {
                                                  Navigator.of(context).push(
                                                    MaterialPageRoute(
                                                      builder: (context) => SettingsPage(profileId: widget.profileId),
                                                    ),
                                                  );
                                                },
                                              ),
                                            ],
                                          ),
                                        ),

                                        const SizedBox(height: 24),
                                        _buildSectionTitle('Assistance et Informations'),
                                        const SizedBox(height: 8),
                                        Card(
                                          color: currentCardColor,
                                          elevation: 0,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                            side: BorderSide(color: dividerColor),
                                          ),
                                          child: Column(
                                            children: [
                                              _buildListTile(
                                                'Envoyer un commentaire',
                                                icon: Icons.chat_bubble_outline,
                                                onTap: () {
                                                  Navigator.of(context).push(
                                                    MaterialPageRoute(builder: (context) => const FeedbackPage()),
                                                  );
                                                },
                                              ),
                                              Divider(height: 1, indent: 16, endIndent: 16, color: dividerColor),
                                              _buildListTile(
                                                "Conditions Générales d'Utilisation",
                                                icon: Icons.description_outlined,
                                                onTap: () {
                                                  Navigator.of(context).push(
                                                    MaterialPageRoute(builder: (context) => const TermsOfServicePage()),
                                                  );
                                                },
                                              ),
                                              Divider(height: 1, indent: 16, endIndent: 16, color: dividerColor),
                                              _buildListTile(
                                                'Politique de Confidentialité',
                                                icon: Icons.lock_outline,
                                                onTap: () {
                                                  Navigator.of(context).push(
                                                    MaterialPageRoute(builder: (context) => const PrivacyPolicyPage()),
                                                  );
                                                },
                                              ),
                                            ],
                                          ),
                                        ),

                                        const SizedBox(height: 32),
                                        SizedBox(
                                          width: double.infinity,
                                          height: 52,
                                          child: TextButton.icon(
                                            style: TextButton.styleFrom(
                                              foregroundColor: Colors.red.shade600,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                            ),
                                            onPressed: _handleSignOut,
                                            icon: const Icon(Icons.logout),
                                            label: const Text(
                                              'Se déconnecter',
                                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ),

                                        const SizedBox(height: 24),
                                        Center(
                                          child: Text(
                                            'Version 1.0.0',
                                            style: TextStyle(
                                              color: Colors.grey.shade500,
                                              fontSize: 12,
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

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildStatCard(String title, String value, {bool highlight = false}) {
    return Expanded(
      child: Card(
        color: highlight ? _gold.withOpacity(0.2) : null,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: highlight ? _gold : null)),
              const SizedBox(height: 4),
              Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildListTile(String title, {required IconData icon, required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title, style: const TextStyle(fontSize: 14)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 14),
      onTap: onTap,
    );
  }

  Widget _buildListTileWithSwitch(String title, {required bool value, required ValueChanged<bool> onChanged}) {
    return SwitchListTile(
      title: Text(title, style: const TextStyle(fontSize: 14)),
      value: value,
      onChanged: onChanged,
    );
  }
}