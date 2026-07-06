import 'package:flutter/material.dart';

import '../../core/routes.dart';
import '../../core/theme/app_theme.dart';
import '../../models/os_state.dart';
import '../../services/app_services.dart';
import '../input/input_home_screen.dart';
import '../insights/insights_screen.dart';
import 'add_focus_sheet.dart';
import 'focus_switcher_sheet.dart';
import 'os_header.dart';

/// Sanctum OS shell — INPUT | INSIGHTS | Menu (wireframe parity).
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => AppShellState();
}

class AppShellState extends State<AppShell> {
  int _tabIndex = 0;

  @override
  void initState() {
    super.initState();
    final mode = AppServices.instance.osState.appMode;
    _tabIndex = mode == AppMode.insights ? 1 : 0;
    AppServices.instance.osState.addListener(_onOsChanged);
  }

  @override
  void dispose() {
    AppServices.instance.osState.removeListener(_onOsChanged);
    super.dispose();
  }

  void _onOsChanged() {
    if (mounted) setState(() {});
  }

  void _selectTab(int index) {
    setState(() => _tabIndex = index);
    final mode = index == 1 ? AppMode.insights : AppMode.input;
    AppServices.instance.osState.setAppMode(mode);
  }

  void _openMenu() {
    Navigator.of(context).pushNamed(AppRoutes.menu);
  }

  void _openFocusSwitcher() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (_) => FocusSwitcherSheet(
        onAddFocus: () => AddFocusSheet.show(context),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: OsHeader(
        onMenuTap: _openMenu,
        onFocusTap: _openFocusSwitcher,
      ),
      body: IndexedStack(
        index: _tabIndex,
        children: const [
          InputHomeScreen(),
          InsightsScreen(),
        ],
      ),
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(
          color: context.sanctumPalette.headerBg,
          border: Border(top: BorderSide(color: context.sanctumPalette.border)),
        ),
        child: NavigationBar(
          selectedIndex: _tabIndex,
          onDestinationSelected: (index) {
            if (index == 2) {
              _openMenu();
              return;
            }
            _selectTab(index);
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.edit_outlined),
              selectedIcon: Icon(Icons.edit),
              label: 'Input',
            ),
            NavigationDestination(
              icon: Icon(Icons.auto_awesome_outlined),
              selectedIcon: Icon(Icons.auto_awesome),
              label: 'Insights',
            ),
            NavigationDestination(
              icon: Icon(Icons.menu),
              label: 'Menu',
            ),
          ],
        ),
      ),
    );
  }
}
