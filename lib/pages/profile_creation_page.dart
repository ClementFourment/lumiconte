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
  final _ageController = TextEditingController(); 
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
    _ageController.dispose();
    super.dispose();
  }

  Future<void> _createProfile({bool customizeNow = false}) async {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Entrez un nom')),
      );
      return;
    }

    if (_ageController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Entrez un âge')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("Pas d'utilisateur");

      _selectedAge = int.parse(_ageController.text);

      final profileId = await _profileService.createProfile(
        user.uid,
        name: _nameController.text,
        age: _selectedAge,
      );

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
    // 🎯 Le GestureDetector ici ferme le clavier dès qu'on clique à côté d'un champ textuel
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: const Color(0xFF0F1123), 
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                
                const Center(
                  child: Text(
                    'Qui est notre aventurier(e) ?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white, 
                    ),
                  ),
                ),
                
                const SizedBox(height: 40),

                Text(
                  'Son nom ?',
                  style: titleStyle,
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: _nameController,
                  style: const TextStyle(color: Colors.white), 
                  decoration: InputDecoration(
                    hintText: "Ex: Léo, Nina...",
                    hintStyle: const TextStyle(color: Colors.white54),
                    filled: true,
                    fillColor: const Color(0xFF1E203B), 
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25), 
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                Text(
                  'Son age ?',
                  style: titleStyle,
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: _ageController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: "Ex: 5",
                    hintStyle: const TextStyle(color: Colors.white54),
                    filled: true,
                    fillColor: const Color(0xFF1E203B),
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
                    onPressed: _isLoading ? null : () => _createProfile(customizeNow: false),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFD25A), 
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(color: Color(0xFF0F1123), strokeWidth: 2),
                          )
                        : const Text(
                            'Créer le profil et commencer la lecture',
                            style: TextStyle(
                              fontSize: 16, 
                              fontWeight: FontWeight.bold, 
                              color: Color(0xFF0F1123), 
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

  TextStyle get titleStyle => const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      );
}