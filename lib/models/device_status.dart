enum DeviceConnectionState {
  notConnected('Not connected'),
  permissionsPending('Permissions pending'),
  connected('Connected'),
  syncError('Sync error');

  const DeviceConnectionState(this.label);

  final String label;
}

class DeviceStatus {
  const DeviceStatus({
    required this.connectionState,
    this.lastSyncAt,
    this.lastSyncMessage,
    this.sourceLabel = 'Apple Health / Health Connect',
  });

  final DeviceConnectionState connectionState;
  final DateTime? lastSyncAt;
  final String? lastSyncMessage;
  final String sourceLabel;

  bool get isWearableConnected =>
      connectionState == DeviceConnectionState.connected;

  String get lastSyncLabel {
    if (lastSyncAt == null) return 'Never synced';
    final diff = DateTime.now().difference(lastSyncAt!);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}

class LogEntry {
  const LogEntry({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.recordedAt,
  });

  final String id;
  final String title;
  final String subtitle;
  final DateTime recordedAt;
}
