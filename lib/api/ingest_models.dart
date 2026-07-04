class IngestRecord {
  IngestRecord({
    required this.sanctumType,
    required this.sourceRecordId,
    required this.observedAt,
    required this.normalized,
    this.payload,
  });

  final String sanctumType;
  final String sourceRecordId;
  final String observedAt;
  final Map<String, dynamic> normalized;
  final Map<String, dynamic>? payload;

  Map<String, dynamic> toJson() => {
        'sanctum_type': sanctumType,
        'source_record_id': sourceRecordId,
        'observed_at': observedAt,
        'normalized': normalized,
        if (payload != null) 'payload': payload,
      };
}

class IngestBatch {
  IngestBatch({
    required this.sourceProvider,
    required this.records,
    this.deviceId,
    this.batchId,
  });

  final String sourceProvider;
  final List<IngestRecord> records;
  final String? deviceId;
  final String? batchId;

  Map<String, dynamic> toJson() => {
        'source_provider': sourceProvider,
        'records': records.map((r) => r.toJson()).toList(),
        if (deviceId != null) 'device_id': deviceId,
        if (batchId != null) 'batch_id': batchId,
      };
}

class IngestResult {
  IngestResult({
    required this.status,
    required this.imported,
    required this.skipped,
    required this.message,
    this.syncRunId,
  });

  factory IngestResult.fromJson(Map<String, dynamic> json) => IngestResult(
        status: json['status'] as String? ?? 'unknown',
        imported: json['imported'] as int? ?? 0,
        skipped: json['skipped'] as int? ?? 0,
        message: json['message'] as String? ?? '',
        syncRunId: json['sync_run_id'] as int?,
      );

  final String status;
  final int imported;
  final int skipped;
  final String message;
  final int? syncRunId;
}
