import 'package:flutter/material.dart';

class ManageProfilesPage extends StatelessWidget {
  const ManageProfilesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Gérer les profils'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: const Center(
        child: Text('Page de gestion des profils (Bientôt disponible)'),
      ),
    );
  }
}