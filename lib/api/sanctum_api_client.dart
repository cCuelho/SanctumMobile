import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config.dart';

class SanctumApiException implements Exception {
  SanctumApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => 'SanctumApiException($statusCode): $message';
}

/// Thin REST client for the Sanctum Flask API (local-first, no auth token on MVP).
class SanctumApiClient {
  SanctumApiClient(this.config, {http.Client? httpClient})
      : _http = httpClient ?? http.Client();

  final SanctumConfig config;
  final http.Client _http;

  Uri _uri(String path) {
    final normalized = path.startsWith('/') ? path : '/$path';
    return Uri.parse('${config.apiBaseUrl}$normalized');
  }

  Map<String, String> get _jsonHeaders => const {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  Future<bool> healthCheck() async {
    try {
      final response = await _http
          .get(_uri('/api/health'))
          .timeout(const Duration(seconds: 8));
      if (response.statusCode != 200) return false;
      final body = jsonDecode(response.body);
      return body is Map && body['status'] == 'ok';
    } catch (_) {
      return false;
    }
  }

  Future<Map<String, dynamic>> getJson(String path) async {
    final response = await _http.get(_uri(path), headers: _jsonHeaders);
    return _decodeObject(response);
  }

  Future<List<dynamic>> getList(String path) async {
    final response = await _http.get(_uri(path), headers: _jsonHeaders);
    final decoded = _decode(response);
    if (decoded is List) return decoded;
    throw SanctumApiException('Expected JSON array from $path');
  }

  Future<Map<String, dynamic>> postJson(
    String path,
    Map<String, dynamic> body,
  ) async {
    final response = await _http.post(
      _uri(path),
      headers: _jsonHeaders,
      body: jsonEncode(body),
    );
    return _decodeObject(response);
  }

  Future<Map<String, dynamic>> patchJson(
    String path,
    Map<String, dynamic> body,
  ) async {
    final response = await _http.patch(
      _uri(path),
      headers: _jsonHeaders,
      body: jsonEncode(body),
    );
    return _decodeObject(response);
  }

  Future<Map<String, dynamic>> putJson(
    String path,
    Map<String, dynamic> body,
  ) async {
    final response = await _http.put(
      _uri(path),
      headers: _jsonHeaders,
      body: jsonEncode(body),
    );
    return _decodeObject(response);
  }

  Future<List<int>> downloadBytes(String path) async {
    final response = await _http.get(_uri(path), headers: _jsonHeaders);
    if (response.statusCode >= 400) {
      throw SanctumApiException(
        response.body,
        statusCode: response.statusCode,
      );
    }
    return response.bodyBytes;
  }

  dynamic _decode(http.Response response) {
    if (response.statusCode >= 400) {
      String message = response.body;
      try {
        final err = jsonDecode(response.body) as Map<String, dynamic>;
        message = err['error'] as String? ?? message;
      } catch (_) {}
      throw SanctumApiException(message, statusCode: response.statusCode);
    }
    if (response.body.isEmpty) return {};
    return jsonDecode(response.body);
  }

  Map<String, dynamic> _decodeObject(http.Response response) {
    final decoded = _decode(response);
    if (decoded is Map<String, dynamic>) return decoded;
    if (decoded is Map) return Map<String, dynamic>.from(decoded);
    return {'result': decoded};
  }

  void close() => _http.close();
}
