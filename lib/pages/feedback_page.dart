import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lumiconte/main.dart'; // Pour appSettings

class FeedbackPage extends StatefulWidget {
  final String profileId; // Reçoit l'ID du profil actuel

  const FeedbackPage({
    super.key,
    required this.profileId,
  });

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  final TextEditingController _feedbackController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isSending = false;
  
  static const int _maxCharacters = 500;
  int _currentLength = 0;

  @override
  void initState() {
    super.initState();
    _feedbackController.addListener(() {
      setState(() {
        _currentLength = _feedbackController.text.length;
      });
    });
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  Future<void> _submitFeedback() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSending = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw 'Utilisateur non connecté';

      final String uid = user.uid;
      final now = Timestamp.now();

      final profileFeedbackCollection = FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('profiles')
          .doc(widget.profileId)
          .collection('feedbacks');

      // --- SÉCURIÉ ANTI-SPAM (TRI EN DART) ---
      final allFeedbacksSnapshot = await profileFeedbackCollection.get(
        const GetOptions(source: Source.server),
      );

      if (allFeedbacksSnapshot.docs.isNotEmpty) {
        final timestamps = allFeedbacksSnapshot.docs
            .map((doc) => doc.data()['createdAt'] as Timestamp?)
            .where((t) => t != null)
            .map((t) => t!.toDate())
            .toList();

        if (timestamps.isNotEmpty) {
          timestamps.sort((a, b) => b.compareTo(a));
          final DateTime lastFeedbackDate = timestamps.first;
          final difference = DateTime.now().difference(lastFeedbackDate);

          if (difference.inMinutes >= 0 && difference.inMinutes < 5) {
            setState(() => _isSending = false);
            
            if (mounted) {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext context) {
                  final isDark = appSettings.isDarkMode;
                  return AlertDialog(
                    backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    title: const Text('Action bloquée'),
                    content: const Text('Pour éviter les abus, vous devez attendre 5 minutes entre chaque commentaire.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('D\'accord'),
                      ),
                    ],
                  );
                },
              );
            }
            return;
          }
        }
      }

      // --- ENVOI DU COMMENTAIRE ---
      await profileFeedbackCollection.add({
        'message': _feedbackController.text.trim(),
        'createdAt': now,
        'platform': 'Android/iOS',
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Merci ! Votre commentaire a bien été envoyé.'), backgroundColor: Colors.green),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de l\'envoi : $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = appSettings.isDarkMode;
    final primaryTextColor = isDark ? Colors.white : Colors.black;
    final cardColor = Theme.of(context).cardColor;

    return Scaffold(
      backgroundColor: isDark ? Theme.of(context).scaffoldBackgroundColor : const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Envoyer un commentaire', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: primaryTextColor,
      ),
      body: _isSending
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Votre avis nous intéresse !',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: primaryTextColor),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Une idée, un bug ou une suggestion ? Écrivez-nous ci-dessous. Nous lisons tous vos messages.',
                      style: TextStyle(fontSize: 14, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600),
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _feedbackController,
                      maxLines: 6,
                      maxLength: _maxCharacters,
                      style: TextStyle(color: primaryTextColor),
                      decoration: InputDecoration(
                        hintText: 'Écrivez votre message ici...',
                        hintStyle: TextStyle(color: isDark ? Colors.grey.shade600 : Colors.grey.shade400),
                        fillColor: cardColor,
                        filled: true,
                        counterText: '$_currentLength / $_maxCharacters',
                        counterStyle: TextStyle(color: isDark ? Colors.grey.shade500 : Colors.grey.shade600),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: isDark ? Colors.grey.shade800 : Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: isDark ? Colors.grey.shade800 : Colors.grey.shade200),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Le message ne peut pas être vide';
                        }
                        if (value.trim().length < 10) {
                          return 'Le message est un peu trop court (10 caractères min)';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFDB833),
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        onPressed: _submitFeedback,
                        child: const Text(
                          'Envoyer',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}