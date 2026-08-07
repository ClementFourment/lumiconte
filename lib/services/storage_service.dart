import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:path_provider/path_provider.dart';

class StorageService {
  static String get _accessKey => dotenv.env['B2_ACCESS_KEY']!;
  static String get _secretKey => dotenv.env['B2_SECRET_KEY']!;
  static const String _service = 's3';

  /// Récupère un fichier en mémoire en le lisant depuis le DISQUE LOCAL s'il existe déjà.
  /// S'il n'existe pas, il le télécharge depuis B2/R2 et le sauvegarde localement.
  static Future<Uint8List> fetchObjectCached(String url) async {
    final file = await getCachedFile(url);
    return await file.readAsBytes();
  }

  /// Retourne un [File] local. S'il n'est pas en cache, il le télécharge d'abord.
  static Future<File> getCachedFile(String url) async {
    final tempDir = await getTemporaryDirectory();
    
    // Génère un nom de fichier unique basé sur le hash MD5 de l'URL
    final filename = md5.convert(utf8.encode(url)).toString();
    final filePath = '${tempDir.path}/$filename';
    final file = File(filePath);

    // 1. SI LE FICHIER EXISTE SUR LE DISQUE DU TÉLÉPHONE -> 0 APPEL RÉSEAU / 0 REQUÊTE B2
    if (await file.exists()) {
      return file;
    }

    // 2. SINON TÉLÉCHARGEMENT DEPUIS B2/R2 PUIS SAUVEGARDE SUR DISQUE
    final bytes = await fetchObject(url);
    await file.writeAsBytes(bytes);
    return file;
  }

  /// Vide le cache local du téléphone
  static Future<void> clearCache() async {
    final tempDir = await getTemporaryDirectory();
    if (await tempDir.exists()) {
      tempDir.deleteSync(recursive: true);
    }
  }

  static Future<List<int>> fetchObject(String url) async {
    if (url.isEmpty) throw ArgumentError('URL ne peut pas être vide');
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      throw ArgumentError('URL doit commencer par http:// ou https://: $url');
    }

    final uri = Uri.parse(url);
    final host = uri.host;
    if (host.isEmpty) throw ArgumentError('Host vide dans l\'URL: $url');

    final region = _regionFromHost(host);
    final now = DateTime.now().toUtc();
    final amzDate = _formatAmzDate(now);
    final dateStamp = amzDate.substring(0, 8);

    final canonicalUriPath =
        '/' + uri.pathSegments.map(Uri.encodeComponent).join('/');

    final canonicalHeaders = 'host:$host\n'
        'x-amz-content-sha256:$_emptyPayloadHash\n'
        'x-amz-date:$amzDate\n';
    const signedHeaders = 'host;x-amz-content-sha256;x-amz-date';

    final canonicalRequest = [
      'GET',
      canonicalUriPath,
      '',
      canonicalHeaders,
      signedHeaders,
      _emptyPayloadHash,
    ].join('\n');

    const algorithm = 'AWS4-HMAC-SHA256';
    final credentialScope = '$dateStamp/$region/$_service/aws4_request';
    final stringToSign = [
      algorithm,
      amzDate,
      credentialScope,
      sha256.convert(utf8.encode(canonicalRequest)).toString(),
    ].join('\n');

    final signingKey =
        _getSignatureKey(_secretKey, dateStamp, region, _service);

    final signature =
        Hmac(sha256, signingKey).convert(utf8.encode(stringToSign)).toString();

    final authorizationHeader =
        '$algorithm Credential=$_accessKey/$credentialScope, '
        'SignedHeaders=$signedHeaders, Signature=$signature';

    final requestUrl = Uri.https(host, canonicalUriPath);

    final response = await http.get(
      requestUrl,
      headers: {
        'x-amz-date': amzDate,
        'x-amz-content-sha256': _emptyPayloadHash,
        'Authorization': authorizationHeader,
      },
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Erreur B2 (${response.statusCode}): ${response.body}',
      );
    }

    return response.bodyBytes;
  }

  static const String _emptyPayloadHash =
      'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855';

  static String _regionFromHost(String host) {
    final parts = host.split('.');
    if (parts.length < 4) {
      return 'us-west-004';
    }
    return parts[2];
  }

  static String _formatAmzDate(DateTime d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${d.year}${two(d.month)}${two(d.day)}T'
        '${two(d.hour)}${two(d.minute)}${two(d.second)}Z';
  }

  static List<int> _hmacSha256(List<int> key, String data) {
    return Hmac(sha256, key).convert(utf8.encode(data)).bytes;
  }

  static List<int> _getSignatureKey(
      String key, String dateStamp, String regionName, String serviceName) {
    final kDate = _hmacSha256(utf8.encode('AWS4$key'), dateStamp);
    final kRegion = _hmacSha256(kDate, regionName);
    final kService = _hmacSha256(kRegion, serviceName);
    final kSigning = _hmacSha256(kService, 'aws4_request');
    return kSigning;
  }
}