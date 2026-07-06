import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../api/sanctum_api_client.dart';
import '../config.dart';
import '../models/insight.dart';
import 'server_config_repository.dart';

class ReportService {
  ReportService({
    required ServerConfigRepository configRepo,
    SanctumApiClient Function(SanctumConfig)? clientFactory,
  })  : _configRepo = configRepo,
        _clientFactory = clientFactory ?? ((c) => SanctumApiClient(c));

  final ServerConfigRepository _configRepo;
  final SanctumApiClient Function(SanctumConfig) _clientFactory;

  SanctumApiClient? _client() {
    if (!_configRepo.hasConfiguredServer) return null;
    return _clientFactory(_configRepo.loadConfig());
  }

  Future<List<ReportOption>> getReportOptions() async {
    return const [
      ReportOption(
        id: 'weekly',
        title: 'Weekly summary',
        description: 'Personal weekly observation summary.',
        available: true,
      ),
      ReportOption(
        id: 'daily',
        title: 'Daily summary',
        description: 'Today-focused log summary.',
        available: true,
      ),
      ReportOption(
        id: 'physician',
        title: 'Physician handoff',
        description: 'Shareable summary for your clinician.',
        available: true,
      ),
      ReportOption(
        id: 'export',
        title: 'Export data bundle',
        description: 'Download JSON export from your Sanctum server.',
        available: true,
      ),
    ];
  }

  Future<List<GeneratedReport>> listReports() async {
    final client = _client();
    if (client == null || !await client.healthCheck()) return [];

    try {
      final list = await client.getList('/api/reports');
      return list.map((raw) {
        final map = raw as Map<String, dynamic>;
        return GeneratedReport(
          id: map['id'] as int? ?? 0,
          title: map['title'] as String? ?? 'Report',
          reportType: map['report_type'] as String? ?? '',
          generatedAt: map['generated_at'] as String? ?? '',
          preview: (map['content'] as String? ?? '').length > 120
              ? '${(map['content'] as String).substring(0, 120)}…'
              : map['content'] as String? ?? '',
        );
      }).toList();
    } catch (_) {
      return [];
    }
  }

  Future<ReportActionResult> generateReport(String reportType) async {
    final client = _client();
    if (client == null || !await client.healthCheck()) {
      return ReportActionResult(
        success: false,
        message: 'Sanctum server not reachable.',
      );
    }

    try {
      final body = await client.postJson('/api/generate-report', {
        'report_type': reportType,
      });
      return ReportActionResult(
        success: true,
        message: 'Report generated: ${body['title'] ?? reportType}',
        content: body['content'] as String?,
      );
    } on SanctumApiException catch (e) {
      return ReportActionResult(success: false, message: e.message);
    }
  }

  Future<ReportActionResult> exportAndShare() async {
    final client = _client();
    if (client == null || !await client.healthCheck()) {
      return ReportActionResult(
        success: false,
        message: 'Sanctum server not reachable.',
      );
    }

    try {
      final bytes = await client.downloadBytes('/api/export/bundle');
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/sanctum-export.json');
      await file.writeAsBytes(bytes);

      // Validate JSON for user feedback
      jsonDecode(await file.readAsString());

      await Share.shareXFiles(
        [XFile(file.path, mimeType: 'application/json', name: 'sanctum-export.json')],
        subject: 'Sanctum data export',
      );

      return ReportActionResult(
        success: true,
        message: 'Export ready to share.',
      );
    } on SanctumApiException catch (e) {
      return ReportActionResult(success: false, message: e.message);
    } catch (e) {
      return ReportActionResult(success: false, message: '$e');
    }
  }
}

class GeneratedReport {
  const GeneratedReport({
    required this.id,
    required this.title,
    required this.reportType,
    required this.generatedAt,
    required this.preview,
  });

  final int id;
  final String title;
  final String reportType;
  final String generatedAt;
  final String preview;
}

class ReportActionResult {
  const ReportActionResult({
    required this.success,
    required this.message,
    this.content,
  });

  final bool success;
  final String message;
  final String? content;
}
