import 'navigation_models.dart';

/// Logs navigation transitions as directed edges for flowchart generation.
class NavigationEdgeLogger {
  NavigationEdgeLogger(this.session);

  final NavigationMapSession session;

  void visit({
    required String pageId,
    required String title,
    required String screenshotFile,
    required String reachedVia,
    String? route,
    List<String> visibleHints = const [],
    String? viaAction,
    String? fromId,
  }) {
    if (viaAction != null) {
      session.addEdge(
        toId: pageId,
        action: viaAction,
        fromId: fromId,
      );
    }
    session.addPage(
      NavigationPageRecord(
        id: pageId,
        title: title,
        screenshotFile: screenshotFile,
        route: route,
        reachedVia: reachedVia,
        visibleHints: visibleHints,
      ),
    );
  }

  void logFailure(String step, String message) {
    session.addFailure(step, message);
  }

  void logTransition({
    required String toId,
    required String action,
    bool success = true,
  }) {
    session.addEdge(toId: toId, action: action, success: success);
  }
}
