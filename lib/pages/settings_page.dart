import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
  final String _uid = FirebaseAuth.instance.currentUser!.uid;
  late final CollectionReference _settingsCollection;

  @override
  void initState() {
    super.initState();
    _settingsCollection = FirebaseFirestore.instance
        .collection('users')
        .doc(_uid)
        .collection('profiles')
        .doc(widget.profileId)
        .collection('settings');
  }

  Future<void> _updateSetting(String docId, String key, dynamic value) async {
    await _settingsCollection.doc(docId).update({key: value});
  }

  // 🧪 Algorithme de découpage en syllabes et détection des lettres muettes
  List<TextSpan> _parseWordToDyslexiaSpans(String word, TextStyle baseDysStyle, Color defaultTextColor) {
    final Color colorRed = Colors.red.shade700;
    final Color colorBlue = Colors.blue.shade700;
    final Color colorSilent = defaultTextColor.withOpacity(0.35);

    if (word.trim().isEmpty) {
      return [TextSpan(text: word, style: baseDysStyle.copyWith(color: defaultTextColor))];
    }

    final matchStart = RegExp(r'^[^a-zA-ZÀ-ÿ]+').firstMatch(word);
    final matchEnd = RegExp(r'[^a-zA-ZÀ-ÿ]+$').firstMatch(word);
    
    String prefix = matchStart?.group(0) ?? '';
    String suffix = matchEnd?.group(0) ?? '';
    
    String cleanWord = word;
    
    if (prefix.length + suffix.length < word.length) {
      cleanWord = word.substring(prefix.length, word.length - suffix.length);
    } else {
      return [TextSpan(text: word, style: baseDysStyle.copyWith(color: defaultTextColor))];
    }

    if (cleanWord.isEmpty) {
      return [TextSpan(text: word, style: baseDysStyle.copyWith(color: defaultTextColor))];
    }

    String silentLetters = '';
    final silentMatch = RegExp(r'(ts|ds|es|[stdxega])$', caseSensitive: false).firstMatch(cleanWord);
    
    if (silentMatch != null && cleanWord.length > 2 && !['les', 'des', 'mes', 'tes', 'ses', 'est'].contains(cleanWord.toLowerCase())) {
      String potentialSilent = silentMatch.group(0) ?? '';
      if (cleanWord.length > potentialSilent.length) {
        silentLetters = potentialSilent;
        cleanWord = cleanWord.substring(0, cleanWord.length - silentLetters.length);
      }
    }

    List<TextSpan> wordSpans = [];
    
    if (prefix.isNotEmpty) {
      wordSpans.add(TextSpan(text: prefix, style: baseDysStyle.copyWith(color: defaultTextColor)));
    }

    List<String> syllables = [];
    if (cleanWord.length <= 3) {
      syllables.add(cleanWord);
    } else {
      final regex = RegExp(r'[^aeiouyéèàùûâîôœüéèêë]*[aeiouyéèàùûâîôœüéèêë]+(?:[^aeiouyéèàùûâîôœüéèêë](?![aeiouyéèàùûâîôœüéèêë]))*', caseSensitive: false);
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
      wordSpans.add(TextSpan(text: suffix, style: baseDysStyle.copyWith(color: defaultTextColor)));
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
      allSpans.addAll(_parseWordToDyslexiaSpans(words[i], baseDysStyle, defaultTextColor));
      if (i < words.length - 1) {
        allSpans.add(TextSpan(text: ' ', style: baseDysStyle));
      }
    }

    return TextSpan(children: allSpans);
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
          final settingsData = settingsDoc.data() as Map<String, dynamic>;
          final String docId = settingsDoc.id;

          final bool dyslexia = settingsData['dyslexia'] ?? false;
          final double fontSize = (settingsData['fontSize'] ?? 16).toDouble();
          final String currentTheme = settingsData['theme'] ?? 'light';

          Color previewBg;
          Color previewText;

          if (dyslexia) {
            previewBg = Colors.white;
            previewText = const Color(0xFF2B261F);
          } else if (currentTheme == 'dark') {
            previewBg = const Color(0xFF1C1C1E);
            previewText = Colors.white;
          } else if (currentTheme == 'naturel') {
            previewBg = const Color(0xFFF5EFE6);
            previewText = const Color(0xFF2B261F);
          } else {
            previewBg = Colors.white;
            previewText = Colors.black;
          }

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
                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
                  ),
                  subtitle: const Text('Adapte les couleurs, l\'espacement et la taille'),
                  value: dyslexia,
                  activeColor: Colors.deepPurple,
                  onChanged: (bool value) {
                    _updateSetting(docId, 'dyslexia', value);
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
                            style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
                          ),
                          Text(
                            '${(((fontSize / 16) * 10).round() * 10).clamp(80, 200)} %',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple),
                          ),
                        ],
                      ),
                      Slider(
                        value: (((fontSize / 16) * 10).round() * 10).clamp(80, 200).toDouble(),
                        min: 80,   
                        max: 200,  
                        divisions: 12, 
                        activeColor: Colors.deepPurple,
                        inactiveColor: Colors.grey.shade200,
                        onChanged: (double percentageValue) {
                          double calculatedPixels = (percentageValue / 100) * 16;
                          _updateSetting(docId, 'fontSize', calculatedPixels.round());
                        },
                      ),
                      const SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: previewBg,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: RichText(
                          textAlign: TextAlign.left,
                          text: _buildColorizedText(
                            text: 'Je ne puis pas jouer avec toi, dit le renard. Les hommes chassent. C\'est bien gênant !',
                            baseFontSize: fontSize,
                            defaultTextColor: previewText,
                            isDyslexiaEnabled: dyslexia,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),

              // 🌟 ICI : Condition de masquage des thèmes si le mode dyslexie est activé
              if (!dyslexia) ...[
                const SizedBox(height: 24),
                _buildSectionTitle('Thème de lecture'),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildThemeOption(
                      label: 'Clair',
                      themeKey: 'light',
                      currentTheme: currentTheme,
                      bgColor: Colors.white,
                      textColor: Colors.black,
                      borderColor: Colors.grey.shade300,
                      docId: docId,
                    ),
                    _buildThemeOption(
                      label: 'Sombre',
                      themeKey: 'dark',
                      currentTheme: currentTheme,
                      bgColor: const Color(0xFF1C1C1E),
                      textColor: Colors.white,
                      borderColor: Colors.transparent,
                      docId: docId,
                    ),
                    _buildThemeOption(
                      label: 'Naturel',
                      themeKey: 'naturel',
                      currentTheme: currentTheme,
                      bgColor: const Color(0xFFF5EFE6),
                      textColor: const Color(0xFF2B261F),
                      borderColor: Colors.transparent,
                      docId: docId,
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
    required String docId,
  }) {
    final bool isSelected = currentTheme == themeKey;

    return GestureDetector(
      onTap: () => _updateSetting(docId, 'theme', themeKey),
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