/// Sanctum server URL and ingest settings.
///
/// Copy to `config.local.dart` and override for your environment, or use
/// `--dart-define=SANCTUM_API_BASE=...` at build time.
class SanctumConfig {
  SanctumConfig({
    required this.apiBaseUrl,
    this.ingestToken = '',
    this.sourceProvider = 'apple_health',
  });

  /// Base URL without trailing slash, e.g. https://sanctum.sanctumwellness.net
  final String apiBaseUrl;

  /// Optional — matches server MOBILE_INGEST_TOKEN (X-Sanctum-Ingest-Token).
  final String ingestToken;

  /// `apple_health` on iOS, `health_connect` on Android.
  final String sourceProvider;

  String get ingestUrl => '$apiBaseUrl/api/sync/ingest';

  static SanctumConfig fromEnvironment() {
    const base = String.fromEnvironment(
      'SANCTUM_API_BASE',
      defaultValue: 'http://127.0.0.1:5000',
    );
    const token = String.fromEnvironment('SANCTUM_INGEST_TOKEN', defaultValue: '');
    const provider = String.fromEnvironment(
      'SANCTUM_SOURCE_PROVIDER',
      defaultValue: 'apple_health',
    );
    return SanctumConfig(
      apiBaseUrl: base.replaceAll(RegExp(r'/+$'), ''),
      ingestToken: token,
      sourceProvider: provider,
    );
  }
}
