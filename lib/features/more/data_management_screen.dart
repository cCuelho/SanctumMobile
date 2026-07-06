import 'package:flutter/material.dart';

import '../../core/widgets/placeholder_banner.dart';

class DataManagementScreen extends StatelessWidget {
  const DataManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Data management')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const PlaceholderBanner(
            message:
                'Your captures and protocols are stored on this device. Export and delete tools coming soon.',
          ),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.upload_outlined),
            title: const Text('Export data'),
            subtitle: const Text('Coming soon'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.delete_outline),
            title: const Text('Clear local data'),
            subtitle: const Text('Coming soon'),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
