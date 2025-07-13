import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:marvel/modules/character.dart';

class MyApi {
  static const _publicKey = '77d174521b4379ef387784a8ef738818';
  static const _privateKey = '90861235491e0fa6e581286d1e28c8cf9a41de73';
  static const _baseUrl = 'https://gateway.marvel.com/v1/public/characters';

  String _generateHash(String ts) {
    final bytes = utf8.encode('$ts$_privateKey$_publicKey');
    return md5.convert(bytes).toString();
  }

  Uri _buildUri({
    required String ts,
    String? nameStartsWith,
    int limit = 20,
    int offset = 0,
    String orderBy = 'name',
  }) {
    final hash = _generateHash(ts);
    final params = <String, String>{
      'ts': ts,
      'apikey': _publicKey,
      'hash': hash,
      'limit': limit.toString(),
      'offset': offset.toString(),
      'orderBy': orderBy,
    };
    if (nameStartsWith != null) {
      params['nameStartsWith'] = nameStartsWith;
    }
    return Uri.parse(_baseUrl).replace(queryParameters: params);
  }

  Future<List<Character>> fetchCharacters({
    String? nameStartsWith,
    int limit = 20,
    int offset = 0,
    String orderBy = 'name',
  }) async {
    final ts = DateTime.now().millisecondsSinceEpoch.toString();
    final uri = _buildUri(
      ts: ts,
      nameStartsWith: nameStartsWith,
      limit: limit,
      offset: offset,
      orderBy: orderBy,
    );

    try {
      final response = await http.get(uri);
      if (response.statusCode != 200) {
        throw HttpException(
          'Marvel API Hatası: ${response.statusCode}',
          uri: uri,
        );
      }

      final Map<String, dynamic> json = jsonDecode(response.body);
      final data = json['data'] as Map<String, dynamic>;
      final results = data['results'] as List<dynamic>;
      return results
          .map((item) => Character.fromJson(item as Map<String, dynamic>))
          .toList();
    } on SocketException {
      throw const HttpException('İnternet bağlantınızı kontrol edin.');
    } catch (e) {
      rethrow;
    }
  }

  Future<Character?> fetchCharacterById(int id) async {
    final ts = DateTime.now().millisecondsSinceEpoch.toString();
    final hash = _generateHash(ts);

    final uri = Uri.parse(
      '$_baseUrl/$id',
    ).replace(queryParameters: {'ts': ts, 'apikey': _publicKey, 'hash': hash});

    try {
      final response = await http.get(uri);
      if (response.statusCode != 200) {
        throw HttpException(
          'Marvel API Hatası: ${response.statusCode}',
          uri: uri,
        );
      }

      final Map<String, dynamic> json = jsonDecode(response.body);
      final results = (json['data']['results'] as List<dynamic>);
      if (results.isEmpty) return null;

      return Character.fromJson(results.first as Map<String, dynamic>);
    } on SocketException {
      throw const HttpException('İnternet bağlantınızı kontrol edin.');
    } catch (e) {
      rethrow;
    }
  }
}
