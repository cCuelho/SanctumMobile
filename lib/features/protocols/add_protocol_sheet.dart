import 'package:flutter/material.dart';

import '../../constants/focus_templates.dart';
import '../../models/os_state.dart';
import '../../services/app_services.dart';
class AddProtocolSheet extends StatefulWidget {
  const AddProtocolSheet({super.key, required this.focusId});

  final String focusId;

  static Future<void> show(BuildContext context, {required String focusId}) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => AddProtocolSheet(focusId: focusId),
    );
  }

  @override
  State<AddProtocolSheet> createState() => _AddProtocolSheetState();
}

class _AddProtocolSheetState extends State<AddProtocolSheet> {
  final _titleController = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _addFromTemplate(ProtocolTemplate tpl) async {
    setState(() => _busy = true);
    await AppServices.instance.osState.addProtocol(
      focusId: widget.focusId,
      title: tpl.title,
      templateKey: tpl.key,
    );
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _addCustom() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a protocol name.')),
      );
      return;
    }
    setState(() => _busy = true);
    await AppServices.instance.osState.addProtocol(
      focusId: widget.focusId,
      title: title,
    );
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final os = AppServices.instance.osState;
    FocusArea? focus;
    for (final f in os.state.focuses) {
      if (f.id == widget.focusId) {
        focus = f;
        break;
      }
    }
    final suggested = getAvailableSuggestedProtocols(focus, os.protocols);
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(20, 8, 20, 24 + bottomInset),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Add protocol',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              if (focus != null) ...[
                const SizedBox(height: 4),
                Text(
                  focus.title,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
              if (suggested.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  'Suggested',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                ...suggested.map(
                  (tpl) => Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      title: Text(tpl.title),
                      trailing: const Icon(Icons.add),
                      onTap: _busy ? null : () => _addFromTemplate(tpl),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              Text(
                'Custom protocol',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  hintText: 'e.g. Collagen Protocol',
                  border: OutlineInputBorder(),
                ),
                textInputAction: TextInputAction.done,
                onSubmitted: _busy ? null : (_) => _addCustom(),
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: _busy ? null : _addCustom,
                child: _busy
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Create protocol'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
