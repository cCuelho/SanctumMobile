import 'package:flutter/material.dart';

import '../../constants/focus_templates.dart';
import '../../core/routes.dart';
import '../../models/capture_form_args.dart';
import '../../models/os_capture_context.dart';
import '../../services/app_services.dart';
import '../protocols/protocols_screen.dart';

class InputHomeScreen extends StatelessWidget {
  const InputHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final os = AppServices.instance.osState;
    final focus = os.activeFocus;
    final template = focus?.templateKey != null
        ? focusTemplates[focus!.templateKey!]
        : null;
    final cards = getPrioritizedInputCards(template);
    final protocols = os.protocolsForActiveFocus();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          focus != null
              ? 'What would you like to log for ${focus.title}?'
              : 'What would you like to log today?',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Text(
          'INPUT is scoped to your active Focus. One tap opens a quick capture form.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        if (protocols.isNotEmpty) ...[
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Active protocols',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: (_) => const ProtocolsScreen()),
                ),
                child: const Text('View all'),
              ),
            ],
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: protocols.take(4).map((p) {
              return ActionChip(
                label: Text(p.title),
                onPressed: () => Navigator.of(context).pushNamed(
                  AppRoutes.protocolDetail,
                  arguments: p.id,
                ),
              );
            }).toList(),
          ),
        ] else if (focus != null) ...[
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const ProtocolsScreen()),
            ),
            icon: const Icon(Icons.add),
            label: const Text('Add a protocol'),
          ),
        ],
        const SizedBox(height: 20),
        Text(
          'Priority for this Focus',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        _CardGrid(
          cards: cards.prioritized,
          protocolId: null,
        ),
        if (cards.rest.isNotEmpty) ...[
          const SizedBox(height: 20),
          Text(
            'More ways to log',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          _CardGrid(cards: cards.rest, protocolId: null),
        ],
      ],
    );
  }
}

class _CardGrid extends StatelessWidget {
  const _CardGrid({required this.cards, this.protocolId});

  final List<InputCard> cards;
  final String? protocolId;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: cards.map((card) => _InputCardTile(card: card, protocolId: protocolId)).toList(),
    );
  }
}

class _InputCardTile extends StatelessWidget {
  const _InputCardTile({required this.card, this.protocolId});

  final InputCard card;
  final String? protocolId;

  void _open(BuildContext context) {
    if (card.id == 'import_data') {
      Navigator.of(context).pushNamed(AppRoutes.devices);
      return;
    }

    final category = captureCategoryForInputCard(card.id);
    if (category == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${card.label} — use the web app for full forms.')),
      );
      return;
    }

    final os = AppServices.instance.osState;
    final ctx = OsCaptureContext(
      focusId: os.activeFocus?.id,
      protocolId: protocolId,
    );

    Navigator.of(context).pushNamed(
      AppRoutes.captureForm,
      arguments: CaptureFormArgs(category: category, captureContext: ctx),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: (MediaQuery.sizeOf(context).width - 48) / 2,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => _open(context),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(card.emoji, style: const TextStyle(fontSize: 22)),
                const SizedBox(height: 8),
                Text(
                  card.label,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
