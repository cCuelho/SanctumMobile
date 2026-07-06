import '../config.dart';
import '../services/app_preferences.dart';

/// Loads persisted Sanctum server configuration for API clients.
class ServerConfigRepository {
  ServerConfigRepository(this._prefs);

  final AppPreferences _prefs;

  SanctumConfig loadConfig() {
    return SanctumConfig(
      apiBaseUrl: _prefs.apiBaseUrl ?? SanctumConfig.fromEnvironment().apiBaseUrl,
      ingestToken: _prefs.ingestToken ?? SanctumConfig.fromEnvironment().ingestToken,
      sourceProvider: SanctumConfig.fromEnvironment().sourceProvider,
    );
  }

  Future<void> save({
    required String apiBaseUrl,
    String ingestToken = '',
  }) async {
    await _prefs.setApiBaseUrl(apiBaseUrl.replaceAll(RegExp(r'/+$'), ''));
    await _prefs.setIngestToken(ingestToken);
  }

  bool get hasConfiguredServer {
    final base = _prefs.apiBaseUrl;
    return base != null && base.trim().isNotEmpty;
  }
}
