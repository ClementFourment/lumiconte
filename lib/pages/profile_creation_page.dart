import 'package:lumiconte/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

import 'package:lumiconte/main.dart';
import 'package:lumiconte/theme/app_theme.dart';
import 'package:lumiconte/services/profile_service.dart';
import 'package:lumiconte/services/settings_service.dart';
import 'package:lumiconte/constants/avatars.dart';

class ProfileCreationPage extends StatefulWidget {
  const ProfileCreationPage({super.key});

  @override
  State<ProfileCreationPage> createState() => _ProfileCreationPageState();
}

class _ProfileCreationPageState extends State<ProfileCreationPage> {
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  String _selectedAvatar = AppAvatars.defaultAvatar;
  bool _isLoading = false;

  late ProfileService _profileService;
  late SettingsService _settingsService;

  @override
  void initState() {
    super.initState();
    _profileService = ProfileService();
    _settingsService = SettingsService();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  Future<void> _createProfile() async {
    final name = _nameController.text.trim();
    final ageText = _ageController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).enterName)),
      );
      return;
    }

    final parsedAge = int.tryParse(ageText);
    if (ageText.isEmpty || parsedAge == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).enterValidAge)),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("Utilisateur non connecté");

      final String profileId = await _profileService.createAndSetActiveProfile(
        user.uid,
        name: name,
        age: parsedAge,
        avatarPath: _selectedAvatar,
      );

      await _settingsService.createOrInitSettings(
        user.uid,
        profileId,
      );

      appSettings.toggleDarkMode(profileId, false);

      // Création de profil = parcours parent : c'est ici qu'on demande
      // l'autorisation des rappels, jamais sur les écrans de l'enfant
      if (appSettings.isNotificationsEnabled) {
        await appSettings.requestNotificationPermissions();
      }

      if (mounted) {
        context.go('/home');
      }
    } catch (e) {
      // Le détail technique reste dans les logs : le parent lit un message
      // traduit, pas le texte brut d'une exception
      debugPrint('Création de profil : $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).profileCreationFailed)),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  TextStyle titleStyle(BuildContext context) {
    final theme = Theme.of(context);
    return TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: theme.colorScheme.onSurface,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardColor = AppTheme.getCardColor(context);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Center(
                  child: Text(
                    AppLocalizations.of(context).whoIsOurAdventurer,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // Sélection de l'avatar
                Text(
                  AppLocalizations.of(context).chooseYourAvatar,
                  style: titleStyle(context),
                ),
                const SizedBox(height: 15),
                SizedBox(
                  height: 90,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: AppAvatars.availableAvatars.length,
                    itemBuilder: (context, index) {
                      final avatar = AppAvatars.availableAvatars[index];
                      final isSelected = avatar == _selectedAvatar;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedAvatar = avatar),
                        child: Container(
                          margin: const EdgeInsets.only(right: 12),
                          padding: const EdgeInsets.all(4),
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
                            radius: 35,
                            backgroundImage: AssetImage(avatar),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 30),
                Text(
                  AppLocalizations.of(context).theirName,
                  style: titleStyle(context),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: _nameController,
                  style: TextStyle(color: theme.colorScheme.onSurface),
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context).nameHintExample,
                    hintStyle: TextStyle(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                    filled: true,
                    fillColor: cardColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                Text(
                  AppLocalizations.of(context).theirAge,
                  style: titleStyle(context),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: _ageController,
                  keyboardType: TextInputType.number,
                  style: TextStyle(color: theme.colorScheme.onSurface),
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context).ageHintExample,
                    hintStyle: TextStyle(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                    filled: true,
                    fillColor: cardColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : () => _createProfile(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accentColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: _isLoading
                        ? CircularProgressIndicator(
                            color: theme.scaffoldBackgroundColor,
                            strokeWidth: 2,
                          )
                        : Text(
                            AppLocalizations.of(context).createProfileAndStart,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: theme.brightness == Brightness.dark
                                  ? AppTheme.darkBg
                                  : Colors.black,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}