import 'package:flutter/material.dart';

import '../../core/routes.dart';
import '../../core/widgets/placeholder_banner.dart';
import '../../services/app_services.dart';

/// Sign in — validates Sanctum server connectivity (no account API on MVP backend).
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  late final TextEditingController _apiController;
  late final TextEditingController _tokenController;
  final _nameController = TextEditingController();
  bool _busy = false;
  String? _status;

  @override
  void initState() {
    super.initState();
    final config = AppServices.instance.configRepo.loadConfig();
    _apiController = TextEditingController(text: config.apiBaseUrl);
    _tokenController = TextEditingController(text: config.ingestToken);
  }

  Future<void> _testConnection() async {
    setState(() {
      _busy = true;
      _status = null;
    });
    final result = await AppServices.instance.auth.checkServer(
      apiBaseUrl: _apiController.text.trim(),
    );
    if (mounted) {
      setState(() {
        _busy = false;
        _status = result.message;
      });
    }
  }

  Future<void> _continue({required bool isNewUser}) async {
    setState(() {
      _busy = true;
      _status = null;
    });

    final check = await AppServices.instance.auth.checkServer(
      apiBaseUrl: _apiController.text.trim(),
    );
    if (!check.ok) {
      if (mounted) {
        setState(() {
          _busy = false;
          _status = check.message;
        });
      }
      return;
    }

    await AppServices.instance.auth.signIn(
      displayName: _nameController.text.trim().isEmpty
          ? 'Sanctum user'
          : _nameController.text.trim(),
      apiBaseUrl: _apiController.text.trim(),
      ingestToken: _tokenController.text.trim(),
    );

    if (!mounted) return;
    setState(() => _busy = false);

    if (isNewUser) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.onboarding);
    } else if (AppServices.instance.auth.isOnboardingComplete) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.shell);
    } else {
      Navigator.of(context).pushReplacementNamed(AppRoutes.onboarding);
    }
  }

  @override
  void dispose() {
    _apiController.dispose();
    _tokenController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Connect Sanctum')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Your private wellness journal',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Point the app at your Sanctum server to log INPUT, review INSIGHTS, and sync device data.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          const PlaceholderBanner(
            message:
                'Sanctum MVP has no login accounts yet. Connection uses your server URL on your local network.',
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _apiController,
            decoration: const InputDecoration(
              labelText: 'Sanctum API base URL',
              hintText: 'http://192.168.1.62:5000',
            ),
            keyboardType: TextInputType.url,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _tokenController,
            decoration: const InputDecoration(
              labelText: 'Ingest token (optional)',
            ),
            obscureText: true,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Display name',
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: _busy ? null : _testConnection,
            child: const Text('Test connection'),
          ),
          if (_status != null) ...[
            const SizedBox(height: 12),
            Text(_status!, style: Theme.of(context).textTheme.bodySmall),
          ],
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _busy ? null : () => _continue(isNewUser: false),
            child: _busy
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Continue'),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: _busy ? null : () => _continue(isNewUser: true),
            child: const Text('New here — set up my journal'),
          ),
        ],
      ),
    );
  }
}
