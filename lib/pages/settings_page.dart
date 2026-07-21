import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lumiconte/models/settings_model.dart';

class SettingsPage extends StatefulWidget {
  final String profileId;

  const SettingsPage({
    super.key,
    required this.profileId,
  });

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late final String _uid;
  late final CollectionReference _settingsCollection;

  @override
  void initState() {
    super.initState();
    _uid = FirebaseAuth.instance.currentUser!.uid;
    _settingsCollection = FirebaseFirestore.instance
        .collection('users')
        .doc(_uid)
        .collection('profiles')
        .doc(widget.profileId)
        .collection('settings');
  }

  /// Met à jour un seul champ du document settings
  Future<void> _updateSetting(String docId, String key, dynamic value) async {
    await _settingsCollection.doc(docId).update({key: value});
  }

  // 🧪 Algorithme de découpage en syllabes et détection des lettres muettes
  List<TextSpan> _parseWordToDyslexiaSpans(
    String word,
    TextStyle baseDysStyle,
    Color defaultTextColor,
  ) {
    final Color colorRed = Colors.red.shade700;
    final Color colorBlue = Colors.blue.shade700;
    final Color colorSilent = defaultTextColor.withOpacity(0.35);

    if (word.trim().isEmpty) {
      return [
        TextSpan(
            text: word, style: baseDysStyle.copyWith(color: defaultTextColor))
      ];
    }

    final matchStart = RegExp(r'^[^a-zA-ZÀ-ÿ]+').firstMatch(word);
    final matchEnd = RegExp(r'[^a-zA-ZÀ-ÿ]+$').firstMatch(word);

    String prefix = matchStart?.group(0) ?? '';
    String suffix = matchEnd?.group(0) ?? '';

    String cleanWord = word;

    if (prefix.length + suffix.length < word.length) {
      cleanWord = word.substring(prefix.length, word.length - suffix.length);
    } else {
      return [
        TextSpan(
            text: word, style: baseDysStyle.copyWith(color: defaultTextColor))
      ];
    }

    if (cleanWord.isEmpty) {
      return [
        TextSpan(
            text: word, style: baseDysStyle.copyWith(color: defaultTextColor))
      ];
    }

    String silentLetters = '';
    final silentMatch = RegExp(r'(ts|ds|es|[stdxega])$', caseSensitive: false)
        .firstMatch(cleanWord);

    if (silentMatch != null &&
        cleanWord.length > 2 &&
        !['les', 'des', 'mes', 'tes', 'ses', 'est']
            .contains(cleanWord.toLowerCase())) {
      String potentialSilent = silentMatch.group(0) ?? '';
      if (cleanWord.length > potentialSilent.length) {
        silentLetters = potentialSilent;
        cleanWord =
            cleanWord.substring(0, cleanWord.length - silentLetters.length);
      }
    }

    List<TextSpan> wordSpans = [];

    if (prefix.isNotEmpty) {
      wordSpans.add(TextSpan(
          text: prefix, style: baseDysStyle.copyWith(color: defaultTextColor)));
    }

    List<String> syllables = [];
    if (cleanWord.length <= 3) {
      syllables.add(cleanWord);
    } else {
      final regex = RegExp(
        r'[^aeiouyéèàùûâîôœüéèêë]*[aeiouyéèàùûâîôœüéèêë]+(?:[^aeiouyéèàùûâîôœüéèêë](?![aeiouyéèàùûâîôœüéèêë]))*',
        caseSensitive: false,
      );
      final matches = regex.allMatches(cleanWord);
      if (matches.isEmpty) {
        syllables.add(cleanWord);
      } else {
        for (var m in matches) {
          syllables.add(m.group(0) ?? '');
        }
        int totalLength = syllables.join().length;
        if (totalLength < cleanWord.length && syllables.isNotEmpty) {
          syllables[syllables.length - 1] += cleanWord.substring(totalLength);
        }
      }
    }

    for (int i = 0; i < syllables.length; i++) {
      if (syllables[i].isEmpty) continue;
      wordSpans.add(TextSpan(
        text: syllables[i],
        style: baseDysStyle.copyWith(
          color: i % 2 == 0 ? colorBlue : colorRed,
        ),
      ));
    }

    if (silentLetters.isNotEmpty) {
      wordSpans.add(TextSpan(
        text: silentLetters,
        style: baseDysStyle.copyWith(
          color: colorSilent,
          fontWeight: FontWeight.w300,
          fontStyle: FontStyle.italic,
        ),
      ));
    }

    if (suffix.isNotEmpty) {
      wordSpans.add(TextSpan(
          text: suffix, style: baseDysStyle.copyWith(color: defaultTextColor)));
    }

    return wordSpans;
  }

  TextSpan _buildColorizedText({
    required String text,
    required double baseFontSize,
    required Color defaultTextColor,
    required bool isDyslexiaEnabled,
  }) {
    if (!isDyslexiaEnabled) {
      return TextSpan(
        text: text,
        style: TextStyle(color: defaultTextColor, fontSize: baseFontSize),
      );
    }

    final double dysFontSize = baseFontSize + 4;
    const double dysLetterSpacing = 1.8;
    const double dysLineHeight = 1.6;

    final TextStyle baseDysStyle = TextStyle(
      fontSize: dysFontSize,
      letterSpacing: dysLetterSpacing,
      height: dysLineHeight,
      fontWeight: FontWeight.bold,
    );

    List<TextSpan> allSpans = [];
    List<String> words = text.split(' ');

    for (int i = 0; i < words.length; i++) {
      allSpans.addAll(
          _parseWordToDyslexiaSpans(words[i], baseDysStyle, defaultTextColor));
      if (i < words.length - 1) {
        allSpans.add(TextSpan(text: ' ', style: baseDysStyle));
      }
    }

    return TextSpan(children: allSpans);
  }

  /// Retourne les couleurs d'aperçu selon le thème et mode dyslexie
  _PreviewColors _getPreviewColors(SettingsModel settings) {
    if (settings.dyslexia) {
      return _PreviewColors(
        backgroundColor: Colors.white,
        textColor: const Color(0xFF2B261F),
      );
    }

    switch (settings.theme) {
      case 'dark':
        return _PreviewColors(
          backgroundColor: const Color(0xFF1C1C1E),
          textColor: Colors.white,
        );
      case 'naturel':
        return _PreviewColors(
          backgroundColor: const Color(0xFFF5EFE6),
          textColor: const Color(0xFF2B261F),
        );
      case 'light':
      default:
        return _PreviewColors(
          backgroundColor: Colors.white,
          textColor: Colors.black,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          'Paramètres',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _settingsCollection.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'Aucun paramètre trouvé.',
                style: TextStyle(color: Colors.black54),
              ),
            );
          }

          final settingsDoc = snapshot.data!.docs.first;
          final settings = SettingsModel.fromMap(
            settingsDoc.data() as Map<String, dynamic>,
            settingsDoc.id,
          );

          final previewColors = _getPreviewColors(settings);

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _buildSectionTitle('Accessibilité'),
              const SizedBox(height: 8),

              // Mode Dyslexie Card
              Card(
                color: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.grey.shade200),
                ),
                child: SwitchListTile(
                  title: const Text(
                    'Mode Dyslexie',
                    style: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.w500),
                  ),
                  subtitle: const Text(
                      'Adapte les couleurs, l\'espacement et la taille'),
                  value: settings.dyslexia,
                  activeColor: Colors.deepPurple,
                  onChanged: (bool value) {
                    _updateSetting(settings.id, 'dyslexia', value);
                  },
                ),
              ),

              const SizedBox(height: 24),
              _buildSectionTitle('Affichage du texte'),
              const SizedBox(height: 8),

              // Taille de la police Card
              Card(
                color: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.grey.shade200),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Taille du texte',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            '${(((settings.fontSize / 16) * 10).round() * 10).clamp(80, 200)} %',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.deepPurple,
                            ),
                          ),
                        ],
                      ),
                      Slider(
                        value: (((settings.fontSize / 16) * 10).round() * 10)
                            .clamp(80, 200)
                            .toDouble(),
                        min: 80,
                        max: 200,
                        divisions: 12,
                        activeColor: Colors.deepPurple,
                        inactiveColor: Colors.grey.shade200,
                        onChanged: (double percentageValue) {
                          double calculatedPixels =
                              (percentageValue / 100) * 16;
                          _updateSetting(
                            settings.id,
                            'fontSize',
                            calculatedPixels.round(),
                          );
                        },
                      ),
                      const SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: previewColors.backgroundColor,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: RichText(
                          textAlign: TextAlign.left,
                          text: _buildColorizedText(
                            text:
                                'Je ne puis pas jouer avec toi, dit le renard. Les hommes chassent. C\'est bien gênant !',
                            baseFontSize: settings.fontSize.toDouble(),
                            defaultTextColor: previewColors.textColor,
                            isDyslexiaEnabled: settings.dyslexia,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 🌟 Les thèmes sont masqués si le mode dyslexie est activé
              if (!settings.dyslexia) ...[
                const SizedBox(height: 24),
                _buildSectionTitle('Thème de lecture'),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildThemeOption(
                      label: 'Clair',
                      themeKey: 'light',
                      currentTheme: settings.theme,
                      bgColor: Colors.white,
                      textColor: Colors.black,
                      borderColor: Colors.grey.shade300,
                      settingsId: settings.id,
                    ),
                    _buildThemeOption(
                      label: 'Sombre',
                      themeKey: 'dark',
                      currentTheme: settings.theme,
                      bgColor: const Color(0xFF1C1C1E),
                      textColor: Colors.white,
                      borderColor: Colors.transparent,
                      settingsId: settings.id,
                    ),
                    _buildThemeOption(
                      label: 'Naturel',
                      themeKey: 'naturel',
                      currentTheme: settings.theme,
                      bgColor: const Color(0xFFF5EFE6),
                      textColor: const Color(0xFF2B261F),
                      borderColor: Colors.transparent,
                      settingsId: settings.id,
                    ),
                  ],
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.black54,
        fontSize: 14,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildThemeOption({
    required String label,
    required String themeKey,
    required String currentTheme,
    required Color bgColor,
    required Color textColor,
    required Color borderColor,
    required String settingsId,
  }) {
    final bool isSelected = currentTheme == themeKey;

    return GestureDetector(
      onTap: () => _updateSetting(settingsId, 'theme', themeKey),
      child: Column(
        children: [
          Container(
            width: 100,
            height: 70,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected ? Colors.deepPurple : borderColor,
                width: isSelected ? 2.5 : 1,
              ),
            ),
            child: Center(
              child: Text(
                'Aa',
                style: TextStyle(
                  color: textColor,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.black : Colors.black54,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

/// Classe helper pour les couleurs d'aperçu
class _PreviewColors {
  final Color backgroundColor;
  final Color textColor;

  _PreviewColors({
    required this.backgroundColor,
    required this.textColor,
  });
}
