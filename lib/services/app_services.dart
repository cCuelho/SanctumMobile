import 'package:flutter/foundation.dart';

import 'app_preferences.dart';
import 'auth_service.dart';
import 'capture_service.dart';
import 'device_sync_service.dart';
import 'insight_service.dart';
import 'os_state_service.dart';
import 'report_service.dart';
import 'server_config_repository.dart';

/// Root service locator — simple DI without third-party packages.
class AppServices {
  AppServices._({
    required this.configRepo,
    required this.auth,
    required this.osState,
    required this.deviceSync,
    required this.capture,
    required this.insights,
    required this.reports,
  });

  final ServerConfigRepository configRepo;
  final AuthService auth;
  final OsStateService osState;
  final DeviceSyncService deviceSync;
  final CaptureService capture;
  final InsightService insights;
  final ReportService reports;

  static AppServices? _instance;

  static AppServices get instance {
    final i = _instance;
    if (i == null) {
      throw StateError('AppServices not initialized. Call AppServices.init() first.');
    }
    return i;
  }

  static Future<AppServices> init() async {
    if (_instance != null) return _instance!;
    final prefs = await AppPreferences.load();
    final configRepo = ServerConfigRepository(prefs);
    final osState = OsStateService(configRepo: configRepo, prefs: prefs);
    _instance = AppServices._(
      configRepo: configRepo,
      auth: AuthService(prefs, configRepo, osState: osState),
      osState: osState,
      deviceSync: DeviceSyncService(configRepo: configRepo),
      capture: CaptureService(configRepo: configRepo, osState: osState),
      insights: InsightService(configRepo: configRepo, osState: osState),
      reports: ReportService(configRepo: configRepo),
    );
    return _instance!;
  }

  @visibleForTesting
  static void resetForTesting() {
    _instance = null;
  }
}
