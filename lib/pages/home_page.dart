import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Lumiconte"),
        actions: [
            IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                    
                    await GoogleSignIn().signOut();
                },
            )
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Bonjour !",
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const Text("Prêt à lire une nouvelle histoire ?"),
            const SizedBox(height: 40),
            
            // Un bouton d'action principal pour le MVP
            ElevatedButton(
              onPressed: () {
                // Action pour commencer la lecture
              },
              child: const Text("Choisir une histoire"),
            ),
          ],
        ),
      ),
    );
  }
}