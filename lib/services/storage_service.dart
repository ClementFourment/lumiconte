import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;

class StorageService {
  static const String _accessKey = 'REMOVED_B2_ACCESS_KEY';
  static const String _secretKey = 'REMOVED_B2_SECRET_KEY';
  static const String _service = 's3';

  static final Map<String, Future<Uint8List>> _cache = {};

  static Future<Uint8List> fetchObjectCached(String url) {
    return _cache.putIfAbsent(
      url,
      () => fetchObject(url).then(Uint8List.fromList),
    );
  }

  static void clearCache() => _cache.clear();

  static Future<List<int>> fetchObject(String url) async {
    final uri = Uri.parse(url);
    final host = uri.host;
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
    if (parts.length < 3) {
      throw ArgumentError('Host inattendu, région introuvable: $host');
    }
    return parts[2]; // [bucket, s3, region, backblazeb2, com]
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
