import 'package:shared_preferences/shared_preferences.dart';

/// Local app flags — auth, onboarding, and lightweight prefs.
class AppPreferences {
  AppPreferences(this._prefs);

  final SharedPreferences _prefs;

  static const _keyAuthenticated = 'sanctum_authenticated';
  static const _keyOnboardingComplete = 'sanctum_onboarding_complete';
  static const _keyDisplayName = 'sanctum_display_name';
  static const _keyApiBase = 'sanctum_api_base';
  static const _keyIngestToken = 'sanctum_ingest_token';
  static const _keyServerReachable = 'sanctum_server_reachable';
  static const _keyServerCheckedAt = 'sanctum_server_checked_at';
  static const _keyOsState = 'sanctum_os_state_v1';

  bool get isAuthenticated => _prefs.getBool(_keyAuthenticated) ?? false;
  bool get isOnboardingComplete =>
      _prefs.getBool(_keyOnboardingComplete) ?? false;
  String? get displayName => _prefs.getString(_keyDisplayName);
  String? get apiBaseUrl => _prefs.getString(_keyApiBase);
  String? get ingestToken => _prefs.getString(_keyIngestToken);
  bool get lastServerReachable => _prefs.getBool(_keyServerReachable) ?? false;
  DateTime? get lastServerCheck {
    final raw = _prefs.getString(_keyServerCheckedAt);
    return raw != null ? DateTime.tryParse(raw) : null;
  }

  Future<void> setServerReachable(bool value) async {
    await _prefs.setBool(_keyServerReachable, value);
    await _prefs.setString(_keyServerCheckedAt, DateTime.now().toIso8601String());
  }

  Future<void> setApiBaseUrl(String url) =>
      _prefs.setString(_keyApiBase, url.replaceAll(RegExp(r'/+$'), ''));

  Future<void> setIngestToken(String token) =>
      _prefs.setString(_keyIngestToken, token.trim());

  Future<void> setAuthenticated(bool value) =>
      _prefs.setBool(_keyAuthenticated, value);

  Future<void> setOnboardingComplete(bool value) =>
      _prefs.setBool(_keyOnboardingComplete, value);

  Future<void> setDisplayName(String name) =>
      _prefs.setString(_keyDisplayName, name);

  String? get osStateJson => _prefs.getString(_keyOsState);

  Future<void> setOsStateJson(String? json) async {
    if (json == null) {
      await _prefs.remove(_keyOsState);
    } else {
      await _prefs.setString(_keyOsState, json);
    }
  }

  static Future<AppPreferences> load() async {
    final prefs = await SharedPreferences.getInstance();
    return AppPreferences(prefs);
  }
}
