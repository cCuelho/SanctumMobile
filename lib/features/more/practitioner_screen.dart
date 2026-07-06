import 'package:flutter/material.dart';

import '../../core/widgets/placeholder_banner.dart';

class PractitionerScreen extends StatelessWidget {
  const PractitionerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Practitioner mode')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          PlaceholderBanner(
            message:
                'A share-focused view for clinicians — export summaries you choose to share. Coming soon.',
          ),
          SizedBox(height: 16),
          Text(
            'Sanctum does not provide medical advice. Shared reports are user-reported observations for discussion with a qualified professional.',
            style: TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }
}
