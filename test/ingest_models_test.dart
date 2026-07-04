import 'package:flutter_test/flutter_test.dart';
import 'package:sanctum_mobile/api/ingest_models.dart';

void main() {
  test('IngestBatch serializes for Sanctum API', () {
    final batch = IngestBatch(
      sourceProvider: 'apple_health',
      records: [
        IngestRecord(
          sanctumType: 'activity',
          sourceRecordId: 'hk:steps:2026-07-03',
          observedAt: '2026-07-03T12:00:00',
          normalized: {'day': '2026-07-03', 'steps': 5000},
        ),
      ],
    );

    final json = batch.toJson();
    expect(json['source_provider'], 'apple_health');
    expect(json['records'], hasLength(1));
    expect(json['records'][0]['sanctum_type'], 'activity');
  });
}
