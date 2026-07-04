import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'api/ingest_client.dart';
import 'config.dart';
import 'health/health_bridge.dart';

void main() {
  runApp(const SanctumMobileApp());
}

class SanctumMobileApp extends StatelessWidget {
  const SanctumMobileApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sanctum Mobile',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF065F46)),
        useMaterial3: true,
      ),
      home: const SyncHomePage(),
    );
  }
}

class SyncHomePage extends StatefulWidget {
  const SyncHomePage({super.key});

  @override
  State<SyncHomePage> createState() => _SyncHomePageState();
}

class _SyncHomePageState extends State<SyncHomePage> {
  late SanctumConfig _config;
  final _apiBaseController = TextEditingController(
    text: SanctumConfig.fromEnvironment().apiBaseUrl,
  );
  final _tokenController = TextEditingController();
  bool _busy = false;
  String _status = 'Connect Sanctum, grant health access, then sync.';

  @override
  void initState() {
    super.initState();
    _config = SanctumConfig.fromEnvironment();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final base = prefs.getString('sanctum_api_base');
    final token = prefs.getString('sanctum_ingest_token');
    if (base != null) _apiBaseController.text = base;
    if (token != null) _tokenController.text = token;
    _applyConfig();
  }

  void _applyConfig() {
    setState(() {
      _config = SanctumConfig(
        apiBaseUrl: _apiBaseController.text.trim().replaceAll(RegExp(r'/+$'), ''),
        ingestToken: _tokenController.text.trim(),
        sourceProvider: SanctumConfig.fromEnvironment().sourceProvider,
      );
    });
  }

  Future<void> _savePrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('sanctum_api_base', _apiBaseController.text.trim());
    await prefs.setString('sanctum_ingest_token', _tokenController.text.trim());
  }

  Future<void> _sync() async {
    setState(() {
      _busy = true;
      _status = 'Requesting health permissions…';
    });

    _applyConfig();
    await _savePrefs();

    final bridge = HealthBridge(_config);
    final client = IngestClient(_config);

    try {
      final granted = await bridge.requestPermissions();
      if (!granted) {
        setState(() => _status = 'Health permissions denied.');
        return;
      }

      setState(() => _status = 'Reading health data…');
      final batch = await bridge.buildBatch(days: 14);

      if (batch.records.isEmpty) {
        setState(() => _status = 'No health records found for the last 14 days.');
        return;
      }

      setState(() => _status = 'Uploading ${batch.records.length} records…');
      final result = await client.postBatch(batch);
      setState(
        () => _status = '${result.message}\n(${result.status}, run #${result.syncRunId})',
      );
    } on IngestException catch (e) {
      setState(() => _status = 'Sync failed: ${e.message}');
    } catch (e) {
      setState(() => _status = 'Error: $e');
    } finally {
      client.close();
      setState(() => _busy = false);
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
      appBar: AppBar(title: const Text('Sanctum Mobile')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Device bridge',
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
                hintText: 'https://sanctum.sanctumwellness.net',
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => _applyConfig(),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _tokenController,
              decoration: const InputDecoration(
                labelText: 'Ingest token (optional locally)',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
              onChanged: (_) => _applyConfig(),
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
                child: Text(_status, style: Theme.of(context).textTheme.bodySmall),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
