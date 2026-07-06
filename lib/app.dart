import 'package:flutter/material.dart';

import 'core/app_lifecycle_sync.dart';
import 'core/routes.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/auth_screen.dart';
import 'features/capture/capture_form_screen.dart';
import 'features/more/data_management_screen.dart';
import 'features/more/device_bridge_screen.dart';
import 'features/more/devices_screen.dart';
import 'features/more/goals_screen.dart';
import 'features/more/library_screen.dart';
import 'features/more/more_screen.dart';
import 'features/more/practitioner_screen.dart';
import 'features/more/profile_screen.dart';
import 'features/more/reports_screen.dart';
import 'features/more/settings_screen.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/protocols/protocol_detail_screen.dart';
import 'features/protocols/protocols_screen.dart';
import 'features/shell/app_shell.dart';
import 'features/splash/splash_screen.dart';
import 'models/capture_form_args.dart';

class SanctumApp extends StatelessWidget {
  const SanctumApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AppLifecycleSync(
      child: MaterialApp(
        title: 'Sanctum Mobile',
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: ThemeMode.system,
        initialRoute: AppRoutes.splash,
        onGenerateRoute: _onGenerateRoute,
      ),
    );
  }

  Route<dynamic>? _onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return _page(const SplashScreen(), settings);
      case AppRoutes.auth:
        return _page(const AuthScreen(), settings);
      case AppRoutes.onboarding:
        return _page(const OnboardingScreen(), settings);
      case AppRoutes.shell:
        return _page(const AppShell(), settings);
      case AppRoutes.menu:
        return _page(const MoreScreen(), settings);
      case AppRoutes.protocols:
        return _page(const ProtocolsScreen(), settings);
      case AppRoutes.captureForm:
        final args = settings.arguments;
        if (args is CaptureFormArgs) {
          return _page(
            CaptureFormScreen(
              category: args.category,
              captureContext: args.captureContext,
            ),
            settings,
          );
        }
        return null;
      case AppRoutes.protocolDetail:
        final id = settings.arguments as String?;
        if (id == null) return null;
        return _page(ProtocolDetailScreen(protocolId: id), settings);
      case AppRoutes.devices:
        return _page(const DevicesScreen(), settings);
      case AppRoutes.deviceBridge:
        return _page(const DeviceBridgeScreen(), settings);
      case AppRoutes.reports:
        return _page(const ReportsScreen(), settings);
      case AppRoutes.profile:
        return _page(const ProfileScreen(), settings);
      case AppRoutes.goals:
        return _page(const GoalsScreen(), settings);
      case AppRoutes.dataManagement:
        return _page(const DataManagementScreen(), settings);
      case AppRoutes.settings:
        return _page(const SettingsScreen(), settings);
      case AppRoutes.practitioner:
        return _page(const PractitionerScreen(), settings);
      case AppRoutes.library:
        return _page(const LibraryScreen(), settings);
      default:
        return null;
    }
  }

  MaterialPageRoute<void> _page(Widget child, RouteSettings settings) {
    return MaterialPageRoute<void>(
      settings: settings,
      builder: (_) => child,
    );
  }
}
