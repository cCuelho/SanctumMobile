import 'package:flutter/material.dart';

import '../../services/app_services.dart';

/// Triggers optional device sync when the app returns to foreground.
class AppLifecycleSync extends StatefulWidget {
  const AppLifecycleSync({super.key, required this.child});

  final Widget child;

  @override
  State<AppLifecycleSync> createState() => _AppLifecycleSyncState();
}

class _AppLifecycleSyncState extends State<AppLifecycleSync>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      AppServices.instance.deviceSync.syncOnResumeIfStale();
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
