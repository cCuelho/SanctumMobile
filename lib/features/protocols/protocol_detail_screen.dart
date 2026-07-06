import 'package:flutter/material.dart';

import '../../core/routes.dart';
import '../../models/capture.dart';
import '../../models/capture_form_args.dart';
import '../../models/os_capture_context.dart';
import '../../models/os_state.dart';
import '../../services/app_services.dart';

class ProtocolDetailScreen extends StatelessWidget {
  const ProtocolDetailScreen({super.key, required this.protocolId});

  final String protocolId;

  Protocol? _findProtocol(OsState state) {
    for (final p in state.protocols) {
      if (p.id == protocolId) return p;
    }
    return null;
  }

  FocusArea? _findFocus(OsState state, String focusId) {
    for (final f in state.focuses) {
      if (f.id == focusId) return f;
    }
    return null;
  }

  Future<void> _rename(BuildContext context, Protocol protocol) async {
    final controller = TextEditingController(text: protocol.title);
    final newTitle = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Rename protocol'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (newTitle == null || newTitle.isEmpty) return;
    await AppServices.instance.osState.updateProtocol(protocolId, title: newTitle);
  }

  Future<void> _setStatus(BuildContext context, String status) async {
    await AppServices.instance.osState.updateProtocol(protocolId, status: status);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Protocol marked $status')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final os = AppServices.instance.osState;

    return ListenableBuilder(
      listenable: os,
      builder: (context, _) {
        final protocol = _findProtocol(os.state);

        if (protocol == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Protocol')),
            body: const Center(child: Text('Protocol not found.')),
          );
        }

        final focus = _findFocus(os.state, protocol.focusId);

        return Scaffold(
          appBar: AppBar(
            title: Text(protocol.title),
            actions: [
              PopupMenuButton<String>(
                onSelected: (value) async {
                  switch (value) {
                    case 'rename':
                      await _rename(context, protocol);
                    case 'pause':
                      await _setStatus(context, 'paused');
                    case 'complete':
                      await _setStatus(context, 'completed');
                    case 'activate':
                      await _setStatus(context, 'active');
                    case 'delete':
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Delete protocol?'),
                          content: Text('Delete "${protocol.title}"?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: const Text('Cancel'),
                            ),
                            FilledButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              child: const Text('Delete'),
                            ),
                          ],
                        ),
                      );
                      if (confirmed == true) {
                        await os.deleteProtocol(protocolId);
                        if (context.mounted) Navigator.of(context).pop();
                      }
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'rename', child: Text('Rename')),
                  if (protocol.status == 'active')
                    const PopupMenuItem(value: 'pause', child: Text('Pause')),
                  if (protocol.status == 'paused')
                    const PopupMenuItem(value: 'activate', child: Text('Resume')),
                  if (protocol.status != 'completed')
                    const PopupMenuItem(value: 'complete', child: Text('Mark completed')),
                  const PopupMenuItem(value: 'delete', child: Text('Delete')),
                ],
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (focus != null)
                Text(
                  focus.title,
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              const SizedBox(height: 8),
              Text('Status: ${protocol.status}'),
              if (protocol.notes.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(protocol.notes),
              ],
              const SizedBox(height: 24),
              Text(
                'Log for this protocol',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  ActionChip(
                    label: const Text('Check-in'),
                    onPressed: () => _openCapture(context, protocol, CaptureCategory.vitals),
                  ),
                  ActionChip(
                    label: const Text('Meal'),
                    onPressed: () => _openCapture(context, protocol, CaptureCategory.meal),
                  ),
                  ActionChip(
                    label: const Text('Supplement'),
                    onPressed: () => _openCapture(context, protocol, CaptureCategory.supplement),
                  ),
                  ActionChip(
                    label: const Text('Exercise'),
                    onPressed: () => _openCapture(context, protocol, CaptureCategory.exercise),
                  ),
                  ActionChip(
                    label: const Text('Journal'),
                    onPressed: () => _openCapture(context, protocol, CaptureCategory.note),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _openCapture(BuildContext context, Protocol protocol, CaptureCategory category) {
    final os = AppServices.instance.osState;
    Navigator.of(context).pushNamed(
      AppRoutes.captureForm,
      arguments: CaptureFormArgs(
        category: category,
        captureContext: OsCaptureContext(
          focusId: os.activeFocus?.id ?? protocol.focusId,
          protocolId: protocolId,
        ),
      ),
    );
  }
}
