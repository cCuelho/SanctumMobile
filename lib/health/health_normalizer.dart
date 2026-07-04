import '../api/ingest_models.dart';

/// Maps platform health samples → Sanctum ingest records.
///
/// Expand as HealthBridge reads more types from the `health` package.
class HealthNormalizer {
  /// Daily step total for a calendar day.
  static IngestRecord steps({
    required String sourceProvider,
    required String day,
    required int steps,
    String? platformId,
  }) {
    final prefix = sourceProvider == 'health_connect' ? 'hc' : 'hk';
    return IngestRecord(
      sanctumType: 'activity',
      sourceRecordId: '$prefix:steps:$day',
      observedAt: '${day}T12:00:00',
      normalized: {'day': day, 'steps': steps},
      payload: {'metric': 'step_count', 'source_provider': sourceProvider},
    );
  }

  /// Sleep session with duration in seconds.
  static IngestRecord sleepSession({
    required String sourceProvider,
    required String day,
    required int durationSeconds,
    required String platformId,
    DateTime? start,
    DateTime? end,
  }) {
    final prefix = sourceProvider == 'health_connect' ? 'hc' : 'hk';
    return IngestRecord(
      sanctumType: 'sleep',
      sourceRecordId: '$prefix:sleep:$platformId',
      observedAt: '${day}T08:00:00',
      normalized: {
        'day': day,
        'duration_seconds': durationSeconds,
        if (start != null) 'start': start.toIso8601String(),
        if (end != null) 'end': end.toIso8601String(),
      },
      payload: {'source_provider': sourceProvider},
    );
  }
}
