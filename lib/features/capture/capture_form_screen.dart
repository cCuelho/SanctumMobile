import 'package:flutter/material.dart';

import '../../models/capture.dart';
import '../../models/capture_payload.dart';
import '../../models/os_capture_context.dart';
import '../../services/app_services.dart';

class CaptureFormScreen extends StatefulWidget {
  const CaptureFormScreen({
    super.key,
    required this.category,
    this.captureContext,
  });

  final CaptureCategory category;
  final OsCaptureContext? captureContext;

  @override
  State<CaptureFormScreen> createState() => _CaptureFormScreenState();
}

class _CaptureFormScreenState extends State<CaptureFormScreen> {
  final _summary = TextEditingController();
  final _notes = TextEditingController();
  final _fieldA = TextEditingController();
  final _fieldB = TextEditingController();
  final _fieldC = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _summary.dispose();
    _notes.dispose();
    _fieldA.dispose();
    _fieldB.dispose();
    _fieldC.dispose();
    super.dispose();
  }

  CapturePayload _buildPayload() {
    final cat = widget.category;
    return switch (cat) {
      CaptureCategory.meal => CapturePayload(
          summary: _summary.text.trim(),
          mealName: _fieldA.text.trim().isEmpty ? _summary.text.trim() : _fieldA.text.trim(),
          foods: _fieldB.text.trim().isEmpty ? _summary.text.trim() : _fieldB.text.trim(),
          mealSlot: _fieldC.text.trim().isEmpty ? null : _fieldC.text.trim(),
          notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
        ),
      CaptureCategory.supplement => CapturePayload(
          summary: _summary.text.trim(),
          supplementName: _fieldA.text.trim().isEmpty ? _summary.text.trim() : _fieldA.text.trim(),
          dose: _fieldB.text.trim().isEmpty ? null : _fieldB.text.trim(),
          notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
        ),
      CaptureCategory.exercise => CapturePayload(
          summary: _summary.text.trim(),
          exerciseType: _fieldA.text.trim().isEmpty ? _summary.text.trim() : _fieldA.text.trim(),
          durationMinutes: double.tryParse(_fieldB.text.trim()),
          intensity: _fieldC.text.trim().isEmpty ? null : _fieldC.text.trim(),
          notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
        ),
      CaptureCategory.symptom => CapturePayload(
          summary: _summary.text.trim(),
          symptomLabel: _fieldA.text.trim().isEmpty ? _summary.text.trim() : _fieldA.text.trim(),
          painLevel: int.tryParse(_fieldB.text.trim()),
          notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
        ),
      CaptureCategory.vitals => CapturePayload(
          summary: _summary.text.trim(),
          weight: double.tryParse(_fieldA.text.trim()),
          energy: int.tryParse(_fieldB.text.trim()),
          notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
        ),
      CaptureCategory.labResult => CapturePayload(
          summary: _summary.text.trim(),
          labName: _fieldA.text.trim().isEmpty ? _summary.text.trim() : _fieldA.text.trim(),
          labResult: _fieldB.text.trim().isEmpty ? null : _fieldB.text.trim(),
          labUnit: _fieldC.text.trim().isEmpty ? null : _fieldC.text.trim(),
          notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
        ),
      CaptureCategory.note => CapturePayload(
          summary: _summary.text.trim(),
          reflectionEntry: _summary.text.trim(),
          notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
        ),
      CaptureCategory.photo => CapturePayload(
          summary: _summary.text.trim(),
          notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
        ),
    };
  }

  Future<void> _save() async {
    final summary = _summary.text.trim();
    if (summary.isEmpty && widget.category != CaptureCategory.photo) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add a short summary to save.')),
      );
      return;
    }

    setState(() => _saving = true);
    final ctx = widget.captureContext ??
        AppServices.instance.capture.defaultCaptureContext();
    final result = await AppServices.instance.capture.submitCapture(
      category: widget.category,
      payload: _buildPayload(),
      captureContext: ctx,
    );
    if (mounted) {
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.message)),
      );
      if (result.success) Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPhoto = widget.category == CaptureCategory.photo;
    final focus = AppServices.instance.osState.activeFocus;

    return Scaffold(
      appBar: AppBar(title: Text('Log ${widget.category.label}')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          if (focus != null)
            Text(
              'Focus: ${focus.title}',
              style: Theme.of(context).textTheme.labelLarge,
            ),
          if (isPhoto)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Icon(
                      Icons.photo_camera_outlined,
                      size: 48,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Camera upload coming soon. Add a label now — photo sync in a later update.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
          if (isPhoto) const SizedBox(height: 16),
          ..._fieldsForCategory(),
          const SizedBox(height: 12),
          TextField(
            controller: _notes,
            decoration: const InputDecoration(labelText: 'Notes (optional)'),
            maxLines: 3,
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save to Sanctum'),
          ),
        ],
      ),
    );
  }

  List<Widget> _fieldsForCategory() {
    return switch (widget.category) {
      CaptureCategory.meal => [
        _tf(_summary, 'Summary', hint: 'e.g. Lunch — salad and chicken'),
        _tf(_fieldA, 'Meal name (optional)'),
        _tf(_fieldB, 'Foods'),
        _tf(_fieldC, 'Meal slot', hint: 'breakfast, lunch, dinner'),
      ],
      CaptureCategory.supplement => [
        _tf(_summary, 'Summary', hint: 'e.g. Magnesium glycinate'),
        _tf(_fieldA, 'Name'),
        _tf(_fieldB, 'Dose', hint: '200mg'),
      ],
      CaptureCategory.exercise => [
        _tf(_summary, 'Summary', hint: 'e.g. Morning walk'),
        _tf(_fieldA, 'Activity type'),
        _tf(_fieldB, 'Duration (minutes)', keyboard: TextInputType.number),
        _tf(_fieldC, 'Intensity', hint: 'light, moderate, hard'),
      ],
      CaptureCategory.symptom => [
        _tf(_summary, 'Summary', hint: 'How you feel'),
        _tf(_fieldA, 'Symptom'),
        _tf(_fieldB, 'Pain level (0–10)', keyboard: TextInputType.number),
      ],
      CaptureCategory.vitals => [
        _tf(_summary, 'Summary', hint: 'e.g. Morning check-in'),
        _tf(_fieldA, 'Weight (lb or kg)', keyboard: TextInputType.number),
        _tf(_fieldB, 'Energy (1–10)', keyboard: TextInputType.number),
      ],
      CaptureCategory.labResult => [
        _tf(_summary, 'Summary'),
        _tf(_fieldA, 'Lab name', hint: 'Vitamin D'),
        _tf(_fieldB, 'Result', hint: '42'),
        _tf(_fieldC, 'Unit', hint: 'ng/mL'),
      ],
      CaptureCategory.note => [
        _tf(_summary, 'Observation', hint: 'What did you notice?', maxLines: 4),
      ],
      CaptureCategory.photo => [
        _tf(_summary, 'Label', hint: 'e.g. Lab report photo'),
      ],
    };
  }

  Widget _tf(
    TextEditingController c,
    String label, {
    String? hint,
    TextInputType? keyboard,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: c,
        decoration: InputDecoration(labelText: label, hintText: hint),
        keyboardType: keyboard,
        maxLines: maxLines,
      ),
    );
  }
}
