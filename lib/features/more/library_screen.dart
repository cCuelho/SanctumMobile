import 'package:flutter/material.dart';

import '../../core/widgets/placeholder_banner.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Library')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          PlaceholderBanner(
            message:
                'Curated wellness resources and references coming soon.',
          ),
        ],
      ),
    );
  }
}
