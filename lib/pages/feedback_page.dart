import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lumiconte/models/feedback_model.dart';
import 'package:lumiconte/theme/app_theme.dart';

class FeedbackPage extends StatefulWidget {
  final String profileId; // ID du profil actif (ProfileModel.id)

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
      if (user == null) throw Exception('Utilisateur non connecté');

      final String uid = user.uid;

      final profileFeedbackCollection = FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('profiles')
          .doc(widget.profileId)
          .collection('feedbacks');

      // --- SÉCURITÉ ANTI-SPAM VIA FeedbackModel ---
      final allFeedbacksSnapshot = await profileFeedbackCollection.get(
        const GetOptions(source: Source.server),
      );

      if (allFeedbacksSnapshot.docs.isNotEmpty) {
        final feedbacks = allFeedbacksSnapshot.docs
            .map((doc) => FeedbackModel.fromMap(doc.data(), doc.id))
            .toList();

        feedbacks.sort((a, b) => b.createdAt.compareTo(a.createdAt));

        final DateTime lastFeedbackDate = feedbacks.first.createdAt;
        final difference = DateTime.now().difference(lastFeedbackDate);

        if (difference.inMinutes >= 0 && difference.inMinutes < 5) {
          setState(() => _isSending = false);

          if (mounted) {
            final cardBg = AppTheme.getCardColor(context);
            final isDark = Theme.of(context).brightness == Brightness.dark;

            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (BuildContext context) {
                return AlertDialog(
                  backgroundColor: cardBg,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  title: Text(
                    'Action bloquée',
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  content: Text(
                    'Pour éviter les abus, vous devez attendre 5 minutes entre chaque commentaire.',
                    style: TextStyle(
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text(
                        'D\'accord',
                        style: TextStyle(
                          color: AppTheme.accentColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          }
          return;
        }
      }

      // --- CRÉATION ET ENVOI DU FEEDBACK VIA LE MODÈLE ---
      final newFeedback = FeedbackModel(
        id: '',
        message: _feedbackController.text.trim(),
        createdAt: DateTime.now(),
        platform: 'Android/iOS',
      );

      await profileFeedbackCollection.add(newFeedback.toMap());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Merci ! Votre commentaire a bien été envoyé.'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de l\'envoi : $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final primaryTextColor = isDark ? Colors.white : Colors.black87;
    final cardColor = AppTheme.getCardColor(context);
    final backgroundColor = theme.scaffoldBackgroundColor; // 🟣 Prend le violet darkBg (0xFF1E1B29)

    return Scaffold(
      backgroundColor: backgroundColor, // 🔴 Force le fond général
      appBar: AppBar(
        backgroundColor: backgroundColor, // 🔴 Assure que l'AppBar n'a pas de fond noir
        surfaceTintColor: Colors.transparent, // Désactive l'effet de surface Material 3
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: primaryTextColor,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Envoyer un commentaire',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: primaryTextColor,
          ),
        ),
      ),
      body: _isSending
          ? const Center(
              child: CircularProgressIndicator(
                color: AppTheme.accentColor,
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Votre avis nous intéresse !',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: primaryTextColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Une idée, un bug ou une suggestion ? Écrivez-nous ci-dessous. Nous lisons tous vos messages.',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _feedbackController,
                      maxLines: 6,
                      maxLength: _maxCharacters,
                      style: TextStyle(color: primaryTextColor),
                      decoration: InputDecoration(
                        hintText: 'Écrivez votre message ici...',
                        hintStyle: TextStyle(
                          color: isDark
                              ? Colors.grey.shade600
                              : Colors.grey.shade400,
                        ),
                        fillColor: cardColor,
                        filled: true,
                        counterText: '$_currentLength / $_maxCharacters',
                        counterStyle: TextStyle(
                          color: isDark
                              ? Colors.grey.shade500
                              : Colors.grey.shade600,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: isDark
                                ? Colors.white.withOpacity(0.05)
                                : Colors.grey.shade200,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(
                            color: AppTheme.accentColor,
                            width: 2,
                          ),
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
                          backgroundColor: AppTheme.accentColor,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                        onPressed: _submitFeedback,
                        child: const Text(
                          'Envoyer',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
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