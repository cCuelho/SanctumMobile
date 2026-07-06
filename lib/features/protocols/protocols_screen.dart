import 'package:flutter/material.dart';

import '../../constants/focus_templates.dart';
import '../../core/routes.dart';
import '../../services/app_services.dart';
import 'add_protocol_sheet.dart';

class ProtocolsScreen extends StatelessWidget {
  const ProtocolsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final os = AppServices.instance.osState;

    return ListenableBuilder(
      listenable: os,
      builder: (context, _) {
        final focus = os.activeFocus;
        final protocols = os.protocolsForActiveFocus();
        final suggested = getAvailableSuggestedProtocols(focus, os.protocols);

        return Scaffold(
          appBar: AppBar(title: const Text('Protocols')),
          floatingActionButton: focus == null
              ? null
              : FloatingActionButton.extended(
                  onPressed: () => AddProtocolSheet.show(context, focusId: focus.id),
                  icon: const Icon(Icons.add),
                  label: const Text('Add protocol'),
                ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
            children: [
              Text(
                focus != null ? 'Protocols for ${focus.title}' : 'Protocols',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              const Text(
                'Protocols are structured plans under your Focus — supplements, routines, rehab plans, and more.',
              ),
              const SizedBox(height: 16),
              if (focus == null)
                const Text('Set a Focus first to add protocols.')
              else if (protocols.isEmpty)
                const Text('No active protocols for this Focus yet.')
              else
                ...protocols.map(
                  (p) => Card(
                    child: ListTile(
                      leading: const Icon(Icons.assignment_outlined),
                      title: Text(p.title),
                      subtitle: Text(p.status),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => Navigator.of(context).pushNamed(
                        AppRoutes.protocolDetail,
                        arguments: p.id,
                      ),
                    ),
                  ),
                ),
              if (focus != null && suggested.isNotEmpty) ...[
                const SizedBox(height: 24),
                Text(
                  'Suggested',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: suggested.map((tpl) {
                    return ActionChip(
                      avatar: const Icon(Icons.add, size: 18),
                      label: Text(tpl.title),
                      onPressed: () async {
                        await os.addProtocol(
                          focusId: focus.id,
                          title: tpl.title,
                          templateKey: tpl.key,
                        );
                      },
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
