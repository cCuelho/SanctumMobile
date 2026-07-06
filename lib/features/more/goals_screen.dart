import 'package:flutter/material.dart';

import '../../core/widgets/placeholder_banner.dart';

class GoalsScreen extends StatelessWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Goals')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          PlaceholderBanner(
            message:
                'Define wellness goals to frame protocols. Goal setup coming soon.',
          ),
          SizedBox(height: 16),
          ListTile(
            leading: Icon(Icons.flag_outlined),
            title: Text('Example: Improve sleep consistency'),
            subtitle: Text('Placeholder — add your own goals later'),
          ),
          ListTile(
            leading: Icon(Icons.flag_outlined),
            title: Text('Example: Track supplement effects'),
            subtitle: Text('Placeholder — add your own goals later'),
          ),
        ],
      ),
    );
  }
}
