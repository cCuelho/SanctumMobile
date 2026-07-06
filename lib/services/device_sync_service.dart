import 'package:shared_preferences/shared_preferences.dart';

import '../api/ingest_client.dart';
import '../config.dart';
import '../health/health_bridge.dart';
import '../models/device_status.dart';
import 'server_config_repository.dart';

/// Device bridge + local sync state. Wraps existing HealthKit ingest flow.
class DeviceSyncService {
  DeviceSyncService({
    required ServerConfigRepository configRepo,
    SharedPreferences? prefs,
  })  : _configRepo = configRepo,
        _prefsFuture = prefs != null
            ? Future.value(prefs)
            : SharedPreferences.getInstance();

  final ServerConfigRepository _configRepo;
  final Future<SharedPreferences> _prefsFuture;

  static const _keyLastSync = 'sanctum_last_sync_at';
  static const _keyLastSyncMessage = 'sanctum_last_sync_message';
  static const _keyDeviceConnected = 'sanctum_device_connected';
  static const _keyAutoSyncEnabled = 'sanctum_auto_sync_on_resume';

  SanctumConfig get config => _configRepo.loadConfig();

  bool get autoSyncOnResume => _cachedAutoSync ?? true;
  bool? _cachedAutoSync;

  Future<DeviceStatus> getStatus() async {
    final prefs = await _prefsFuture;
    final lastSyncRaw = prefs.getString(_keyLastSync);
    final lastSyncAt =
        lastSyncRaw != null ? DateTime.tryParse(lastSyncRaw) : null;
    final lastMessage = prefs.getString(_keyLastSyncMessage);
    final connected = prefs.getBool(_keyDeviceConnected) ?? false;

    final state = connected
        ? DeviceConnectionState.connected
        : DeviceConnectionState.notConnected;

    return DeviceStatus(
      connectionState: state,
      lastSyncAt: lastSyncAt,
      lastSyncMessage: lastMessage,
    );
  }

  Future<void> setAutoSyncOnResume(bool enabled) async {
    final prefs = await _prefsFuture;
    _cachedAutoSync = enabled;
    await prefs.setBool(_keyAutoSyncEnabled, enabled);
  }

  Future<bool> loadAutoSyncOnResume() async {
    final prefs = await _prefsFuture;
    _cachedAutoSync = prefs.getBool(_keyAutoSyncEnabled) ?? true;
    return _cachedAutoSync!;
  }

  /// Sync on app resume if last sync was more than [minHoursSinceLastSync] ago.
  Future<String?> syncOnResumeIfStale({int minHoursSinceLastSync = 24}) async {
    if (!await loadAutoSyncOnResume()) return null;
    final status = await getStatus();
    if (status.lastSyncAt == null) return null;
    final hours = DateTime.now().difference(status.lastSyncAt!).inHours;
    if (hours < minHoursSinceLastSync) return null;

    final saved = _configRepo.loadConfig();
    return syncToServer(
      apiBaseUrl: saved.apiBaseUrl,
      ingestToken: saved.ingestToken,
    );
  }

  Future<void> markConnected() async {
    final prefs = await _prefsFuture;
    await prefs.setBool(_keyDeviceConnected, true);
  }

  Future<String> syncToServer({
    required String apiBaseUrl,
    required String ingestToken,
    int days = 14,
  }) async {
    final syncConfig = SanctumConfig(
      apiBaseUrl: apiBaseUrl.replaceAll(RegExp(r'/+$'), ''),
      ingestToken: ingestToken,
      sourceProvider: _configRepo.loadConfig().sourceProvider,
    );

    await _configRepo.save(apiBaseUrl: apiBaseUrl, ingestToken: ingestToken);

    final bridge = HealthBridge(syncConfig);
    final client = IngestClient(syncConfig);

    try {
      final granted = await bridge.requestPermissions();
      if (!granted) {
        await _saveSyncResult(
          success: false,
          message:
              'Health permissions denied. On iPhone: Settings → Health → Data Access → Sanctum Mobile → enable Steps and Sleep. Then delete and reinstall the app if no prompt appeared (HealthKit was missing from the build).',
        );
        return 'Health permissions denied. Enable access in Settings → Health → Data Access → Sanctum Mobile, then try again.';
      }

      final batch = await bridge.buildBatch(days: days);
      if (batch.records.isEmpty) {
        await _saveSyncResult(
          success: false,
          message: 'No health records found for the last $days days.',
        );
        return 'No health records found for the last $days days.';
      }

      final result = await client.postBatch(batch);
      await markConnected();
      await _saveSyncResult(success: true, message: result.message);
      return '${result.message} (${result.status}, run #${result.syncRunId})';
    } on IngestException catch (e) {
      await _saveSyncResult(success: false, message: e.message);
      return 'Sync failed: ${e.message}';
    } catch (e) {
      await _saveSyncResult(success: false, message: '$e');
      return 'Error: $e';
    } finally {
      client.close();
    }
  }

  Future<void> _saveSyncResult({
    required bool success,
    required String message,
  }) async {
    final prefs = await _prefsFuture;
    if (success) {
      await prefs.setString(_keyLastSync, DateTime.now().toIso8601String());
      await prefs.setBool(_keyDeviceConnected, true);
    }
    await prefs.setString(_keyLastSyncMessage, message);
  }

  Future<({String apiBase, String token})> loadSavedConfig() async {
    final c = _configRepo.loadConfig();
    return (apiBase: c.apiBaseUrl, token: c.ingestToken);
  }

  Future<void> saveConfig({
    required String apiBaseUrl,
    required String ingestToken,
  }) async {
    await _configRepo.save(apiBaseUrl: apiBaseUrl, ingestToken: ingestToken);
  }
}
