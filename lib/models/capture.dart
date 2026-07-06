enum CaptureCategory {
  meal('Meal', 'Log food or nutrition'),
  supplement('Supplement', 'Track supplements or medications'),
  exercise('Exercise', 'Record movement or activity'),
  symptom('Symptom', 'Note how you feel'),
  vitals('Vitals', 'Record blood pressure, weight, etc.'),
  labResult('Lab result', 'Add lab values or results'),
  note('Note', 'Free-form observation'),
  photo('Photo / document', 'Attach a photo or document');

  const CaptureCategory(this.label, this.description);

  final String label;
  final String description;
}

class CaptureEntry {
  const CaptureEntry({
    required this.id,
    required this.category,
    required this.summary,
    required this.recordedAt,
    this.notes,
  });

  final String id;
  final CaptureCategory category;
  final String summary;
  final DateTime recordedAt;
  final String? notes;
}

class DailyItem {
  const DailyItem({
    required this.id,
    required this.title,
    required this.dueLabel,
    this.isComplete = false,
  });

  final String id;
  final String title;
  final String dueLabel;
  final bool isComplete;
}
