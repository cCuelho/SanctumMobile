import 'package:flutter/material.dart';

import '../../config.dart';
import '../../services/app_services.dart';

/// Preserved device bridge — reads HealthKit / Health Connect and syncs to Sanctum.
class DeviceBridgeScreen extends StatefulWidget {
  const DeviceBridgeScreen({super.key});

  @override
  State<DeviceBridgeScreen> createState() => _DeviceBridgeScreenState();
}

class _DeviceBridgeScreenState extends State<DeviceBridgeScreen> {
  late final TextEditingController _apiBaseController;
  late final TextEditingController _tokenController;
  bool _busy = false;
  String _status = 'Connect Sanctum, grant health access, then sync.';

  @override
  void initState() {
    super.initState();
    _apiBaseController = TextEditingController(
      text: SanctumConfig.fromEnvironment().apiBaseUrl,
    );
    _tokenController = TextEditingController();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final saved = await AppServices.instance.deviceSync.loadSavedConfig();
    _apiBaseController.text = saved.apiBase;
    _tokenController.text = saved.token;
    if (mounted) setState(() {});
  }

  Future<void> _sync() async {
    setState(() {
      _busy = true;
      _status = 'Requesting health permissions…';
    });

    final apiBase = _apiBaseController.text.trim();
    final token = _tokenController.text.trim();
    await AppServices.instance.deviceSync.saveConfig(
      apiBaseUrl: apiBase,
      ingestToken: token,
    );

    final result = await AppServices.instance.deviceSync.syncToServer(
      apiBaseUrl: apiBase,
      ingestToken: token,
    );

    if (mounted) {
      setState(() {
        _status = result;
        _busy = false;
      });
    }
  }

  @override
  void dispose() {
    _apiBaseController.dispose();
    _tokenController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Device bridge')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Health sync',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Reads Apple Health or Health Connect and pushes to your Sanctum server.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _apiBaseController,
              decoration: const InputDecoration(
                labelText: 'Sanctum API base URL',
                hintText: 'http://127.0.0.1:5000',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _tokenController,
              decoration: const InputDecoration(
                labelText: 'Ingest token (optional locally)',
              ),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: _busy ? null : _sync,
              icon: _busy
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.sync),
              label: Text(_busy ? 'Syncing…' : 'Sync to Sanctum'),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  _status,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
