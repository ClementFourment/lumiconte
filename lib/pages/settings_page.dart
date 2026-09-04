import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lumiconte/models/settings_model.dart';
import 'package:lumiconte/theme/app_theme.dart';

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

  static const String _localPreviewImageAsset = 'assets/images/preview_cover.webp';

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

  Future<void> _updateSetting(String docId, String key, dynamic value) async {
    await _settingsCollection.doc(docId).update({key: value});
  }

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
    TextStyle? customTextStyle,
  }) {
    if (!isDyslexiaEnabled) {
      return TextSpan(
        text: text,
        style: (customTextStyle ?? const TextStyle()).copyWith(
          color: defaultTextColor,
          fontSize: baseFontSize,
        ),
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

  Widget _buildPreviewBox(SettingsModel settings, bool isDark) {
    const String sampleText =
        'Il y était une fois, dans une ville de Perse, deux frères nommés Kassim et Ali-Baba.';

    if (settings.dyslexia) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: RichText(
          textAlign: TextAlign.left,
          text: _buildColorizedText(
            text: sampleText,
            baseFontSize: settings.fontSize.toDouble(),
            defaultTextColor: const Color(0xFF2B261F),
            isDyslexiaEnabled: true,
          ),
        ),
      );
    }

    if (settings.readTheme == 'immersive') {
      return Container(
        height: 180,
        width: double.infinity,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: const Color(0xFF161224),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              _localPreviewImageAsset,
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: const Color(0xFF2A2016),
                  child: const Center(
                    child: Icon(Icons.image_not_supported,
                        color: Colors.white24, size: 40),
                  ),
                );
              },
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.3),
                    Colors.black.withOpacity(0.85),
                    Colors.black.withOpacity(0.95),
                  ],
                  stops: const [0.2, 0.5, 0.8, 1.0],
                ),
              ),
            ),
            Positioned(
              bottom: 12,
              left: 16,
              right: 16,
              child: RichText(
                textAlign: TextAlign.left,
                text: _buildColorizedText(
                  text: sampleText,
                  baseFontSize: settings.fontSize.toDouble(),
                  defaultTextColor: Colors.white,
                  isDyslexiaEnabled: false,
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (settings.readTheme == 'manuscript') {
      const pageColor = Color(0xFFFAF6EB);
      const textColor = Color(0xFF2E2418);
      const subtleTextColor = Color(0xFF6B5D52);
      const borderColor = Color(0xFFB8A680);

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: pageColor,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: borderColor, width: 2),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text('❖  ', style: TextStyle(color: subtleTextColor, fontSize: 8)),
                Text('✦', style: TextStyle(color: textColor, fontSize: 10)),
                Text('  ❖', style: TextStyle(color: subtleTextColor, fontSize: 8)),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              height: 50,
              width: 90,
              decoration: BoxDecoration(
                border: Border.all(color: textColor, width: 1),
                color: const Color(0xFFE8DDD0),
              ),
              child: ClipRRect(
                child: Image.asset(
                  _localPreviewImageAsset,
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.image_outlined, size: 20, color: subtleTextColor),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  'I',
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: (settings.fontSize * 2.2).clamp(24.0, 48.0),
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF32271B),
                    height: 0.8,
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: RichText(
                    textAlign: TextAlign.justify,
                    text: _buildColorizedText(
                      text: sampleText.substring(1),
                      baseFontSize: settings.fontSize.toDouble(),
                      defaultTextColor: const Color(0xFF32271B),
                      isDyslexiaEnabled: false,
                      customTextStyle: GoogleFonts.cormorantGaramond(
                        height: 1.4,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text('❖  ❖  ❖', style: TextStyle(color: subtleTextColor, fontSize: 8)),
              ],
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: const Color(0xFF161224),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          Container(
            height: 90,
            width: double.infinity,
            color: const Color(0xFF26203B),
            child: Image.asset(
              _localPreviewImageAsset,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => const Center(
                child: Icon(Icons.image, size: 28, color: Colors.white38),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: RichText(
              textAlign: TextAlign.center,
              text: _buildColorizedText(
                text: sampleText,
                baseFontSize: settings.fontSize.toDouble(),
                defaultTextColor: Colors.white,
                isDyslexiaEnabled: false,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVoiceOption({
    required String label,
    required IconData icon,
    required String genderKey,
    required String currentGender,
    required String settingsId,
    required Color primaryTextColor,
  }) {
    final bool isSelected = currentGender == genderKey;

    return GestureDetector(
      onTap: () => _updateSetting(settingsId, 'voiceGender', genderKey),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.accentColor.withOpacity(0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppTheme.accentColor : Colors.grey.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? AppTheme.accentColor : primaryTextColor.withOpacity(0.7),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppTheme.accentColor : primaryTextColor,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? AppTheme.darkBg : AppTheme.lightBg;
    final cardColor = AppTheme.getCardColor(context);
    final primaryTextColor = isDark ? Colors.white : Colors.black87;
    final secondaryTextColor = isDark ? Colors.grey.shade400 : Colors.black54;
    final borderColor =
        isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade200;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: primaryTextColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Paramètres',
          style: TextStyle(
            color: primaryTextColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _settingsCollection.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppTheme.accentColor,
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                'Aucun paramètre trouvé.',
                style: TextStyle(color: secondaryTextColor),
              ),
            );
          }

          final settingsDoc = snapshot.data!.docs.first;
          final settings = SettingsModel.fromMap(
            settingsDoc.data() as Map<String, dynamic>,
            settingsDoc.id,
          );

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // Voix de la narration
              _buildSectionTitle('Voix de la narration', secondaryTextColor),
              const SizedBox(height: 8),
              Card(
                color: cardColor,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: borderColor),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildVoiceOption(
                          label: 'Féminine',
                          icon: Icons.record_voice_over_rounded,
                          genderKey: 'femme',
                          currentGender: settings.voiceGender,
                          settingsId: settings.id,
                          primaryTextColor: primaryTextColor,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildVoiceOption(
                          label: 'Masculine',
                          icon: Icons.voice_over_off_rounded,
                          genderKey: 'homme',
                          currentGender: settings.voiceGender,
                          settingsId: settings.id,
                          primaryTextColor: primaryTextColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),
              _buildSectionTitle('Accessibilité', secondaryTextColor),
              const SizedBox(height: 8),

              // Mode Dyslexie Card
              Card(
                color: cardColor,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: borderColor),
                ),
                child: SwitchListTile(
                  title: Text(
                    'Mode Dyslexie',
                    style: TextStyle(
                      color: primaryTextColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: Text(
                    'Adapte les couleurs, l\'espacement et la taille',
                    style: TextStyle(color: secondaryTextColor),
                  ),
                  value: settings.dyslexia,
                  activeColor: AppTheme.accentColor,
                  onChanged: (bool value) {
                    _updateSetting(settings.id, 'dyslexia', value);
                  },
                ),
              ),

              const SizedBox(height: 24),
              _buildSectionTitle('Affichage du texte', secondaryTextColor),
              const SizedBox(height: 8),

              // Carte de réglage taille + Aperçu dynamique du thème
              Card(
                color: cardColor,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: borderColor),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Taille du texte',
                            style: TextStyle(
                              color: primaryTextColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            '${(((settings.fontSize / 16) * 10).round() * 10).clamp(80, 200)} %',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.accentColor,
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
                        activeColor: AppTheme.accentColor,
                        inactiveColor:
                            isDark ? Colors.white12 : Colors.grey.shade200,
                        onChangeEnd: (double percentageValue) {
                          double calculatedPixels =
                              (percentageValue / 100) * 16;
                          _updateSetting(
                            settings.id,
                            'fontSize',
                            calculatedPixels.round(),
                          );
                        },
                        onChanged: (double val) {},
                      ),
                      const SizedBox(height: 10),
                      _buildPreviewBox(settings, isDark),
                    ],
                  ),
                ),
              ),

              // Sélection des Thèmes de lecture
              if (!settings.dyslexia) ...[
                const SizedBox(height: 24),
                _buildSectionTitle('Thème de lecture', secondaryTextColor),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildThemeOption(
                      label: 'Classique',
                      themeKey: 'classic',
                      currentTheme: settings.readTheme,
                      settingsId: settings.id,
                      primaryTextColor: primaryTextColor,
                      secondaryTextColor: secondaryTextColor,
                      previewWidget: _buildClassicPreview(),
                    ),
                    _buildThemeOption(
                      label: 'Immersif',
                      themeKey: 'immersive',
                      currentTheme: settings.readTheme,
                      settingsId: settings.id,
                      primaryTextColor: primaryTextColor,
                      secondaryTextColor: secondaryTextColor,
                      previewWidget: _buildImmersivePreview(),
                    ),
                    _buildThemeOption(
                      label: 'Manuscrit',
                      themeKey: 'manuscript',
                      currentTheme: settings.readTheme,
                      settingsId: settings.id,
                      primaryTextColor: primaryTextColor,
                      secondaryTextColor: secondaryTextColor,
                      previewWidget: _buildManuscriptPreview(),
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

  Widget _buildSectionTitle(String title, Color textColor) {
    return Text(
      title,
      style: TextStyle(
        color: textColor,
        fontSize: 14,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildThemeOption({
    required String label,
    required String themeKey,
    required String currentTheme,
    required String settingsId,
    required Color primaryTextColor,
    required Color secondaryTextColor,
    required Widget previewWidget,
  }) {
    final bool isSelected = currentTheme == themeKey;

    return GestureDetector(
      onTap: () => _updateSetting(settingsId, 'readTheme', themeKey),
      child: Column(
        children: [
          Container(
            width: 100,
            height: 70,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected ? AppTheme.accentColor : Colors.transparent,
                width: isSelected ? 2.5 : 0,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: previewWidget,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? primaryTextColor : secondaryTextColor,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClassicPreview() {
    return Container(
      color: const Color(0xFF161224),
      padding: const EdgeInsets.all(4),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF26203B),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Column(
          children: [
            Expanded(
              flex: 4,
              child: Container(
                clipBehavior: Clip.antiAlias,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(6)),
                ),
                child: Image.asset(
                  _localPreviewImageAsset,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: const Color(0xFF4A3E6D),
                    child: const Center(
                      child: Icon(Icons.image, size: 14, color: Colors.white54),
                    ),
                  ),
                ),
              ),
            ),
            const Expanded(
              flex: 6,
              child: Center(
                child: Text(
                  'Aa',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImmersivePreview() {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          _localPreviewImageAsset,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
              Container(color: const Color(0xFF2C241B)),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.black.withOpacity(0.4),
                Colors.black.withOpacity(0.9),
              ],
              stops: const [0.0, 0.4, 1.0],
            ),
          ),
        ),
        const Center(
          child: Text(
            'Aa',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildManuscriptPreview() {
    return Container(
      color: const Color(0xFFEEEADE),
      padding: const EdgeInsets.all(4),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFFAF6EB),
          borderRadius: BorderRadius.circular(2),
          border: Border.all(color: const Color(0xFFB8A680), width: 1.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '✦',
              style: TextStyle(fontSize: 8, color: Color(0xFF2E2418)),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: const [
                Text(
                  'A',
                  style: TextStyle(
                    color: Color(0xFF32271B),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Serif',
                  ),
                ),
                Text(
                  'a',
                  style: TextStyle(
                    color: Color(0xFF32271B),
                    fontSize: 13,
                    fontFamily: 'Serif',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}