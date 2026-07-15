import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../services/app_preferences.dart';
import '../services/auth_service.dart';
import '../services/os_state_service.dart';

/// Integration-test flags — enabled via `--dart-define=INTEGRATION_TEST=true`.
abstract final class IntegrationTestFlags {
  static const enabled = bool.fromEnvironment('INTEGRATION_TEST', defaultValue: false);
}

/// Seeds local state and bypasses network for guided navigation screenshots.
abstract final class IntegrationTestBootstrap {
  static const mockApiBase = String.fromEnvironment(
    'SANCTUM_API_BASE',
    defaultValue: 'http://127.0.0.1:5000',
  );

  static Future<void> install() async {
    if (!IntegrationTestFlags.enabled) return;
    AuthService.integrationTestMode = true;
    OsStateService.integrationTestMode = true;
  }

  static Future<void> seedFreshUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await prefs.setString(AppPreferences.keyApiBase, mockApiBase);
    await prefs.setString('sanctum_display_name', 'Navigation Mapper');
  }

  static Future<void> seedOnboardedUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('sanctum_authenticated', true);
    await prefs.setBool('sanctum_onboarding_complete', true);
    await prefs.setString('sanctum_display_name', 'Navigation Mapper');
    await prefs.setString(AppPreferences.keyApiBase, mockApiBase);
    await prefs.setString('sanctum_os_state_v1', jsonEncode(_mockOsState));
  }

  static Map<String, dynamic> get _mockOsState => {
        'onboarded': true,
        'appMode': 'input',
        'focuses': [
          {
            'id': 'nav-focus-sleep',
            'title': 'Sleep Optimization',
            'templateKey': 'sleep',
            'status': 'active',
            'isPrimary': true,
            'createdAt': '2026-01-01T00:00:00.000Z',
          },
        ],
        'protocols': [
          {
            'id': 'nav-protocol-mag',
            'focusId': 'nav-focus-sleep',
            'title': 'Magnesium Sleep Routine',
            'templateKey': 'magnesium_sleep',
            'status': 'active',
            'startedAt': '2026-01-01T00:00:00.000Z',
            'notes': '',
            'components': [],
          },
        ],
        'activeFocusId': 'nav-focus-sleep',
      };
}
