import 'package:flutter/material.dart';

import '../../constants/focus_templates.dart';
import '../../core/routes.dart';
import '../../services/app_services.dart';
import '../more/device_bridge_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _step = 0;
  String? _selectedTemplateKey;
  String _bodyRegion = 'hip';
  final Set<String> _selectedProtocolKeys = {};
  bool _busy = false;

  static const _focusOptions = [
    ('rehab', 'Rehabilitation'),
    ('sleep', 'Sleep Optimization'),
    ('fat_loss', 'Fat Loss'),
    ('mental_wellness', 'Mental Wellness'),
    ('strength', 'Strength'),
    ('longevity', 'Longevity'),
    ('spiritual', 'Spiritual Practice'),
  ];

  List<ProtocolTemplate> get _protocolOptions {
    if (_selectedTemplateKey == null) return [];
    return getSuggestedProtocolsForFocus(_selectedTemplateKey);
  }

  Future<void> _finish({bool skipDevice = false}) async {
    if (_selectedTemplateKey == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Choose a Focus to continue.')),
      );
      return;
    }

    setState(() => _busy = true);
    final focusId = newFocusId();
    final focus = buildFocusFromTemplate(
      _selectedTemplateKey!,
      id: focusId,
      bodyRegion: _bodyRegion,
    ).copyWith(isPrimary: true);

    await AppServices.instance.osState.completeOnboarding(
      focusSelections: [focus],
      primaryFocusId: focusId,
      protocolTemplateKeys: _selectedProtocolKeys.toList(),
    );

    if (!mounted) return;
    setState(() => _busy = false);

    if (skipDevice) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.shell);
    } else {
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => const DeviceBridgeScreen(),
        ),
      );
      if (mounted) {
        Navigator.of(context).pushReplacementNamed(AppRoutes.shell);
      }
    }
  }

  void _next() {
    if (_step == 0) {
      setState(() => _step = 1);
      return;
    }
    if (_step == 1) {
      if (_selectedTemplateKey == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Select a Focus area.')),
        );
        return;
      }
      setState(() => _step = 2);
      return;
    }
    if (_step == 2) {
      setState(() => _step = 3);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sanctum setup'),
        actions: [
          if (_step > 0)
            TextButton(
              onPressed: _busy ? null : () => _finish(skipDevice: true),
              child: const Text('Skip'),
            ),
        ],
      ),
      body: _busy
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                if (_step == 0) ..._welcomeStep(),
                if (_step == 1) ..._focusStep(),
                if (_step == 2) ..._protocolStep(),
                if (_step == 3) ..._deviceStep(),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _step == 3 ? () => _finish(skipDevice: false) : _next,
                  child: Text(_step == 3 ? 'Connect device' : 'Next'),
                ),
                if (_step == 3) ...[
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => _finish(skipDevice: true),
                    child: const Text('Skip device sync'),
                  ),
                ],
              ],
            ),
    );
  }

  List<Widget> _welcomeStep() {
    return const [
      Icon(Icons.eco_outlined, size: 48),
      SizedBox(height: 16),
      Text(
        'Welcome to Sanctum',
        style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
      ),
      SizedBox(height: 12),
      Text(
        'Sanctum is a Focus-driven wellness journal — not a generic tracker. '
        'You pick what you are trying to improve, add Protocols, then log INPUT and review INSIGHTS.',
      ),
    ];
  }

  List<Widget> _focusStep() {
    return [
      const Text(
        'What are you trying to improve?',
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
      ),
      const SizedBox(height: 12),
      ..._focusOptions.map((opt) {
        final selected = _selectedTemplateKey == opt.$1;
        return Card(
          child: ListTile(
            title: Text(opt.$2),
            trailing: selected ? const Icon(Icons.check_circle) : null,
            onTap: () => setState(() => _selectedTemplateKey = opt.$1),
          ),
        );
      }),
      if (_selectedTemplateKey == 'rehab') ...[
        const SizedBox(height: 16),
        const Text('Body region'),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            for (final region in ['hip', 'knee', 'shoulder', 'spine_low'])
              ChoiceChip(
                label: Text(region.replaceAll('_', ' ')),
                selected: _bodyRegion == region,
                onSelected: (_) => setState(() => _bodyRegion = region),
              ),
          ],
        ),
      ],
    ];
  }

  List<Widget> _protocolStep() {
    final options = _protocolOptions;
    return [
      const Text(
        'Add protocols (optional)',
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
      ),
      const SizedBox(height: 8),
      const Text('Protocols are structured plans under your Focus.'),
      const SizedBox(height: 16),
      if (options.isEmpty)
        const Text('No suggested protocols for this Focus.')
      else
        ...options.map((tpl) {
          final selected = _selectedProtocolKeys.contains(tpl.key);
          return CheckboxListTile(
            value: selected,
            onChanged: (v) {
              setState(() {
                if (v == true) {
                  _selectedProtocolKeys.add(tpl.key);
                } else {
                  _selectedProtocolKeys.remove(tpl.key);
                }
              });
            },
            title: Text(tpl.title),
          );
        }),
    ];
  }

  List<Widget> _deviceStep() {
    return const [
      Icon(Icons.watch_outlined, size: 48),
      SizedBox(height: 16),
      Text(
        'Connect a device (optional)',
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
      ),
      SizedBox(height: 12),
      Text(
        'Import steps and sleep from Apple Health on this device. '
        'You can also set this up later under Menu → Devices.',
      ),
    ];
  }
}
