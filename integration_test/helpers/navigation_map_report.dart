import 'navigation_models.dart';

/// Builds markdown and Mermaid artifacts from a navigation map session.
class NavigationMapReport {
  NavigationMapReport(this.session);

  final NavigationMapSession session;

  String toMarkdown() {
    final buf = StringBuffer()
      ..writeln('# Sanctum Mobile — Navigation Map')
      ..writeln()
      ..writeln('Generated: ${DateTime.now().toIso8601String()}')
      ..writeln('Pages: ${session.pages.length} · Edges: ${session.edges.length} · Failures: ${session.failures.length}')
      ..writeln()
      ..writeln('## Pages')
      ..writeln();

    for (final page in session.pages) {
      final shot = 'screenshots/${page.screenshotFile}';
      buf
        ..writeln('### ${page.title}')
        ..writeln()
        ..writeln('![${page.title}]($shot)')
        ..writeln()
        ..writeln('| Field | Value |')
        ..writeln('| --- | --- |')
        ..writeln('| **ID** | `${page.id}` |')
        ..writeln('| **Route** | `${page.route ?? '—'}` |')
        ..writeln('| **Screenshot** | `$shot` |')
        ..writeln('| **Reached via** | ${page.reachedVia} |');
      if (page.visibleHints.isNotEmpty) {
        buf.writeln('| **Visible hints** | ${page.visibleHints.join(', ')} |');
      }
      buf.writeln();
    }

    if (session.failures.isNotEmpty) {
      buf
        ..writeln('## Failures (continued run)')
        ..writeln();
      for (final f in session.failures) {
        buf.writeln('- **${f.step}**: ${f.message}${f.fromId != null ? ' (from `${f.fromId}`)' : ''}');
      }
      buf.writeln();
    }

    buf
      ..writeln('## Navigation edges')
      ..writeln()
      ..writeln('| From | Action | To | OK |')
      ..writeln('| --- | --- | --- | --- |');
    for (final edge in session.edges) {
      buf.writeln(
        '| `${edge.fromId}` | ${edge.action} | `${edge.toId}` | ${edge.success ? '✓' : '✗'} |',
      );
    }
    buf.writeln();

    return buf.toString();
  }

  String toMermaid() {
    final buf = StringBuffer()
      ..writeln('flowchart TD')
      ..writeln('  classDef page fill:#f4f2ee,stroke:#2e2a6e,color:#0f172a')
      ..writeln('  classDef fail stroke:#a8435f,stroke-dasharray:5 5');

    final nodeIds = <String>{};
    for (final page in session.pages) {
      final node = _mermaidId(page.id);
      nodeIds.add(node);
      final label = _escape(page.title);
      buf.writeln('  $node["$label"]:::page');
    }

    for (final edge in session.edges) {
      final from = _mermaidId(edge.fromId);
      final to = _mermaidId(edge.toId);
      final action = _escape(edge.action);
      if (edge.success) {
        buf.writeln('  $from -->|$action| $to');
      } else {
        buf.writeln('  $from -.->|$action| $to');
      }
    }

    return buf.toString();
  }

  static String _mermaidId(String raw) =>
      raw.replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '_');

  static String _escape(String raw) =>
      raw.replaceAll('"', "'").replaceAll('\n', ' ');
}
