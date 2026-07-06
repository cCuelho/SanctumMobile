import '../api/sanctum_api_client.dart';
import '../config.dart';
import '../models/insight.dart';
import 'os_state_service.dart';
import 'server_config_repository.dart';

class InsightService {
  InsightService({
    required ServerConfigRepository configRepo,
    required OsStateService osState,
    SanctumApiClient Function(SanctumConfig)? clientFactory,
  })  : _configRepo = configRepo,
        _osState = osState,
        _clientFactory = clientFactory ?? ((c) => SanctumApiClient(c));

  final ServerConfigRepository _configRepo;
  final OsStateService _osState;
  final SanctumApiClient Function(SanctumConfig) _clientFactory;

  SanctumApiClient? _client() {
    if (!_configRepo.hasConfiguredServer) return null;
    return _clientFactory(_configRepo.loadConfig());
  }

  String? get focusSubtitle {
    final focus = _osState.activeFocus;
    if (focus == null) return null;
    final count = _osState.protocolsForActiveFocus().length;
    if (count == 0) return 'Based on ${focus.title}';
    return 'Based on ${focus.title} and $count active protocol${count == 1 ? '' : 's'}';
  }

  Future<InsightSummary> getInsightSummary() async {
    final client = _client();
    if (client != null && await client.healthCheck()) {
      try {
        final payload = await client.getJson('/api/observations');
        final observations =
            payload['observations'] as List<dynamic>? ?? [];
        final dayCount = payload['day_count'] as int? ?? 0;
        final minDays = payload['min_days_for_patterns'] as int? ?? 7;
        final disclaimer = payload['disclaimer'] as String?;

        if (observations.isEmpty) {
          return InsightSummary(
            cards: _needsDataCards(dayCount: dayCount, minDays: minDays),
            dayCount: dayCount,
            minDaysForPatterns: minDays,
            disclaimer: disclaimer,
            focusSubtitle: focusSubtitle,
            fromServer: true,
          );
        }

        final cards = observations.map((raw) {
          final map = raw as Map<String, dynamic>;
          return InsightCard(
            id: '${map['id'] ?? map['title']}',
            title: map['title'] as String? ?? 'Observation',
            body: map['observation'] as String? ?? '',
            kind: InsightKind.pattern,
            requiresMoreData: false,
          );
        }).toList();

        return InsightSummary(
          cards: cards,
          dayCount: dayCount,
          minDaysForPatterns: minDays,
          disclaimer: disclaimer,
          focusSubtitle: focusSubtitle,
          fromServer: true,
        );
      } catch (_) {
        // fall through
      }
    }

    return InsightSummary(
      cards: _needsDataCards(dayCount: 0, minDays: 7),
      dayCount: 0,
      minDaysForPatterns: 7,
      focusSubtitle: focusSubtitle,
      fromServer: false,
    );
  }

  List<InsightCard> _needsDataCards({required int dayCount, required int minDays}) {
    return [
      InsightCard(
        id: 'data-needed',
        title: 'Keep logging',
        body: dayCount > 0
            ? 'You have $dayCount days logged. Patterns typically appear after $minDays+ days of consistent captures.'
            : 'Insights require sufficient logged data. Capture meals, sleep notes, and daily check-ins to compare trends.',
        kind: InsightKind.trend,
        requiresMoreData: true,
      ),
    ];
  }
}

class InsightSummary {
  const InsightSummary({
    required this.cards,
    required this.dayCount,
    required this.minDaysForPatterns,
    this.disclaimer,
    this.focusSubtitle,
    required this.fromServer,
  });

  final List<InsightCard> cards;
  final int dayCount;
  final int minDaysForPatterns;
  final String? disclaimer;
  final String? focusSubtitle;
  final bool fromServer;
}
