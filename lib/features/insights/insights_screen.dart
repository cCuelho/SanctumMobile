import 'package:flutter/material.dart';

import '../../core/widgets/placeholder_banner.dart';
import '../../models/insight.dart';
import '../../services/app_services.dart';
import '../../services/insight_service.dart';

class InsightsScreen extends StatefulWidget {
  const InsightsScreen({super.key});

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  InsightSummary? _summary;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
    AppServices.instance.osState.addListener(_onOsChanged);
  }

  @override
  void dispose() {
    AppServices.instance.osState.removeListener(_onOsChanged);
    super.dispose();
  }

  void _onOsChanged() {
    if (mounted) _load();
  }

  Future<void> _load() async {
    final summary = await AppServices.instance.insights.getInsightSummary();
    if (mounted) {
      setState(() {
        _summary = summary;
        _loading = false;
      });
    }
  }

  IconData _iconFor(InsightKind kind) {
    return switch (kind) {
      InsightKind.trend => Icons.show_chart,
      InsightKind.pattern => Icons.hub_outlined,
      InsightKind.aiSummary => Icons.auto_awesome_outlined,
    };
  }

  @override
  Widget build(BuildContext context) {
    final summary = _summary;
    return _loading
        ? const Center(child: CircularProgressIndicator())
        : RefreshIndicator(
            onRefresh: _load,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  'What Sanctum learned',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                if (summary?.focusSubtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    summary!.focusSubtitle!,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
                const SizedBox(height: 8),
                Text(
                  'One observation at a time — for personal reflection, not diagnosis.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 16),
                if (summary != null && !summary.fromServer)
                  const PlaceholderBanner(
                    message:
                        'Connect to your Sanctum server to load observations from logged data.',
                  )
                else if (summary != null && summary.disclaimer != null)
                  PlaceholderBanner(message: summary.disclaimer!),
                const SizedBox(height: 16),
                ...(summary?.cards ?? []).map(
                  (card) => Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(_iconFor(card.kind)),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  card.title,
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                              ),
                              if (card.requiresMoreData)
                                const Chip(
                                  label: Text('Needs data'),
                                  visualDensity: VisualDensity.compact,
                                ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(card.body),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
  }
}
