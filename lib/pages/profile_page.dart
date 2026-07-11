import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lumiconte/services/auth_service.dart';
import 'package:lumiconte/pages/settings_page.dart';

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

  final AuthService _authService = AuthService();
  final String _uid = FirebaseAuth.instance.currentUser!.uid;
  
  late final DocumentReference _profileDoc;
  late final CollectionReference _readingProgressCollection;
  late final CollectionReference _settingsCollection;
  bool _isLoading = false;

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

  Future<void> _updateSetting(String docId, String key, dynamic value) async {
    await _settingsCollection.doc(docId).update({key: value});
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
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: _isLoading
          ? const Center(child: _LoadingIndicator())
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

                          // 🕒 RÉCUPÉRATION DU TEMPS TOTAL (EN MINUTES) DEPUIS FIREBASE
                          final int totalMinutes = settingsData['totalReadingTime'] ?? 0;

                          if (totalMinutes < 60) {
                            timeDisplay = '$totalMinutes min';
                          } else {
                            final hours = totalMinutes ~/ 60;
                            final minutes = totalMinutes % 60;
                            timeDisplay = minutes > 0 ? '${hours}h $minutes' : '${hours}h';
                          }

                          // 🔥 GESTION DE LA SÉRIE (STREAK) ET VÉRIFICATION DE LA BRÈCHE DE 24H
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

                        return SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 1. En-tête Profil Dynamique
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.only(top: 60, bottom: 30, left: 24, right: 24),
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [_purpleBg, Colors.white],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 40,
                                      backgroundColor: Colors.transparent,
                                      backgroundImage: const AssetImage('assets/images/boy.png'),
                                    ),
                                    const SizedBox(width: 20),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          name,
                                          style: const TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        ),
                                        Text(
                                          '$age ans',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey.shade600,
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
                                    // 2. Section Statistiques Dynamique
                                    _buildSectionTitle('Statistiques'),
                                    const SizedBox(height: 12),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        _buildStatCard('Histoires\nlues', '$storiesReadCount'),
                                        _buildStatCard('Temps de\nlecture', timeDisplay),
                                        _buildStatCard('Série en\ncours', streakDisplay, highlight: true),
                                      ],
                                    ),

                                    const SizedBox(height: 28),

                                    // 3. Section Préférences avec Dropdown de Langue
                                    _buildSectionTitle('Préférences'),
                                    const SizedBox(height: 8),
                                    Card(
                                      color: Colors.white,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        side: BorderSide(color: Colors.grey.shade100),
                                      ),
                                      child: Column(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                const Text(
                                                  'Langue',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w500,
                                                    color: Colors.black87,
                                                  ),
                                                ),
                                                DropdownButtonHideUnderline(
                                                  child: DropdownButton<String>(
                                                    value: currentLangCode,
                                                    icon: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.grey.shade600,
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                    onChanged: (String? newValue) {
                                                      if (newValue != null && settingsDocId.isNotEmpty) {
                                                        _updateSetting(settingsDocId, 'langage', newValue);
                                                      }
                                                    },
                                                    items: const [
                                                      DropdownMenuItem(
                                                        value: 'fr',
                                                        child: Text('Français  '),
                                                      ),
                                                      DropdownMenuItem(
                                                        value: 'en',
                                                        child: Text('English  '),
                                                      ),
                                                      DropdownMenuItem(
                                                        value: 'es',
                                                        child: Text('Español  '),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const Divider(height: 1, indent: 16, endIndent: 16),
                                          _buildListTile('Rappels de lecture', trailingText: 'Activés'),
                                          const Divider(height: 1, indent: 16, endIndent: 16),
                                          _buildListTile('Mode nuit', trailingText: 'Désactivé'),
                                        ],
                                      ),
                                    ),

                                    const SizedBox(height: 24),

                                    // 4. Section Mon Compte
                                    _buildSectionTitle('Mon Compte'),
                                    const SizedBox(height: 8),
                                    Card(
                                      color: Colors.white,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        side: BorderSide(color: Colors.grey.shade100),
                                      ),
                                      child: Column(
                                        children: [
                                          _buildListTile(
                                            'Gérer mes profils',
                                            icon: Icons.people_outline,
                                            onTap: () {},
                                          ),
                                          const Divider(height: 1, indent: 16, endIndent: 16),
                                          _buildListTile(
                                            'Mes Récompenses',
                                            icon: Icons.emoji_events_outlined,
                                            onTap: () {},
                                          ),
                                          const Divider(height: 1, indent: 16, endIndent: 16),
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

                                    // 5. Section Légal & Support
                                    _buildSectionTitle('Assistance et Informations'),
                                    const SizedBox(height: 8),
                                    Card(
                                      color: Colors.white,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        side: BorderSide(color: Colors.grey.shade100),
                                      ),
                                      child: Column(
                                        children: [
                                          _buildListTile('Envoyer un commentaire', icon: Icons.chat_bubble_outline),
                                          const Divider(height: 1, indent: 16, endIndent: 16),
                                          _buildListTile('Conditions Générales d\'Utilisation', icon: Icons.description_outlined),
                                          const Divider(height: 1, indent: 16, endIndent: 16),
                                          _buildListTile('Politique de Confidentialité', icon: Icons.lock_outline),
                                        ],
                                      ),
                                    ),

                                    const SizedBox(height: 32),

                                    // 6. Bouton Déconnexion
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

                                    // 7. Version de l'application
                                    const SizedBox(height: 24),
                                    Center(
                                      child: Text(
                                        'Version 1.0.0',
                                        style: TextStyle(
                                          color: Colors.grey.shade400,
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
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildStatCard(String title, String value, {bool highlight = false}) {
    return Container(
      width: (MediaQuery.of(context).size.width - 64) / 3,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: highlight ? Colors.orange.shade200 : Colors.grey.shade100,
          width: highlight ? 1.5 : 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              color: highlight ? Colors.orange.shade700 : Colors.grey.shade500,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: highlight ? Colors.orange.shade800 : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListTile(String title, {String? trailingText, IconData? icon, VoidCallback? onTap}) {
    return ListTile(
      onTap: onTap ?? () {},
      leading: icon != null ? Icon(icon, color: Colors.black54, size: 22) : null,
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailingText != null)
            Text(
              trailingText,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            ),
          const SizedBox(width: 4),
          Icon(
            Icons.arrow_forward_ios,
            size: 14,
            color: Colors.grey.shade400,
          ),
        ],
      ),
    );
  }
}

class _LoadingIndicator extends StatelessWidget {
  const _LoadingIndicator();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(
            _ProfilePageState._gold,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          "Déconnexion en cours...",
          style: TextStyle(
            color: Colors.black54,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}