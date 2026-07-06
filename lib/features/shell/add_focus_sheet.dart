import 'package:flutter/material.dart';

import '../../constants/focus_templates.dart';
import '../../services/app_services.dart';

/// Bottom sheet to add a new Focus (template picker + optional protocols).
class AddFocusSheet extends StatefulWidget {
  const AddFocusSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => const AddFocusSheet(),
    );
  }

  @override
  State<AddFocusSheet> createState() => _AddFocusSheetState();
}

class _AddFocusSheetState extends State<AddFocusSheet> {
  static const _focusOptions = [
    ('rehab', 'Rehabilitation'),
    ('sleep', 'Sleep Optimization'),
    ('fat_loss', 'Fat Loss'),
    ('mental_wellness', 'Mental Wellness'),
    ('strength', 'Strength'),
    ('longevity', 'Longevity'),
    ('spiritual', 'Spiritual Practice'),
  ];

  String? _selectedTemplateKey;
  String _bodyRegion = 'hip';
  final Set<String> _selectedProtocolKeys = {};
  bool _switchToNew = true;
  bool _busy = false;

  List<ProtocolTemplate> get _protocolOptions {
    if (_selectedTemplateKey == null) return [];
    return getSuggestedProtocolsForFocus(_selectedTemplateKey);
  }

  Future<void> _submit() async {
    if (_selectedTemplateKey == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select a Focus template.')),
      );
      return;
    }

    setState(() => _busy = true);
    final focusId = newFocusId();
    final focus = buildFocusFromTemplate(
      _selectedTemplateKey!,
      id: focusId,
      bodyRegion: _bodyRegion,
    );

    await AppServices.instance.osState.addFocusPhase(
      focusSelections: [focus],
      activeFocusId: focusId,
      protocolTemplateKeys: _selectedProtocolKeys.toList(),
      switchToNew: _switchToNew,
    );

    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
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
                'Add Focus',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              const Text('Pick what you want to work on. You can run multiple Focus areas at once.'),
              const SizedBox(height: 16),
              ..._focusOptions.map((opt) {
                final selected = _selectedTemplateKey == opt.$1;
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    title: Text(opt.$2),
                    trailing: selected ? const Icon(Icons.check_circle) : null,
                    onTap: () => setState(() {
                      _selectedTemplateKey = opt.$1;
                      _selectedProtocolKeys.clear();
                    }),
                  ),
                );
              }),
              if (_selectedTemplateKey == 'rehab') ...[
                const SizedBox(height: 8),
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
              if (_protocolOptions.isNotEmpty) ...[
                const SizedBox(height: 20),
                Text(
                  'Suggested protocols (optional)',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                ..._protocolOptions.map((tpl) {
                  final selected = _selectedProtocolKeys.contains(tpl.key);
                  return CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
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
              ],
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Switch to this Focus'),
                subtitle: const Text('Make it active for Input and Insights'),
                value: _switchToNew,
                onChanged: _busy ? null : (v) => setState(() => _switchToNew = v),
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: _busy ? null : _submit,
                child: _busy
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Add Focus'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
