import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:lumiconte/services/profile_service.dart';
import 'package:lumiconte/services/settings_service.dart';

class ProfileCreationPage extends StatefulWidget {
  const ProfileCreationPage({super.key});

  @override
  State<ProfileCreationPage> createState() => _ProfileCreationPageState();
}

class _ProfileCreationPageState extends State<ProfileCreationPage> {
  final _nameController = TextEditingController();
  int _selectedAge = 5;
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
    super.dispose();
  }

  Future<void> _createProfile() async {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Entrez un nom')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("Pas d'utilisateur");

      // Créer le profil
      final profileId = await _profileService.createProfile(
        user.uid,
        name: _nameController.text,
        age: _selectedAge,
      );

      // Créer les settings par défaut
      await _settingsService.createSettings(
        user.uid,
        profileId,
      );

      if (mounted) {
        context.go('/home');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Créer un profil enfant")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: "Nom de l'enfant",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            Text("Âge: $_selectedAge ans"),
            Slider(
              value: _selectedAge.toDouble(),
              min: 3,
              max: 18,
              divisions: 15,
              onChanged: (value) {
                setState(() => _selectedAge = value.toInt());
              },
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _isLoading ? null : _createProfile,
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(),
                    )
                  : const Text("Créer le profil"),
            ),
          ],
        ),
      ),
    );
  }
}
