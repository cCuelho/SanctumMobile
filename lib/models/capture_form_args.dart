import 'capture.dart';
import 'os_capture_context.dart';

class CaptureFormArgs {
  const CaptureFormArgs({
    required this.category,
    this.captureContext,
  });

  final CaptureCategory category;
  final OsCaptureContext? captureContext;
}
