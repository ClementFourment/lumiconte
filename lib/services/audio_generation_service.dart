import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AudioGenerationService {
  static String get _googleApiKey => dotenv.env['GOOGLE_TTS_API_KEY']!;

  static String get _b2KeyId => dotenv.env['B2_KEY_ID']!;
  static String get _b2AppKey => dotenv.env['B2_APP_KEY']!;
  static String get _b2BucketId => dotenv.env['B2_BUCKET_ID']!;

  /// Génère l'audio via Google TTS, l'upload sur B2, et renvoie l'objectKey.
  static Future<String> generateAndUploadAudio({
    required String storyId,
    required String text,
  }) async {
    final audioBytes = await _generateAudio(text);
    final objectKey = 'audio/$storyId.mp3';
    await _uploadToB2(objectKey, audioBytes);
    return objectKey;
  }

  static Future<Uint8List> _generateAudio(String text) async {
    final response = await http.post(
      Uri.parse(
        'https://texttospeech.googleapis.com/v1/text:synthesize?key=$_googleApiKey',
      ),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'input': {'text': text},
        'voice': {'languageCode': 'fr-FR', 'name': 'fr-FR-Standard-G'},
        'audioConfig': {'audioEncoding': 'MP3', 'speakingRate': 0.92},
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Erreur Google TTS: ${response.body}');
    }

    final data = jsonDecode(response.body);
    final audioContent = data['audioContent'] as String?;
    if (audioContent == null) {
      throw Exception('Réponse Google TTS inattendue: ${response.body}');
    }

    return base64Decode(audioContent);
  }

  static Future<void> _uploadToB2(String objectKey, Uint8List bytes) async {
    // 1. Authentification B2 (native API, pas S3-compatible)
    final authResponse = await http.get(
      Uri.parse('https://api.backblazeb2.com/b2api/v3/b2_authorize_account'),
      headers: {
        'Authorization':
            'Basic ${base64Encode(utf8.encode('$_b2KeyId:$_b2AppKey'))}',
      },
    );

    if (authResponse.statusCode != 200) {
      throw Exception('Erreur auth B2: ${authResponse.body}');
    }

    final authData = jsonDecode(authResponse.body);
    final apiUrl = authData['apiInfo']['storageApi']['apiUrl'];
    final authToken = authData['authorizationToken'];

    // 2. Récupère une URL d'upload temporaire
    final uploadUrlResponse = await http.post(
      Uri.parse('$apiUrl/b2api/v3/b2_get_upload_url'),
      headers: {'Authorization': authToken},
      body: jsonEncode({'bucketId': _b2BucketId}),
    );

    if (uploadUrlResponse.statusCode != 200) {
      throw Exception('Erreur get_upload_url B2: ${uploadUrlResponse.body}');
    }

    final uploadData = jsonDecode(uploadUrlResponse.body);
    final uploadUrl = uploadData['uploadUrl'];
    final uploadAuthToken = uploadData['authorizationToken'];

    // 3. Upload effectif du fichier
    final sha1Hash = sha1.convert(bytes).toString();

    final uploadResponse = await http.post(
      Uri.parse(uploadUrl),
      headers: {
        'Authorization': uploadAuthToken,
        'X-Bz-File-Name': Uri.encodeComponent(objectKey),
        'Content-Type': 'audio/mpeg',
        'X-Bz-Content-Sha1': sha1Hash,
        'Content-Length': bytes.length.toString(),
      },
      body: bytes,
    );

    if (uploadResponse.statusCode != 200) {
      throw Exception('Erreur upload B2: ${uploadResponse.body}');
    }
  }
}
