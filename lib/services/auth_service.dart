import '../api/sanctum_api_client.dart';
import '../config.dart';
import '../services/app_preferences.dart';
import 'os_state_service.dart';
import 'server_config_repository.dart';

/// Local session + Sanctum server connectivity (no account API on MVP backend).
class AuthService {
  AuthService(
    this._prefs,
    this._configRepo, {
    required OsStateService osState,
  }) : _osState = osState;

  /// When true, server health checks succeed without network (integration tests).
  static bool integrationTestMode = false;

  final AppPreferences _prefs;
  final ServerConfigRepository _configRepo;
  final OsStateService _osState;

  bool get isAuthenticated => _prefs.isAuthenticated;
  bool get isOnboardingComplete => _osState.onboarded;
  String? get displayName => _prefs.displayName;
  bool get lastServerReachable => _prefs.lastServerReachable;
  String? get apiBaseUrl => _prefs.apiBaseUrl;

  SanctumConfig get config => _configRepo.loadConfig();

  Future<AuthDestination> resolveDestination() async {
    if (!isAuthenticated) return AuthDestination.auth;
    if (!_osState.hydrated) {
      await _osState.hydrate();
    }
    if (!_osState.onboarded) return AuthDestination.onboarding;
    return AuthDestination.shell;
  }

  Future<ServerCheckResult> checkServer({String? apiBaseUrl}) async {
    if (integrationTestMode) {
      final base = (apiBaseUrl ?? _prefs.apiBaseUrl ?? config.apiBaseUrl)
          .trim()
          .replaceAll(RegExp(r'/+$'), '');
      if (base.isNotEmpty) {
        await _configRepo.save(
          apiBaseUrl: base,
          ingestToken: _prefs.ingestToken ?? '',
        );
      }
      await _prefs.setServerReachable(true);
      return ServerCheckResult(
        ok: true,
        message: 'Integration test — server check bypassed.',
      );
    }

    final base = (apiBaseUrl ?? _prefs.apiBaseUrl ?? config.apiBaseUrl)
        .trim()
        .replaceAll(RegExp(r'/+$'), '');
    if (base.isEmpty) {
      return ServerCheckResult(ok: false, message: 'Enter a Sanctum API base URL.');
    }

    final client = SanctumApiClient(
      SanctumConfig(apiBaseUrl: base, ingestToken: _prefs.ingestToken ?? ''),
    );
    try {
      final ok = await client.healthCheck();
      await _prefs.setServerReachable(ok);
      if (ok) {
        await _configRepo.save(
          apiBaseUrl: base,
          ingestToken: _prefs.ingestToken ?? '',
        );
      }
      return ServerCheckResult(
        ok: ok,
        message: ok
            ? 'Connected to Sanctum at $base'
            : 'Could not reach $base — is Flask running?',
      );
    } finally {
      client.close();
    }
  }

  Future<void> signIn({
    String? displayName,
    required String apiBaseUrl,
    String ingestToken = '',
  }) async {
    await _configRepo.save(apiBaseUrl: apiBaseUrl, ingestToken: ingestToken);
    await _prefs.setAuthenticated(true);
    if (displayName != null && displayName.trim().isNotEmpty) {
      await _prefs.setDisplayName(displayName.trim());
    }
    await checkServer(apiBaseUrl: apiBaseUrl);
    await _osState.hydrate();
  }

  Future<void> signOut() async {
    await _prefs.setAuthenticated(false);
    await _osState.clearLocal();
  }
}

enum AuthDestination { auth, onboarding, shell }

class ServerCheckResult {
  const ServerCheckResult({required this.ok, required this.message});

  final bool ok;
  final String message;
}
