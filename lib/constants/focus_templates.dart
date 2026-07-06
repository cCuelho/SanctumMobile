import '../models/capture.dart';
import '../models/os_state.dart';

class FocusTemplate {
  const FocusTemplate({
    required this.key,
    required this.title,
    required this.inputCardIds,
    required this.suggestedProtocols,
    this.requiresBodyRegion = false,
  });

  final String key;
  final String title;
  final List<String> inputCardIds;
  final List<String> suggestedProtocols;
  final bool requiresBodyRegion;
}

class ProtocolTemplate {
  const ProtocolTemplate({
    required this.key,
    required this.title,
    required this.focusKeys,
  });

  final String key;
  final String title;
  final List<String> focusKeys;
}

class InputCard {
  const InputCard({
    required this.id,
    required this.label,
    required this.emoji,
    required this.group,
  });

  final String id;
  final String label;
  final String emoji;
  final String group;
}

const focusTemplates = <String, FocusTemplate>{
  'rehab': FocusTemplate(
    key: 'rehab',
    title: 'Rehabilitation',
    requiresBodyRegion: true,
    inputCardIds: ['pain', 'mobility', 'recovery', 'sleep', 'exercise', 'journal'],
    suggestedProtocols: ['pain_tracking', 'mobility_rehab'],
  ),
  'sleep': FocusTemplate(
    key: 'sleep',
    title: 'Sleep Optimization',
    inputCardIds: ['sleep', 'supplements', 'recovery', 'journal', 'check_in'],
    suggestedProtocols: ['magnesium_sleep', 'evening_meditation'],
  ),
  'fat_loss': FocusTemplate(
    key: 'fat_loss',
    title: 'Fat Loss',
    inputCardIds: ['nutrition', 'weight', 'exercise', 'check_in', 'journal'],
    suggestedProtocols: ['high_protein', 'calorie_tracking'],
  ),
  'mental_wellness': FocusTemplate(
    key: 'mental_wellness',
    title: 'Mental Wellness',
    inputCardIds: ['journal', 'mood', 'sleep', 'recovery', 'check_in'],
    suggestedProtocols: ['meditation_routine', 'journaling'],
  ),
  'strength': FocusTemplate(
    key: 'strength',
    title: 'Strength',
    inputCardIds: ['exercise', 'nutrition', 'recovery', 'weight', 'journal'],
    suggestedProtocols: ['strength_program'],
  ),
  'longevity': FocusTemplate(
    key: 'longevity',
    title: 'Longevity',
    inputCardIds: ['supplements', 'labs', 'vitals', 'exercise', 'sleep'],
    suggestedProtocols: ['supplement_stack'],
  ),
  'spiritual': FocusTemplate(
    key: 'spiritual',
    title: 'Spiritual Practice',
    inputCardIds: ['journal', 'recovery', 'sleep', 'check_in'],
    suggestedProtocols: ['qi_gong', 'meditation_routine'],
  ),
};

const protocolTemplates = <String, ProtocolTemplate>{
  'pain_tracking': ProtocolTemplate(
    key: 'pain_tracking',
    title: 'Pain Tracking Protocol',
    focusKeys: ['rehab'],
  ),
  'mobility_rehab': ProtocolTemplate(
    key: 'mobility_rehab',
    title: 'Mobility & Recovery Protocol',
    focusKeys: ['rehab'],
  ),
  'magnesium_sleep': ProtocolTemplate(
    key: 'magnesium_sleep',
    title: 'Magnesium Sleep Routine',
    focusKeys: ['sleep'],
  ),
  'evening_meditation': ProtocolTemplate(
    key: 'evening_meditation',
    title: 'Evening Meditation Protocol',
    focusKeys: ['sleep'],
  ),
  'high_protein': ProtocolTemplate(
    key: 'high_protein',
    title: 'High-Protein Nutrition Plan',
    focusKeys: ['fat_loss'],
  ),
  'calorie_tracking': ProtocolTemplate(
    key: 'calorie_tracking',
    title: 'Calorie Tracking',
    focusKeys: ['fat_loss'],
  ),
  'meditation_routine': ProtocolTemplate(
    key: 'meditation_routine',
    title: 'Meditation Routine',
    focusKeys: ['mental_wellness', 'spiritual'],
  ),
  'journaling': ProtocolTemplate(
    key: 'journaling',
    title: 'Journaling Protocol',
    focusKeys: ['mental_wellness'],
  ),
  'strength_program': ProtocolTemplate(
    key: 'strength_program',
    title: 'Strength Program',
    focusKeys: ['strength'],
  ),
  'supplement_stack': ProtocolTemplate(
    key: 'supplement_stack',
    title: 'Supplement Stack',
    focusKeys: ['longevity'],
  ),
  'qi_gong': ProtocolTemplate(
    key: 'qi_gong',
    title: 'Qi Gong Practice',
    focusKeys: ['spiritual'],
  ),
};

const inputCards = <String, InputCard>{
  'check_in': InputCard(id: 'check_in', label: 'Daily Check-In', emoji: '✅', group: 'health'),
  'sleep': InputCard(id: 'sleep', label: 'Sleep', emoji: '😴', group: 'health'),
  'nutrition': InputCard(id: 'nutrition', label: 'Nutrition', emoji: '🥗', group: 'health'),
  'supplements': InputCard(id: 'supplements', label: 'Supplements', emoji: '💊', group: 'health'),
  'exercise': InputCard(id: 'exercise', label: 'Exercise', emoji: '🏋️', group: 'activities'),
  'mobility': InputCard(id: 'mobility', label: 'Mobility', emoji: '🦵', group: 'health'),
  'pain': InputCard(id: 'pain', label: 'Pain Assessment', emoji: '🩹', group: 'health'),
  'recovery': InputCard(id: 'recovery', label: 'Recovery', emoji: '💚', group: 'health'),
  'journal': InputCard(id: 'journal', label: 'Journal', emoji: '📓', group: 'activities'),
  'mood': InputCard(id: 'mood', label: 'Mood', emoji: '🙂', group: 'health'),
  'weight': InputCard(id: 'weight', label: 'Weight', emoji: '⚖️', group: 'health'),
  'vitals': InputCard(id: 'vitals', label: 'Vitals', emoji: '❤️', group: 'health'),
  'labs': InputCard(id: 'labs', label: 'Labs', emoji: '🧪', group: 'advanced'),
  'import_data': InputCard(id: 'import_data', label: 'Device Sync', emoji: '🔗', group: 'import'),
};

const defaultCardOrder = [
  'check_in',
  'sleep',
  'nutrition',
  'supplements',
  'exercise',
  'journal',
  'recovery',
];

const inputGroupLabels = <String, String>{
  'health': 'Health Data',
  'activities': 'Activities',
  'advanced': 'Advanced',
  'import': 'Import Data',
};

String newFocusId() =>
    '${DateTime.now().millisecondsSinceEpoch}-${DateTime.now().microsecond}';

PrioritizedInputCards getPrioritizedInputCards(FocusTemplate? template) {
  final priorityIds = template?.inputCardIds ?? defaultCardOrder;
  final seen = <String>{};
  final prioritized = <InputCard>[];

  for (final id in priorityIds) {
    final card = inputCards[id];
    if (card != null && seen.add(id)) {
      prioritized.add(card);
    }
  }

  final rest = inputCards.values.where((c) => !seen.contains(c.id)).toList();
  return PrioritizedInputCards(prioritized: prioritized, rest: rest);
}

class PrioritizedInputCards {
  const PrioritizedInputCards({required this.prioritized, required this.rest});

  final List<InputCard> prioritized;
  final List<InputCard> rest;
}

List<ProtocolTemplate> getSuggestedProtocolsForFocus(String? templateKey) {
  if (templateKey == null) return [];
  final template = focusTemplates[templateKey];
  if (template == null) return [];
  return template.suggestedProtocols
      .map((key) => protocolTemplates[key])
      .whereType<ProtocolTemplate>()
      .toList();
}

List<ProtocolTemplate> getAvailableSuggestedProtocols(
  FocusArea? focus,
  List<Protocol> existingProtocols,
) {
  if (focus == null) return [];
  final suggested = getSuggestedProtocolsForFocus(focus.templateKey);
  final existingKeys = existingProtocols
      .where((p) => p.focusId == focus.id && p.templateKey != null)
      .map((p) => p.templateKey!)
      .toSet();
  return suggested.where((t) => !existingKeys.contains(t.key)).toList();
}

FocusArea buildFocusFromTemplate(
  String templateKey, {
  required String id,
  String bodyRegion = 'hip',
}) {
  if (templateKey == 'custom') {
    return FocusArea(id: id, title: 'Custom Focus', templateKey: null);
  }
  final tpl = focusTemplates[templateKey];
  if (tpl == null) {
    return FocusArea(id: id, title: 'Custom Focus');
  }
  if (templateKey == 'rehab') {
    const regions = {
      'hip': 'Hip',
      'knee': 'Knee',
      'shoulder': 'Shoulder',
      'spine_low': 'Lower back',
    };
    final label = regions[bodyRegion] ?? 'Hip';
    return FocusArea(
      id: id,
      title: 'Rehabilitation · $label',
      templateKey: 'rehab',
      bodyRegion: bodyRegion,
      bodyRegionLabel: label,
      createdAt: DateTime.now().toIso8601String(),
    );
  }
  return FocusArea(
    id: id,
    title: tpl.title,
    templateKey: templateKey,
    createdAt: DateTime.now().toIso8601String(),
  );
}

CaptureCategory? captureCategoryForInputCard(String cardId) {
  switch (cardId) {
    case 'nutrition':
      return CaptureCategory.meal;
    case 'supplements':
      return CaptureCategory.supplement;
    case 'exercise':
    case 'mobility':
      return CaptureCategory.exercise;
    case 'pain':
      return CaptureCategory.symptom;
    case 'labs':
      return CaptureCategory.labResult;
    case 'journal':
      return CaptureCategory.note;
    case 'sleep':
    case 'recovery':
    case 'mood':
    case 'vitals':
    case 'check_in':
    case 'weight':
      return CaptureCategory.vitals;
    default:
      return null;
  }
}
