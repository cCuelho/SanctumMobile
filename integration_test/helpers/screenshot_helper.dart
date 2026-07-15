import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'navigation_edge_logger.dart';

/// Captures simulator screenshots and records page metadata.
class NavigationScreenshotHelper {
  NavigationScreenshotHelper({
    required IntegrationTestWidgetsFlutterBinding binding,
    required WidgetTester tester,
    required NavigationEdgeLogger logger,
  })  : _binding = binding,
        _tester = tester,
        _logger = logger;

  final IntegrationTestWidgetsFlutterBinding _binding;
  final WidgetTester _tester;
  final NavigationEdgeLogger _logger;
  int _sequence = 0;

  Future<void> capture({
    required String pageId,
    required String title,
    required String reachedVia,
    String? route,
    String? viaAction,
    String? fromId,
    List<String> visibleHints = const [],
    Duration settle = const Duration(milliseconds: 800),
  }) async {
    await _tester.pumpAndSettle(settle);
    final screenshotFile = '${_sequence.toString().padLeft(3, '0')}_$pageId.png';
    _sequence++;

    try {
      if (Platform.isAndroid) {
        await _binding.convertFlutterSurfaceToImage();
      }
      // Name must not include .png — driver appends extension (args unsupported on iOS).
      final shotName = screenshotFile.replaceAll(RegExp(r'\.png$'), '');
      await _binding.takeScreenshot(shotName);
    } catch (e) {
      _logger.logFailure('screenshot:$pageId', e.toString());
    }

    _logger.visit(
      pageId: pageId,
      title: title,
      screenshotFile: screenshotFile,
      reachedVia: reachedVia,
      route: route,
      visibleHints: visibleHints,
      viaAction: viaAction,
      fromId: fromId,
    );
  }
}
