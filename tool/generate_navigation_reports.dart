import 'dart:convert';
import 'dart:io';

/// Writes navigation_map.md and navigation_flow.mmd from session.json.
///
/// Usage: dart tool/generate_navigation_reports.dart test_outputs/navigation_map/session.json
void main(List<String> args) {
  if (args.isEmpty) {
    stderr.writeln('Usage: dart tool/generate_navigation_reports.dart <session.json>');
    exit(1);
  }
  final file = File(args.first);
  if (!file.existsSync()) {
    stderr.writeln('File not found: ${file.path}');
    exit(1);
  }
  final raw = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
  final dir = file.parent;

  // Re-import report logic inline for CLI use
  final md = _markdownFromSession(raw);
  final mmd = _mermaidFromSession(raw);

  File('${dir.path}/navigation_map.md').writeAsStringSync(md);
  File('${dir.path}/navigation_flow.mmd').writeAsStringSync(mmd);
  stdout.writeln('Wrote navigation_map.md and navigation_flow.mmd');
}

String _markdownFromSession(Map<String, dynamic> session) {
  final pages = (session['pages'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>();
  final edges = (session['edges'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>();
  final failures = (session['failures'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>();

  final buf = StringBuffer('''# Sanctum Mobile — Navigation Map

Pages: ${pages.length} · Edges: ${edges.length} · Failures: ${failures.length}

## Pages

''');

  for (final page in pages) {
    buf.writeln('### ${page['title']}');
    buf.writeln('| Field | Value |');
    buf.writeln('| --- | --- |');
    buf.writeln('| **ID** | `${page['id']}` |');
    buf.writeln('| **Route** | `${page['route'] ?? '—'}` |');
    buf.writeln('| **Screenshot** | `screenshots/${page['screenshotFile']}` |');
    buf.writeln('| **Reached via** | ${page['reachedVia']} |');
    buf.writeln();
  }
  return buf.toString();
}

String _mermaidFromSession(Map<String, dynamic> session) {
  final pages = (session['pages'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>();
  final edges = (session['edges'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>();
  final buf = StringBuffer('flowchart TD\n');
  for (final page in pages) {
    final id = '${page['id']}'.replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '_');
    buf.writeln('  $id["${page['title']}"]');
  }
  for (final edge in edges) {
    final from = '${edge['fromId']}'.replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '_');
    final to = '${edge['toId']}'.replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '_');
    buf.writeln('  $from -->|${edge['action']}| $to');
  }
  return buf.toString();
}
