import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:sanctum_mobile/app.dart';
import 'package:sanctum_mobile/core/routes.dart';
import 'package:sanctum_mobile/integration_test/bootstrap.dart';
import 'package:sanctum_mobile/services/app_services.dart';
import 'package:sanctum_mobile/services/auth_service.dart';
import 'package:sanctum_mobile/services/os_state_service.dart';

import 'helpers/guided_navigator.dart';
import 'helpers/navigation_edge_logger.dart';
import 'helpers/navigation_map_report.dart';
import 'helpers/navigation_models.dart';
import 'helpers/screenshot_helper.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('guided navigation screenshot map', (tester) async {
    final session = NavigationMapSession(startedAt: DateTime.now());
    final logger = NavigationEdgeLogger(session);
    final nav = GuidedNavigator(tester: tester, logger: logger);
    final shots = NavigationScreenshotHelper(
      binding: binding,
      tester: tester,
      logger: logger,
    );

    await _launchApp(tester, fresh: true);

    // --- Splash → Auth ---
    await tester.pump(const Duration(milliseconds: 300));
    if (find.text('Sanctum').evaluate().isNotEmpty) {
      await shots.capture(
        pageId: 'splash',
        title: 'Splash',
        route: AppRoutes.splash,
        reachedVia: 'App launch',
        visibleHints: ['Sanctum', 'Track. Observe. Learn.'],
      );
      await tester.pumpAndSettle(const Duration(milliseconds: 1500));
    }

    await shots.capture(
      pageId: 'auth',
      title: 'Connect Sanctum',
      route: AppRoutes.auth,
      reachedVia: 'Splash timeout → unauthenticated',
      viaAction: 'auto-route',
      fromId: 'splash',
      visibleHints: ['Connect Sanctum', 'Continue'],
    );

    // --- Onboarding (new user path) ---
    await nav.tapText('New here — set up my journal', step: 'auth:new-user');
    logger.logTransition(toId: 'onboarding_welcome', action: 'Tap "New here — set up my journal"');

    await shots.capture(
      pageId: 'onboarding_welcome',
      title: 'Onboarding — Welcome',
      route: AppRoutes.onboarding,
      reachedVia: 'Auth → New user',
      viaAction: 'New here — set up my journal',
      fromId: 'auth',
      visibleHints: ['Welcome to Sanctum', 'Next'],
    );

    await nav.tapText('Next', step: 'onboarding:welcome-next');
    await shots.capture(
      pageId: 'onboarding_focus',
      title: 'Onboarding — Choose Focus',
      route: AppRoutes.onboarding,
      reachedVia: 'Onboarding welcome → Next',
      viaAction: 'Next',
      fromId: 'onboarding_welcome',
      visibleHints: ['Sleep Optimization', 'Rehabilitation'],
    );

    await nav.tapText('Sleep Optimization', step: 'onboarding:pick-focus');
    await nav.tapText('Next', step: 'onboarding:focus-next');
    await shots.capture(
      pageId: 'onboarding_protocols',
      title: 'Onboarding — Protocols',
      route: AppRoutes.onboarding,
      reachedVia: 'Focus step → Next',
      viaAction: 'Next',
      fromId: 'onboarding_focus',
    );

    await nav.tapText('Next', step: 'onboarding:protocols-next');
    await shots.capture(
      pageId: 'onboarding_device',
      title: 'Onboarding — Device',
      route: AppRoutes.onboarding,
      reachedVia: 'Protocols step → Next',
      viaAction: 'Next',
      fromId: 'onboarding_protocols',
      visibleHints: ['Connect a device', 'Skip device sync'],
    );

    await nav.tapText('Skip device sync', step: 'onboarding:skip-device');
    await tester.pumpAndSettle(const Duration(seconds: 1));

    await shots.capture(
      pageId: 'shell_input',
      title: 'INPUT (Home)',
      route: AppRoutes.shell,
      reachedVia: 'Onboarding skip device → shell',
      viaAction: 'Skip device sync',
      fromId: 'onboarding_device',
      visibleHints: ['Input', 'Insights', 'Menu'],
    );

    await _mapShellAndMenu(tester, nav, shots, logger);

    // --- Sign out → Auth ---
    await nav.tapNavigationDestination('Menu', step: 'nav:menu-for-signout');
    await nav.tapText('Sign out', step: 'menu:sign-out');
    await tester.pumpAndSettle(const Duration(seconds: 1));

    await shots.capture(
      pageId: 'auth_returning',
      title: 'Connect Sanctum (after sign out)',
      route: AppRoutes.auth,
      reachedVia: 'Menu → Sign out',
      viaAction: 'Sign out',
      fromId: 'menu',
    );

    // --- Returning user → shell ---
    await nav.tapText('Continue', step: 'auth:continue-returning');
    await tester.pumpAndSettle(const Duration(seconds: 1));

    if (find.text('Sanctum setup').evaluate().isNotEmpty) {
      await shots.capture(
        pageId: 'onboarding_resume',
        title: 'Onboarding (resumed)',
        route: AppRoutes.onboarding,
        reachedVia: 'Continue without prior onboarded state',
      );
      await nav.tapText('Skip', step: 'onboarding:skip-header');
      await nav.tapText('Sleep Optimization', step: 'onboarding:resume-focus');
      await nav.tapText('Next', step: 'onboarding:resume-next-1');
      await nav.tapText('Next', step: 'onboarding:resume-next-2');
      await nav.tapText('Skip device sync', step: 'onboarding:resume-skip');
      await tester.pumpAndSettle(const Duration(seconds: 1));
    }

    await shots.capture(
      pageId: 'shell_input_returning',
      title: 'INPUT (returning user)',
      route: AppRoutes.shell,
      reachedVia: 'Auth → Continue',
      viaAction: 'Continue',
      fromId: 'auth_returning',
    );

    await _mapShellAndMenu(tester, nav, shots, logger, idSuffix: '_r2');

    _emitSessionArtifacts(binding, session);
  });
}

Future<void> _launchApp(WidgetTester tester, {required bool fresh}) async {
  if (fresh) {
    await IntegrationTestBootstrap.seedFreshUser();
  } else {
    await IntegrationTestBootstrap.seedOnboardedUser();
  }
  AppServices.resetForTesting();
  AuthService.integrationTestMode = true;
  OsStateService.integrationTestMode = true;
  await AppServices.init();
  await tester.pumpWidget(const SanctumApp());
  await tester.pumpAndSettle();
}

Future<void> _mapShellAndMenu(
  WidgetTester tester,
  GuidedNavigator nav,
  NavigationScreenshotHelper shots,
  NavigationEdgeLogger logger, {
  String idSuffix = '',
}) async {
  // Insights tab
  await nav.tapNavigationDestination('Insights', step: 'tab:insights$idSuffix');
  await shots.capture(
    pageId: 'shell_insights$idSuffix',
    title: 'INSIGHTS',
    route: AppRoutes.shell,
    reachedVia: 'Bottom nav → Insights',
    viaAction: 'Insights tab',
    fromId: 'shell_input$idSuffix',
    visibleHints: ['What Sanctum learned'],
  );

  // Input tab
  await nav.tapNavigationDestination('Input', step: 'tab:input$idSuffix');
  await shots.capture(
    pageId: 'shell_input$idSuffix',
    title: 'INPUT',
    route: AppRoutes.shell,
    reachedVia: 'Bottom nav → Input',
    viaAction: 'Input tab',
    fromId: 'shell_insights$idSuffix',
  );

  // Focus switcher
  final focusTitle = find.textContaining('Sleep');
  if (focusTitle.evaluate().isNotEmpty) {
    await tester.tap(focusTitle.first);
    await tester.pumpAndSettle();
    await shots.capture(
      pageId: 'focus_switcher$idSuffix',
      title: 'Focus Switcher Sheet',
      reachedVia: 'Header focus title tap',
      viaAction: 'Tap focus title',
      fromId: 'shell_input$idSuffix',
      visibleHints: ['Switch Focus', 'Add Focus'],
    );
    await nav.maybePop(step: 'focus_switcher:close');
  }

  // Protocols list
  if (await nav.tapText('View all', step: 'input:view-protocols$idSuffix', warnIfMissing: false) ||
      await nav.tapText('Add a protocol', step: 'input:add-protocol$idSuffix', warnIfMissing: false)) {
    await shots.capture(
      pageId: 'protocols_list$idSuffix',
      title: 'Protocols',
      route: AppRoutes.protocols,
      reachedVia: 'INPUT → View all / Add protocol',
      fromId: 'shell_input$idSuffix',
    );
    await nav.maybePop(step: 'protocols:back$idSuffix');
  }

  // Capture form (Daily Check-In card)
  if (await nav.tapText('Daily Check-In', step: 'input:daily-check-in$idSuffix', warnIfMissing: false)) {
    await shots.capture(
      pageId: 'capture_vitals$idSuffix',
      title: 'Capture — Vitals / Check-in',
      route: AppRoutes.captureForm,
      reachedVia: 'INPUT card → Daily Check-In',
      fromId: 'shell_input$idSuffix',
    );
    await nav.maybePop(step: 'capture:back$idSuffix');
  }

  // Menu + sub-pages
  await nav.tapNavigationDestination('Menu', step: 'tab:menu$idSuffix');
  await shots.capture(
    pageId: 'menu$idSuffix',
    title: 'More / Menu',
    route: AppRoutes.menu,
    reachedVia: 'Bottom nav → Menu',
    viaAction: 'Menu tab',
    fromId: 'shell_input$idSuffix',
    visibleHints: ['Devices', 'Settings', 'Sign out'],
  );

  final menuRoutes = <String, String>{
    'Devices': AppRoutes.devices,
    'Goals': AppRoutes.goals,
    'Reports': AppRoutes.reports,
    'Data management': AppRoutes.dataManagement,
    'Settings': AppRoutes.settings,
    'Practitioner mode': AppRoutes.practitioner,
    'Library': AppRoutes.library,
  };

  if (await nav.tapText('Navigation Mapper', step: 'menu:profile$idSuffix', warnIfMissing: false)) {
    await shots.capture(
      pageId: 'menu_profile$idSuffix',
      title: 'Profile',
      route: AppRoutes.profile,
      reachedVia: 'Menu → profile tile',
      fromId: 'menu$idSuffix',
    );
    await nav.maybePop(step: 'profile:back$idSuffix');
    if (find.text('Sign out').evaluate().isEmpty) {
      await nav.tapNavigationDestination('Menu', step: 'tab:menu-reopen-profile$idSuffix');
    }
  }

  for (final entry in menuRoutes.entries) {
    final label = entry.key;
    final route = entry.value;
    final pageId = 'menu_${route.replaceAll(RegExp(r'[^a-z0-9]+'), '_')}$idSuffix';

    if (!await nav.tapText(label, step: 'menu:$label$idSuffix', warnIfMissing: false)) {
      continue;
    }

    await shots.capture(
      pageId: pageId,
      title: label,
      route: route,
      reachedVia: 'Menu → $label',
      viaAction: 'Tap $label',
      fromId: 'menu$idSuffix',
    );

    // Device bridge from Devices screen
    if (route == AppRoutes.devices) {
      if (await nav.tapText('Device bridge', step: 'devices:bridge$idSuffix', warnIfMissing: false)) {
        await shots.capture(
          pageId: 'device_bridge$idSuffix',
          title: 'Device Bridge / Wearable Sync',
          route: AppRoutes.deviceBridge,
          reachedVia: 'Devices → Device bridge',
          fromId: pageId,
        );
        await nav.maybePop(step: 'device_bridge:back$idSuffix');
      }
    }

    await nav.maybePop(step: 'subpage:back:$pageId');
    // Re-open menu if we popped to shell
    if (find.text('Sign out').evaluate().isEmpty) {
      await nav.tapNavigationDestination('Menu', step: 'tab:menu-reopen$idSuffix');
    }
  }
}

void _emitSessionArtifacts(
  IntegrationTestWidgetsFlutterBinding binding,
  NavigationMapSession session,
) {
  final report = NavigationMapReport(session);
  binding.reportData ??= <String, dynamic>{};
  binding.reportData!['navigation_map'] = <String, dynamic>{
    'session': session.toJson(),
    'markdown': report.toMarkdown(),
    'mermaid': report.toMermaid(),
  };
}
