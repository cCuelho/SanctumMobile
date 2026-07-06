import 'package:flutter/material.dart';

import '../../services/app_services.dart';
import 'add_focus_sheet.dart';

class FocusSwitcherSheet extends StatelessWidget {
  const FocusSwitcherSheet({super.key, this.onAddFocus});

  final VoidCallback? onAddFocus;

  Future<void> _renameFocus(BuildContext context, String focusId, String currentTitle) async {
    final controller = TextEditingController(text: currentTitle);
    final newTitle = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Rename Focus'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Focus name',
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
    if (newTitle == null || newTitle.isEmpty || newTitle == currentTitle) return;
    await AppServices.instance.osState.updateFocus(focusId, title: newTitle);
  }

  Future<void> _confirmDeleteFocus(BuildContext context, String focusId, String title) async {
    final os = AppServices.instance.osState;
    if (os.state.focuses.where((f) => f.status != 'archived').length <= 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Keep at least one Focus area.')),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Focus?'),
        content: Text('Delete "$title" and its protocols? This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await os.deleteFocus(focusId);
    if (context.mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final os = AppServices.instance.osState;

    return ListenableBuilder(
      listenable: os,
      builder: (context, _) {
        final focuses = os.state.focuses.where((f) => f.status != 'archived').toList();
        final activeId = os.activeFocus?.id;

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Switch Focus',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 4),
                const Text('Tap to switch. Long-press to rename or delete.'),
                const SizedBox(height: 12),
                if (focuses.isEmpty)
                  const Text('No Focus areas yet.')
                else
                  ...focuses.map((focus) {
                    final selected = focus.id == activeId;
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        selected ? Icons.radio_button_checked : Icons.radio_button_off,
                        color: selected ? Theme.of(context).colorScheme.primary : null,
                      ),
                      title: Text(focus.title),
                      subtitle: focus.isPrimary ? const Text('Primary') : null,
                      onTap: () async {
                        await os.setActiveFocus(focus.id);
                        if (context.mounted) Navigator.of(context).pop();
                      },
                      onLongPress: () => _showFocusActions(context, focus.id, focus.title),
                      trailing: IconButton(
                        icon: const Icon(Icons.more_vert),
                        onPressed: () => _showFocusActions(context, focus.id, focus.title),
                      ),
                    );
                  }),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    if (onAddFocus != null) {
                      onAddFocus!();
                    } else {
                      AddFocusSheet.show(context);
                    }
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Add Focus'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showFocusActions(BuildContext context, String focusId, String title) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('Rename'),
              onTap: () {
                Navigator.pop(ctx);
                _renameFocus(context, focusId, title);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline),
              title: const Text('Delete'),
              onTap: () {
                Navigator.pop(ctx);
                _confirmDeleteFocus(context, focusId, title);
              },
            ),
          ],
        ),
      ),
    );
  }
}
