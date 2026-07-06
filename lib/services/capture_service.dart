import '../api/sanctum_api_client.dart';
import '../config.dart';
import '../models/capture.dart';
import '../models/capture_payload.dart';
import '../models/os_capture_context.dart';
import 'os_state_service.dart';
import 'server_config_repository.dart';

/// Focus-scoped capture — posts to Sanctum API with optional os_focus_id / os_protocol_id.
class CaptureService {
  CaptureService({
    required ServerConfigRepository configRepo,
    required OsStateService osState,
    SanctumApiClient Function(SanctumConfig)? clientFactory,
  })  : _configRepo = configRepo,
        _osState = osState,
        _clientFactory = clientFactory ?? ((c) => SanctumApiClient(c));

  final ServerConfigRepository _configRepo;
  final OsStateService _osState;
  final SanctumApiClient Function(SanctumConfig) _clientFactory;

  SanctumApiClient? _client() {
    if (!_configRepo.hasConfiguredServer) return null;
    return _clientFactory(_configRepo.loadConfig());
  }

  OsCaptureContext defaultCaptureContext({String? protocolId}) {
    return OsCaptureContext(
      focusId: _osState.activeFocus?.id,
      protocolId: protocolId,
    );
  }

  Future<CaptureResult> submitCapture({
    required CaptureCategory category,
    required CapturePayload payload,
    OsCaptureContext? captureContext,
  }) async {
    final client = _client();
    if (client == null) {
      return const CaptureResult(
        success: false,
        message: 'Configure your Sanctum server URL under Menu → Settings.',
        usedServer: false,
      );
    }

    final ctx = captureContext ?? defaultCaptureContext();

    try {
      final reachable = await client.healthCheck();
      if (!reachable) {
        return const CaptureResult(
          success: false,
          message: 'Cannot reach Sanctum server. Check URL and that Flask is running.',
          usedServer: false,
        );
      }

      await _postToApi(client, category, payload, ctx);
      return CaptureResult(
        success: true,
        message: '${category.label} saved to Sanctum.',
        usedServer: true,
      );
    } on SanctumApiException catch (e) {
      return CaptureResult(
        success: false,
        message: e.message,
        usedServer: true,
      );
    } catch (e) {
      return CaptureResult(
        success: false,
        message: '$e',
        usedServer: false,
      );
    }
  }

  Future<void> _postToApi(
    SanctumApiClient client,
    CaptureCategory category,
    CapturePayload p,
    OsCaptureContext ctx,
  ) async {
    final now = DateTime.now().toIso8601String().split('.').first;
    final osFields = ctx.toApiFields();

    switch (category) {
      case CaptureCategory.meal:
        await client.postJson('/api/meals', {
          'logged_at': now,
          'meal_name': p.mealName ?? p.summary,
          'meal_slot': p.mealSlot,
          'foods': p.foods ?? p.summary,
          'protein_estimate': p.proteinEstimate,
          'carbs_estimate': p.carbsEstimate,
          'notes': p.notes,
          ...osFields,
        });
      case CaptureCategory.supplement:
        await client.postJson('/api/supplements', {
          'logged_at': now,
          'name': p.supplementName ?? p.summary,
          'dose': p.dose,
          'notes': p.notes,
          ...osFields,
        });
      case CaptureCategory.exercise:
        await client.postJson('/api/exercises', {
          'logged_at': now,
          'exercise_type': p.exerciseType ?? p.summary,
          'duration': p.durationMinutes,
          'intensity': p.intensity,
          'notes': p.notes,
          ...osFields,
        });
      case CaptureCategory.symptom:
        await client.postJson('/api/daily-log', {
          'log_date': _today(),
          'joint_pain': p.painLevel,
          'notes': _jsonNotes(p.symptomLabel ?? p.summary, p.notes),
          ...osFields,
        });
        await client.postJson('/api/observations', {
          'observation_type': 'symptom',
          'value_text': p.symptomLabel ?? p.summary,
          'source': 'manual',
          'observed_at': now,
          ...osFields,
        });
      case CaptureCategory.vitals:
        await client.postJson('/api/daily-log', {
          'log_date': _today(),
          'weight': p.weight,
          'energy': p.energy,
          'notes': _jsonNotes(p.summary, p.notes),
          ...osFields,
        });
      case CaptureCategory.labResult:
        await client.postJson('/api/labs', {
          'lab_date': _today(),
          'lab_name': p.labName ?? p.summary,
          'result': p.labResult,
          'unit': p.labUnit,
          'notes': p.notes,
          ...osFields,
        });
      case CaptureCategory.note:
        await client.postJson('/api/reflections', {
          'logged_at': now,
          'entry': p.reflectionEntry ?? p.summary,
          'prompt': 'Mobile capture',
          ...osFields,
        });
      case CaptureCategory.photo:
        await client.postJson('/api/reflections', {
          'logged_at': now,
          'entry': '[Photo pending upload] ${p.summary}',
          'prompt': 'Mobile photo placeholder',
          ...osFields,
        });
    }
  }

  String _today() => DateTime.now().toIso8601String().split('T').first;

  String? _jsonNotes(String primary, String? extra) {
    if (extra == null || extra.isEmpty) return primary;
    return '$primary — $extra';
  }
}

class CaptureResult {
  const CaptureResult({
    required this.success,
    required this.message,
    required this.usedServer,
  });

  final bool success;
  final String message;
  final bool usedServer;
}
