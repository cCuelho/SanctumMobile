import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'navigation_edge_logger.dart';

/// Resilient taps and scrolls for guided integration-test navigation.
class GuidedNavigator {
  GuidedNavigator({
    required this.tester,
    required this.logger,
  });

  final WidgetTester tester;
  final NavigationEdgeLogger logger;

  Future<bool> tapText(
    String label, {
    required String step,
    bool warnIfMissing = true,
    int index = 0,
  }) async {
    final finder = find.text(label);
    if (finder.evaluate().isEmpty) {
      if (warnIfMissing) logger.logFailure(step, 'Text not found: "$label"');
      return false;
    }
    await tester.tap(finder.at(index));
    await tester.pumpAndSettle(const Duration(milliseconds: 600));
    return true;
  }

  Future<bool> tapIcon(
    IconData icon, {
    required String step,
  }) async {
    final finder = find.byIcon(icon);
    if (finder.evaluate().isEmpty) {
      logger.logFailure(step, 'Icon not found: $icon');
      return false;
    }
    await tester.tap(finder.first);
    await tester.pumpAndSettle(const Duration(milliseconds: 600));
    return true;
  }

  Future<bool> tapSemantics(
    String label, {
    required String step,
  }) async {
    final finder = find.bySemanticsLabel(label);
    if (finder.evaluate().isEmpty) {
      logger.logFailure(step, 'Semantics label not found: "$label"');
      return false;
    }
    await tester.tap(finder.first);
    await tester.pumpAndSettle(const Duration(milliseconds: 600));
    return true;
  }

  Future<bool> tapNavigationDestination(
    String label, {
    required String step,
  }) async {
    return tapText(label, step: step);
  }

  Future<bool> scrollUntilVisible(
    Finder finder, {
    required String step,
    double delta = -280,
  }) async {
    if (finder.evaluate().isNotEmpty) return true;
    for (var i = 0; i < 6; i++) {
      await tester.drag(find.byType(Scrollable).first, Offset(0, delta));
      await tester.pumpAndSettle(const Duration(milliseconds: 300));
      if (finder.evaluate().isNotEmpty) return true;
    }
    logger.logFailure(step, 'Could not scroll target into view: $finder');
    return false;
  }

  Future<bool> maybePop({required String step}) async {
    final back = find.byTooltip('Back');
    if (back.evaluate().isNotEmpty) {
      await tester.tap(back.first);
      await tester.pumpAndSettle(const Duration(milliseconds: 500));
      return true;
    }
    final arrowBack = find.byIcon(Icons.arrow_back);
    if (arrowBack.evaluate().isNotEmpty) {
      await tester.tap(arrowBack.first);
      await tester.pumpAndSettle(const Duration(milliseconds: 500));
      return true;
    }
    logger.logFailure(step, 'No back navigation available');
    return false;
  }
}
