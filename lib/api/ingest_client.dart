import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config.dart';
import 'ingest_models.dart';

class IngestException implements Exception {
  IngestException(this.message, {this.statusCode});
  final String message;
  final int? statusCode;

  @override
  String toString() => 'IngestException($statusCode): $message';
}

/// POST batches to Sanctum `/api/sync/ingest`.
///
/// API contract: https://github.com/cCuelho/Sanctum/blob/redesign/os/docs/MOBILE_INGEST.md
class IngestClient {
  IngestClient(this.config, {http.Client? httpClient})
      : _http = httpClient ?? http.Client();

  final SanctumConfig config;
  final http.Client _http;

  Future<IngestResult> postBatch(IngestBatch batch) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (config.ingestToken.isNotEmpty) {
      headers['X-Sanctum-Ingest-Token'] = config.ingestToken;
    }

    final response = await _http.post(
      Uri.parse(config.ingestUrl),
      headers: headers,
      body: jsonEncode(batch.toJson()),
    );

    Map<String, dynamic>? body;
    try {
      body = jsonDecode(response.body) as Map<String, dynamic>?;
    } catch (_) {
      body = null;
    }

    if (response.statusCode == 401) {
      throw IngestException(
        body?['error'] as String? ?? 'Unauthorized — check ingest token',
        statusCode: 401,
      );
    }

    if (response.statusCode >= 400) {
      throw IngestException(
        body?['error'] as String? ?? response.body,
        statusCode: response.statusCode,
      );
    }

    if (body == null) {
      throw IngestException('Invalid JSON response', statusCode: response.statusCode);
    }

    return IngestResult.fromJson(body);
  }

  void close() => _http.close();
}
