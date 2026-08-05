import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:lumiconte/constants/avatars.dart';
import 'package:lumiconte/main.dart';
import 'package:lumiconte/models/profile_model.dart';
import 'package:lumiconte/services/profile_service.dart';
import 'package:lumiconte/theme/app_theme.dart';

class ManageProfilesPage extends StatefulWidget {
  const ManageProfilesPage({super.key});

  @override
  State<ManageProfilesPage> createState() => _ManageProfilesPageState();
}

class _ManageProfilesPageState extends State<ManageProfilesPage> {
  final ProfileService _profileService = ProfileService();
  final _uid = FirebaseAuth.instance.currentUser?.uid;

  // Modifie le nom, l'âge et l'avatar d'un profil dans Firestore
  Future<void> _editProfile(
    String profileId,
    String currentName,
    int currentAge,
    String? currentAvatar,
  ) async {
    final nameController = TextEditingController(text: currentName);
    final ageController = TextEditingController(text: currentAge.toString());
    final formKey = GlobalKey<FormState>();

    String selectedAvatar = currentAvatar ?? AppAvatars.defaultAvatar;

    showDialog(
      context: context,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final cardBg = AppTheme.getCardColor(context);
        final primaryText = isDark ? Colors.white : const Color(0xFF1E1E1E);

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: cardBg,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              title: Text(
                'Modifier le profil',
                style: GoogleFonts.nunito(
                  fontWeight: FontWeight.bold,
                  color: primaryText,
                ),
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: Form(
                  key: formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Avatar',
                          style: GoogleFonts.nunito(
                            fontWeight: FontWeight.bold,
                            color: primaryText,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Center(
                          child: Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            alignment: WrapAlignment.center,
                            children: AppAvatars.availableAvatars.map((avatar) {
                              final isSelected = avatar == selectedAvatar;
                              return GestureDetector(
                                onTap: () {
                                  setDialogState(() {
                                    selectedAvatar = avatar;
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isSelected
                                          ? AppTheme.accentColor
                                          : Colors.transparent,
                                      width: 3,
                                    ),
                                  ),
                                  child: CircleAvatar(
                                    radius: 26,
                                    backgroundImage: AssetImage(avatar),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: nameController,
                          style: GoogleFonts.nunito(color: primaryText),
                          decoration: InputDecoration(
                            labelText: 'Nom',
                            labelStyle: GoogleFonts.nunito(
                              color: primaryText.withValues(alpha: 0.7),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          validator: (v) => v == null || v.trim().isEmpty
                              ? 'Entrez un nom'
                              : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: ageController,
                          style: GoogleFonts.nunito(color: primaryText),
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Âge',
                            labelStyle: GoogleFonts.nunito(
                              color: primaryText.withValues(alpha: 0.7),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          validator: (v) => v == null || int.tryParse(v) == null
                              ? 'Entrez un âge valide'
                              : null,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Annuler',
                    style: GoogleFonts.nunito(
                      color: isDark ? Colors.white70 : Colors.grey.shade700,
                    ),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () async {
                    if (!formKey.currentState!.validate() || _uid == null) {
                      return;
                    }
                    Navigator.pop(context);

                    try {
                      await _profileService.updateProfile(
                        _uid!,
                        profileId,
                        name: nameController.text.trim(),
                        age: int.parse(ageController.text.trim()),
                        avatarPath: selectedAvatar,
                      );

                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Profil mis à jour !'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Erreur : $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                  child: Text(
                    'Sauvegarder',
                    style: GoogleFonts.nunito(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Supprime un profil et toutes ses sous-collections après confirmation
  Future<void> _deleteProfile(String profileId, String profileName) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = AppTheme.getCardColor(context);
    final primaryText = isDark ? Colors.white : const Color(0xFF1E1E1E);

    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          'Supprimer le profil',
          style: GoogleFonts.nunito(
            fontWeight: FontWeight.bold,
            color: primaryText,
          ),
        ),
        content: Text(
          'Voulez-vous vraiment supprimer le profil de $profileName ? Cette action est irréversible.',
          style: GoogleFonts.nunito(
            color: isDark ? Colors.white70 : Colors.black87,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Annuler',
              style: GoogleFonts.nunito(
                color: isDark ? Colors.white70 : Colors.grey.shade700,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(
              'Supprimer',
              style: GoogleFonts.nunito(
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm == true && _uid != null) {
      try {
        await _profileService.deleteProfile(_uid!, profileId);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profil et données supprimés'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur : $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  // Change le profil actif de l'application ET applique son thème
  Future<void> _selectProfile(String profileId, String name) async {
    if (_uid != null) {
      try {
        await _profileService.setActiveProfile(_uid!, profileId);

        final settingsSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(_uid)
            .collection('profiles')
            .doc(profileId)
            .collection('settings')
            .get();

        if (settingsSnapshot.docs.isNotEmpty) {
          final data = settingsSnapshot.docs.first.data();
          final bool isDark = data['theme'] == 'dark';
          appSettings.toggleDarkMode(profileId, isDark);
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Profil actif : $name'),
              backgroundColor: AppTheme.accentColor,
              duration: const Duration(seconds: 1),
            ),
          );

          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          } else {
            context.go('/home');
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur : $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? AppTheme.darkBg : AppTheme.lightBg;
    final cardColor = AppTheme.getCardColor(context);
    final primaryTextColor = isDark ? Colors.white : const Color(0xFF1E1E1E);

    if (_uid == null) {
      return Scaffold(
        backgroundColor: backgroundColor,
        body: Center(
          child: Text(
            'Veuillez vous connecter.',
            style: GoogleFonts.nunito(color: primaryTextColor, fontSize: 16),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          'Gérer les profils',
          style: GoogleFonts.nunito(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: primaryTextColor,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        foregroundColor: primaryTextColor,
      ),
      body: StreamBuilder<List<ProfileModel>>(
        stream: _profileService.getUserProfilesStream(_uid!),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.accentColor),
            );
          }

          final profiles = snapshot.data ?? [];
          final bool canAddProfile = profiles.length < 6;
          final int itemCount =
              canAddProfile ? profiles.length + 1 : profiles.length;

          return GridView.builder(
            padding: const EdgeInsets.all(24),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.75,
            ),
            itemCount: itemCount,
            itemBuilder: (context, index) {
              if (canAddProfile && index == profiles.length) {
                return InkWell(
                  onTap: () {
                    context.push('/create-profile');
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppTheme.accentColor.withValues(alpha: 0.4),
                        style: BorderStyle.solid,
                        width: 2,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.add_circle_outline,
                          size: 48,
                          color: AppTheme.accentColor,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Créer un profil',
                          style: GoogleFonts.nunito(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: primaryTextColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final profile = profiles[index];
              final String name = profile.name;
              final int age = profile.age;

              return Container(
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: !isDark
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ]
                      : null,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _selectProfile(profile.id, name),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              radius: 32,
                              backgroundColor: const Color(0xFFFFD25A),
                              backgroundImage: AssetImage(
                                profile.avatarPath ?? AppAvatars.defaultAvatar,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.nunito(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: primaryTextColor,
                              ),
                            ),
                            Text(
                              '$age ans',
                              style: GoogleFonts.nunito(
                                color: isDark
                                    ? Colors.grey.shade400
                                    : Colors.grey.shade600,
                                fontSize: 13,
                              ),
                            ),
                            const Spacer(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit_outlined,
                                    size: 20,
                                    color: Colors.blue,
                                  ),
                                  onPressed: () => _editProfile(
                                    profile.id,
                                    name,
                                    age,
                                    profile.avatarPath,
                                  ),
                                  constraints: const BoxConstraints(),
                                  padding: EdgeInsets.zero,
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.delete_outline,
                                    size: 20,
                                    color: Colors.red.shade400,
                                  ),
                                  onPressed: () =>
                                      _deleteProfile(profile.id, name),
                                  constraints: const BoxConstraints(),
                                  padding: EdgeInsets.zero,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
