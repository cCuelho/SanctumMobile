import 'dart:io';

import 'package:flutter_driver/flutter_driver.dart';
import 'package:integration_test/integration_test_driver_extended.dart';

/// Host-side driver: saves simulator screenshots for the navigation map run.
Future<void> main() async {
  final outDir = Platform.environment['NAV_MAP_SCREENSHOT_DIR'] ??
      '${Directory.current.path}/test_outputs/navigation_map/screenshots';
  await Directory(outDir).create(recursive: true);

  final driver = await FlutterDriver.connect();
  await integrationDriver(
    driver: driver,
    onScreenshot:
        (String screenshotName, List<int> screenshotBytes, [Map<String, Object?>? args]) async {
      final filename = '$screenshotName.png';
      final file = File('$outDir/$filename');
      await file.writeAsBytes(screenshotBytes, flush: true);
      stderr.writeln('Saved screenshot: ${file.path} (${screenshotBytes.length} bytes)');
      return screenshotBytes.isNotEmpty;
    },
    writeResponseOnFailure: true,
  );
}
