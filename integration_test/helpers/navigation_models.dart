/// A captured screen in the navigation map run.
class NavigationPageRecord {
  NavigationPageRecord({
    required this.id,
    required this.title,
    required this.screenshotFile,
    this.route,
    required this.reachedVia,
    this.visibleHints = const [],
  });

  final String id;
  final String title;
  final String screenshotFile;
  final String? route;
  final String reachedVia;
  final List<String> visibleHints;

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'screenshotFile': screenshotFile,
        'route': route,
        'reachedVia': reachedVia,
        'visibleHints': visibleHints,
      };
}

/// Directed navigation transition between two pages.
class NavigationEdge {
  NavigationEdge({
    required this.fromId,
    required this.toId,
    required this.action,
    this.success = true,
  });

  final String fromId;
  final String toId;
  final String action;
  final bool success;

  Map<String, dynamic> toJson() => {
        'fromId': fromId,
        'toId': toId,
        'action': action,
        'success': success,
      };
}

/// Failure log entry when a guided step cannot complete.
class NavigationFailure {
  NavigationFailure({
    required this.step,
    required this.message,
    this.fromId,
  });

  final String step;
  final String message;
  final String? fromId;

  Map<String, dynamic> toJson() => {
        'step': step,
        'message': message,
        'fromId': fromId,
      };
}

class NavigationMapSession {
  NavigationMapSession({required this.startedAt});

  final DateTime startedAt;
  final List<NavigationPageRecord> pages = [];
  final List<NavigationEdge> edges = [];
  final List<NavigationFailure> failures = [];

  String? _currentPageId;

  void setCurrentPage(String? id) => _currentPageId = id;

  void addPage(NavigationPageRecord page) {
    pages.add(page);
    _currentPageId = page.id;
  }

  void addEdge({
    required String toId,
    required String action,
    bool success = true,
    String? fromId,
  }) {
    edges.add(
      NavigationEdge(
        fromId: fromId ?? _currentPageId ?? 'start',
        toId: toId,
        action: action,
        success: success,
      ),
    );
    if (success) _currentPageId = toId;
  }

  void addFailure(String step, String message, {String? fromId}) {
    failures.add(
      NavigationFailure(step: step, message: message, fromId: fromId ?? _currentPageId),
    );
  }

  Map<String, dynamic> toJson() => {
        'startedAt': startedAt.toIso8601String(),
        'finishedAt': DateTime.now().toIso8601String(),
        'pageCount': pages.length,
        'edgeCount': edges.length,
        'failureCount': failures.length,
        'pages': pages.map((p) => p.toJson()).toList(),
        'edges': edges.map((e) => e.toJson()).toList(),
        'failures': failures.map((f) => f.toJson()).toList(),
      };
}
