import 'package:flutter/material.dart';

import '../../services/app_services.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final TextEditingController _apiController;
  late final TextEditingController _tokenController;
  bool _autoSync = true;
  bool _busy = false;
  String? _status;

  @override
  void initState() {
    super.initState();
    final config = AppServices.instance.configRepo.loadConfig();
    _apiController = TextEditingController(text: config.apiBaseUrl);
    _tokenController = TextEditingController(text: config.ingestToken);
    _loadAutoSync();
  }

  Future<void> _loadAutoSync() async {
    final enabled = await AppServices.instance.deviceSync.loadAutoSyncOnResume();
    setState(() => _autoSync = enabled);
  }

  Future<void> _save() async {
    setState(() {
      _busy = true;
      _status = null;
    });
    await AppServices.instance.configRepo.save(
      apiBaseUrl: _apiController.text.trim(),
      ingestToken: _tokenController.text.trim(),
    );
    await AppServices.instance.deviceSync.setAutoSyncOnResume(_autoSync);
    final check = await AppServices.instance.auth.checkServer(
      apiBaseUrl: _apiController.text.trim(),
    );
    if (mounted) {
      setState(() {
        _busy = false;
        _status = check.message;
      });
    }
  }

  @override
  void dispose() {
    _apiController.dispose();
    _tokenController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = AppServices.instance.auth;
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Server', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          TextField(
            controller: _apiController,
            decoration: const InputDecoration(labelText: 'Sanctum API base URL'),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _tokenController,
            decoration: const InputDecoration(labelText: 'Ingest token (optional)'),
            obscureText: true,
          ),
          const SizedBox(height: 8),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Server status'),
            subtitle: Text(
              auth.lastServerReachable ? 'Last check: reachable' : 'Last check: unreachable',
            ),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Auto-sync devices on app open'),
            subtitle: const Text('Sync health data if last sync was over 24h ago'),
            value: _autoSync,
            onChanged: (v) => setState(() => _autoSync = v),
          ),
          FilledButton(
            onPressed: _busy ? null : _save,
            child: _busy
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save & test connection'),
          ),
          if (_status != null) ...[
            const SizedBox(height: 8),
            Text(_status!, style: Theme.of(context).textTheme.bodySmall),
          ],
          const Divider(height: 32),
          const ListTile(
            title: Text('About'),
            subtitle: Text('Sanctum Mobile — capture-first wellness journal'),
          ),
        ],
      ),
    );
  }
}
