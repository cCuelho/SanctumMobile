import 'package:flutter/material.dart';

import '../../core/routes.dart';
import '../../core/widgets/placeholder_banner.dart';
import '../../models/device_status.dart';
import '../../services/app_services.dart';

class DevicesScreen extends StatefulWidget {
  const DevicesScreen({super.key});

  @override
  State<DevicesScreen> createState() => _DevicesScreenState();
}

class _DevicesScreenState extends State<DevicesScreen> {
  DeviceStatus? _status;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final status = await AppServices.instance.deviceSync.getStatus();
    setState(() {
      _status = status;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final status = _status;
    return Scaffold(
      appBar: AppBar(title: const Text('Devices')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: ListTile(
                    leading: Icon(
                      status?.isWearableConnected == true
                          ? Icons.link
                          : Icons.link_off,
                    ),
                    title: Text(status?.connectionState.label ?? 'Unknown'),
                    subtitle: Text(
                      status?.isWearableConnected == true
                          ? 'Last sync: ${status!.lastSyncLabel}'
                          : 'Connect Apple Health or Health Connect',
                    ),
                  ),
                ),
                if (status?.lastSyncMessage != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    status!.lastSyncMessage!,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
                const SizedBox(height: 16),
                const PlaceholderBanner(
                  message:
                      'Wearable data imports steps, sleep, and activity when available. No fake scores are shown.',
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.sync),
                  title: const Text('Device bridge'),
                  subtitle: const Text(
                    'Configure server URL and sync health data',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () async {
                    await Navigator.of(context).pushNamed(AppRoutes.deviceBridge);
                    await _load();
                  },
                ),
              ],
            ),
    );
  }
}
