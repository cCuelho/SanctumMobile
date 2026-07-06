import 'dart:io';

import 'package:health/health.dart';

import '../api/ingest_models.dart';
import '../config.dart';
import 'health_normalizer.dart';

/// Reads HealthKit (iOS) or Health Connect (Android) and builds ingest batches.
///
/// Requires platform folders from `flutter create` plus HealthKit / Health Connect
/// permissions in Info.plist and AndroidManifest.xml — see docs/SETUP.md.
class HealthBridge {
  HealthBridge(this.config) : _health = Health();

  final SanctumConfig config;
  final Health _health;

  static const _readTypes = [
    HealthDataType.STEPS,
    HealthDataType.SLEEP_ASLEEP,
    HealthDataType.SLEEP_IN_BED,
    HealthDataType.HEART_RATE,
    HealthDataType.WORKOUT,
  ];

  String get _sourceProvider {
    if (config.sourceProvider.isNotEmpty) {
      return config.sourceProvider;
    }
    return Platform.isIOS ? 'apple_health' : 'health_connect';
  }

  Future<bool> requestPermissions() async {
    await _health.configure();
    return _health.requestAuthorization(
      _readTypes,
      permissions: List.filled(_readTypes.length, HealthDataAccess.READ),
    );
  }

  /// Fetch last [days] days and normalize to ingest records.
  Future<List<IngestRecord>> fetchRecords({int days = 14}) async {
    final now = DateTime.now();
    final start = now.subtract(Duration(days: days));
    final points = await _health.getHealthDataFromTypes(
      types: _readTypes,
      startTime: start,
      endTime: now,
    );

    final records = <IngestRecord>[];
    final stepsByDay = <String, int>{};

    for (final point in points) {
      final day = _dayKey(point.dateFrom);
      switch (point.type) {
        case HealthDataType.STEPS:
          final steps = _numericValue(point.value);
          if (steps != null) {
            stepsByDay[day] = (stepsByDay[day] ?? 0) + steps.round();
          }
        case HealthDataType.SLEEP_ASLEEP:
        case HealthDataType.SLEEP_IN_BED:
          final seconds = point.dateTo.difference(point.dateFrom).inSeconds;
          if (seconds > 0) {
            records.add(
              HealthNormalizer.sleepSession(
                sourceProvider: _sourceProvider,
                day: day,
                durationSeconds: seconds,
                platformId: point.uuid,
                start: point.dateFrom,
                end: point.dateTo,
              ),
            );
          }
        default:
          break;
      }
    }

    for (final entry in stepsByDay.entries) {
      if (entry.value > 0) {
        records.add(
          HealthNormalizer.steps(
            sourceProvider: _sourceProvider,
            day: entry.key,
            steps: entry.value,
          ),
        );
      }
    }

    return records;
  }

  Future<IngestBatch> buildBatch({int days = 14, String? deviceId}) async {
    final records = await fetchRecords(days: days);
    return IngestBatch(
      sourceProvider: _sourceProvider,
      records: records,
      deviceId: deviceId,
      batchId: DateTime.now().toUtc().toIso8601String(),
    );
  }

  String _dayKey(DateTime dt) {
    final local = dt.toLocal();
    return '${local.year.toString().padLeft(4, '0')}-'
        '${local.month.toString().padLeft(2, '0')}-'
        '${local.day.toString().padLeft(2, '0')}';
  }

  double? _numericValue(HealthValue value) {
    if (value is NumericHealthValue) {
      return value.numericValue.toDouble();
    }
    return null;
  }
}
