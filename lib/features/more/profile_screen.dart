import 'package:flutter/material.dart';

import '../../core/widgets/placeholder_banner.dart';
import '../../services/app_services.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final name = AppServices.instance.auth.displayName ?? 'Not set';

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            title: const Text('Display name'),
            subtitle: Text(name),
          ),
          const SizedBox(height: 16),
          const PlaceholderBanner(
            message:
                'Full profile editing (age range, timezone, units) coming in a later phase.',
          ),
        ],
      ),
    );
  }
}
