import 'package:flutter/material.dart';

import '../../core/routes.dart';
import '../../services/app_services.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final name = AppServices.instance.auth.displayName ?? 'Sanctum user';

    return Scaffold(
      appBar: AppBar(title: const Text('More')),
      body: ListView(
        children: [
          ListTile(
            leading: CircleAvatar(
              child: Text(name.isNotEmpty ? name[0].toUpperCase() : 'S'),
            ),
            title: Text(name),
            subtitle: const Text('Profile & account'),
            onTap: () => Navigator.of(context).pushNamed(AppRoutes.profile),
          ),
          const Divider(),
          const _MenuTile(
            icon: Icons.watch_outlined,
            title: 'Devices',
            subtitle: 'Health sync & device bridge',
            route: AppRoutes.devices,
          ),
          const _MenuTile(
            icon: Icons.flag_outlined,
            title: 'Goals',
            subtitle: 'What you are working toward',
            route: AppRoutes.goals,
          ),
          const _MenuTile(
            icon: Icons.summarize_outlined,
            title: 'Reports',
            subtitle: 'Summaries & export',
            route: AppRoutes.reports,
          ),
          const _MenuTile(
            icon: Icons.storage_outlined,
            title: 'Data management',
            subtitle: 'Export, delete, local storage',
            route: AppRoutes.dataManagement,
          ),
          const _MenuTile(
            icon: Icons.settings_outlined,
            title: 'Settings',
            subtitle: 'App preferences',
            route: AppRoutes.settings,
          ),
          const Divider(),
          const _MenuTile(
            icon: Icons.medical_services_outlined,
            title: 'Practitioner mode',
            subtitle: 'Share-focused view (coming soon)',
            route: AppRoutes.practitioner,
          ),
          const _MenuTile(
            icon: Icons.menu_book_outlined,
            title: 'Library',
            subtitle: 'Resources & references (coming soon)',
            route: AppRoutes.library,
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Sign out'),
            onTap: () async {
              await AppServices.instance.auth.signOut();
              if (context.mounted) {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  AppRoutes.auth,
                  (_) => false,
                );
              }
            },
          ),
        ],
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.route,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String route;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => Navigator.of(context).pushNamed(route),
    );
  }
}
