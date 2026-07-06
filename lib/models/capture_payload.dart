/// Typed payload from category-specific capture forms.
class CapturePayload {
  const CapturePayload({
    required this.summary,
    this.notes,
    this.mealName,
    this.mealSlot,
    this.foods,
    this.proteinEstimate,
    this.carbsEstimate,
    this.supplementName,
    this.dose,
    this.exerciseType,
    this.durationMinutes,
    this.intensity,
    this.symptomLabel,
    this.painLevel,
    this.weight,
    this.energy,
    this.labName,
    this.labResult,
    this.labUnit,
    this.reflectionEntry,
  });

  final String summary;
  final String? notes;

  // Meal
  final String? mealName;
  final String? mealSlot;
  final String? foods;
  final double? proteinEstimate;
  final double? carbsEstimate;

  // Supplement
  final String? supplementName;
  final String? dose;

  // Exercise
  final String? exerciseType;
  final double? durationMinutes;
  final String? intensity;

  // Symptom / vitals via daily log
  final String? symptomLabel;
  final int? painLevel;
  final double? weight;
  final int? energy;

  // Lab
  final String? labName;
  final String? labResult;
  final String? labUnit;

  // Note
  final String? reflectionEntry;
}
