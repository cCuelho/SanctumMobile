enum InsightKind { trend, pattern, aiSummary }

class InsightCard {
  const InsightCard({
    required this.id,
    required this.title,
    required this.body,
    required this.kind,
    this.requiresMoreData = true,
  });

  final String id;
  final String title;
  final String body;
  final InsightKind kind;
  final bool requiresMoreData;
}

class ReportOption {
  const ReportOption({
    required this.id,
    required this.title,
    required this.description,
    this.available = false,
  });

  final String id;
  final String title;
  final String description;
  final bool available;
}
