import 'package:flutter/material.dart';
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

  final AuthService _authService = AuthService();
  bool _isLoading = false;

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
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: _isLoading
              ? const _LoadingIndicator()
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Bouton Paramètres (Style épuré standard)
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.black,
                          side: const BorderSide(color: Colors.grey),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => SettingsPage(profileId: widget.profileId),
                            ),
                          );
                        },
                        icon: const Icon(Icons.settings, color: Colors.black87),
                        label: const Text('Paramètres de lecture'),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Bouton Déconnexion (D'origine)
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.black,
                          textStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        onPressed: _handleSignOut,
                        child: const Text('Se déconnecter'),
                      ),
                    ),
                  ],
                ),
        ),
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
        Text(
          "Déconnexion en cours...",
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}