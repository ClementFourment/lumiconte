import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:lumiconte/main.dart'; // Pour appSettings
import 'package:lumiconte/services/profile_service.dart';
import 'package:lumiconte/pages/profile_creation_page.dart';

class ManageProfilesPage extends StatefulWidget {
  const ManageProfilesPage({super.key});

  @override
  State<ManageProfilesPage> createState() => _ManageProfilesPageState();
}

class _ManageProfilesPageState extends State<ManageProfilesPage> {
  final ProfileService _profileService = ProfileService();
  final _uid = FirebaseAuth.instance.currentUser?.uid;

  // Modifie le nom et l'âge d'un profil dans Firestore
  Future<void> _editProfile(String profileId, String currentName, int currentAge) async {
    final nameController = TextEditingController(text: currentName);
    final ageController = TextEditingController(text: currentAge.toString());
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        final isDark = appSettings.isDarkMode;
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          title: Text('Modifier le profil', style: TextStyle(color: isDark ? Colors.white : Colors.black)),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  style: TextStyle(color: isDark ? Colors.white : Colors.black),
                  decoration: const InputDecoration(labelText: 'Nom'),
                  validator: (v) => v == null || v.trim().isEmpty ? 'Entrez un nom' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: ageController,
                  style: TextStyle(color: isDark ? Colors.white : Colors.black),
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Âge'),
                  validator: (v) => v == null || int.tryParse(v) == null ? 'Entrez un âge valide' : null,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                Navigator.pop(context);

                try {
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(_uid)
                      .collection('profiles')
                      .doc(profileId)
                      .update({
                    'name': nameController.text.trim(),
                    'age': int.parse(ageController.text.trim()),
                  });

                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Profil mis à jour !'), backgroundColor: Colors.green),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Erreur : $e'), backgroundColor: Colors.red),
                    );
                  }
                }
              },
              child: const Text('Sauvegarder'),
            ),
          ],
        );
      },
    );
  }

  // Supprime un profil après confirmation
  Future<void> _deleteProfile(String profileId, String profileName) async {
    final isDark = appSettings.isDarkMode;
    
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        title: Text('Supprimer le profil', style: TextStyle(color: isDark ? Colors.white : Colors.black)),
        content: Text(
          'Voulez-vous vraiment supprimer le profil de $profileName ? Cette action est irréversible.',
          style: TextStyle(color: isDark ? Colors.white70 : Colors.black87),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(_uid)
            .collection('profiles')
            .doc(profileId)
            .delete();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profil supprimé'), backgroundColor: Colors.orange),
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

  // Simule le changement de profil actif de l'application
  void _selectProfile(String profileId, String name) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Profil actif : $name'), backgroundColor: Colors.indigo),
    );
    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = appSettings.isDarkMode;
    final primaryTextColor = isDark ? Colors.white : Colors.black;

    if (_uid == null) {
      return const Scaffold(body: Center(child: Text('Veuillez vous connecter.')));
    }

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F1123) : const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Gérer les profils', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: primaryTextColor,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(_uid)
            .collection('profiles')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data?.docs ?? [];

          return GridView.builder(
            padding: const EdgeInsets.all(24),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.75, // Ajusté pour accueillir les deux boutons
            ),
            itemCount: docs.length + 1,
            itemBuilder: (context, index) {
              // Bouton de création
              if (index == docs.length) {
                return InkWell(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const ProfileCreationPage()),
                    );
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E203B) : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey.withOpacity(0.3), style: BorderStyle.solid, width: 2),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_circle_outline, size: 48, color: isDark ? Colors.white70 : Colors.grey),
                        const SizedBox(height: 12),
                        Text(
                          'Créer un profil',
                          style: TextStyle(fontWeight: FontWeight.bold, color: primaryTextColor),
                        ),
                      ],
                    ),
                  ),
                );
              }

              // Profil existant
              final profile = docs[index];
              final data = profile.data() as Map<String, dynamic>;
              final String name = data['name'] ?? 'Aventurier';
              final int age = data['age'] ?? 0;

              return Container(
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E203B) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ],
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
                              child: Text(
                                name.trim().isNotEmpty ? name.trim()[0].toUpperCase() : '?',
                                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0F1123)),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: primaryTextColor),
                            ),
                            Text(
                              '$age ans',
                              style: const TextStyle(color: Colors.grey, fontSize: 13),
                            ),
                            const Spacer(),
                            // Ligne de boutons : Modifier et Supprimer
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, size: 20, color: Colors.blue),
                                  onPressed: () => _editProfile(profile.id, name, age),
                                  constraints: const BoxConstraints(),
                                  padding: EdgeInsets.zero,
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete_outline, size: 20, color: Colors.red.shade400),
                                  onPressed: () => _deleteProfile(profile.id, name),
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