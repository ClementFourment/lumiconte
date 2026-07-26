import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

import 'package:lumiconte/theme/app_theme.dart';
import 'package:lumiconte/services/profile_service.dart';
import 'package:lumiconte/services/settings_service.dart';

class ProfileCreationPage extends StatefulWidget {
  const ProfileCreationPage({super.key});

  @override
  State<ProfileCreationPage> createState() => _ProfileCreationPageState();
}

class _ProfileCreationPageState extends State<ProfileCreationPage> {
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
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

  Future<void> _createProfile({bool customizeNow = false}) async {
    final name = _nameController.text.trim();
    final ageText = _ageController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Entrez un nom')),
      );
      return;
    }

    final parsedAge = int.tryParse(ageText);
    if (ageText.isEmpty || parsedAge == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Entrez un âge valide')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("Utilisateur non connecté");

      // 1. On crée le profil ET on le définit comme profil actif (activeProfileId)
      final String profileId = await _profileService.createAndSetActiveProfile(
        user.uid,
        name: name,
        age: parsedAge,
      );

      // 2. Initialisation des paramètres associés
      await _settingsService.createOrInitSettings(
        user.uid,
        profileId,
      );

      if (mounted) {
        // Redirection vers l'accueil
        context.go('/home');
      }
    } catch (e) {
      if (mounted) {
        // On nettoie le message pour retirer 'Exception: ' si présent
        final errorMessage = e.toString().replaceAll('Exception: ', '');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $errorMessage')),
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
                const SizedBox(height: 40),
                Center(
                  child: Text(
                    'Qui est notre aventurier(e) ?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                Text(
                  'Son nom ?',
                  style: titleStyle(context),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: _nameController,
                  style: TextStyle(color: theme.colorScheme.onSurface),
                  decoration: InputDecoration(
                    hintText: "Ex: Léo, Nina...",
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
                  'Son âge ?',
                  style: titleStyle(context),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: _ageController,
                  keyboardType: TextInputType.number,
                  style: TextStyle(color: theme.colorScheme.onSurface),
                  decoration: InputDecoration(
                    hintText: "Ex: 5",
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
                const SizedBox(height: 50),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : () => _createProfile(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accentColor, // Doré Lumiconte
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
                            'Créer le profil et commencer la lecture',
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