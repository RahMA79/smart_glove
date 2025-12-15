import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:smart_glove/core/utils/size_config.dart';
import 'package:smart_glove/core/widgets/app_text_field.dart';
import 'package:smart_glove/core/widgets/primary_button.dart';
import '../widgets/labeled_slider.dart';
import 'package:smart_glove/features/doctor/data/models/therapy_program_model.dart';

class CreateProgramScreen extends StatefulWidget {
  const CreateProgramScreen({super.key});

  @override
  State<CreateProgramScreen> createState() => _CreateProgramScreenState();
}

class _CreateProgramScreenState extends State<CreateProgramScreen> {
  final TextEditingController _programNameController = TextEditingController();
  String? _selectedInjuryType = 'Stroke';

  double _sessionDuration = 30;
  double _fingerAngle = 60;
  double _motorAssist = 50;
  double _emgThreshold = 30;

  bool _saving = false;

  // مؤقت لحد Auth
  static const String _doctorId = 'vhDs4fPhUjKvJVqVqJImj7';

  @override
  void dispose() {
    _programNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Create Program')),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: SizeConfig.blockWidth * 4,
          vertical: SizeConfig.blockHeight * 2,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppTextField(
              label: 'Program Name',
              hint: 'Enter program name',
              controller: _programNameController,
            ),
            SizedBox(height: SizeConfig.blockHeight * 2),

            Text(
              'Type of Injury',
              style: textTheme.titleMedium?.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),

            DropdownButtonFormField<String>(
              value: _selectedInjuryType,
              items: const [
                DropdownMenuItem(value: 'Stroke', child: Text('Stroke')),
                DropdownMenuItem(
                  value: 'Tendon Repair',
                  child: Text('Tendon Repair'),
                ),
                DropdownMenuItem(value: 'Burn', child: Text('Burn')),
                DropdownMenuItem(
                  value: 'Nerve Injury',
                  child: Text('Nerve Injury'),
                ),
              ],
              onChanged: _saving
                  ? null
                  : (v) => setState(() => _selectedInjuryType = v),
              decoration: InputDecoration(
                filled: true,
                fillColor: theme.cardColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              dropdownColor: theme.cardColor,
              style: textTheme.bodyMedium,
            ),

            SizedBox(height: SizeConfig.blockHeight * 3),

            Text(
              'Session Settings',
              style: textTheme.titleMedium?.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: SizeConfig.blockHeight * 1.5),

            LabeledSlider(
              title: 'Session Duration',
              value: _sessionDuration,
              min: 10,
              max: 60,
              divisions: 5,
              unit: 'min',
              onChanged: _saving
                  ? (_) {}
                  : (v) => setState(() => _sessionDuration = v),
            ),

            SizedBox(height: SizeConfig.blockHeight * 2),

            Text(
              'Finger Angles & Assistance',
              style: textTheme.titleMedium?.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: SizeConfig.blockHeight * 1.5),

            LabeledSlider(
              title: 'Target Finger Flexion',
              value: _fingerAngle,
              min: 0,
              max: 90,
              divisions: 9,
              unit: '°',
              onChanged: _saving
                  ? (_) {}
                  : (v) => setState(() => _fingerAngle = v),
            ),

            SizedBox(height: SizeConfig.blockHeight * 1.5),

            LabeledSlider(
              title: 'Motor Assistance Level',
              value: _motorAssist,
              min: 0,
              max: 100,
              divisions: 10,
              unit: '%',
              onChanged: _saving
                  ? (_) {}
                  : (v) => setState(() => _motorAssist = v),
            ),

            SizedBox(height: SizeConfig.blockHeight * 3),

            Text(
              'EMG Threshold',
              style: textTheme.titleMedium?.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: SizeConfig.blockHeight * 1.5),

            LabeledSlider(
              title: 'EMG Activation Threshold',
              value: _emgThreshold,
              min: 0,
              max: 100,
              divisions: 10,
              unit: '%MVC',
              onChanged: _saving
                  ? (_) {}
                  : (v) => setState(() => _emgThreshold = v),
            ),

            SizedBox(height: SizeConfig.blockHeight * 4),

            PrimaryButton(
              text: _saving ? 'Saving...' : 'Create Program',
              onPressed: () {
                if (!_saving) _onCreatePressed();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onCreatePressed() async {
    final name = _programNameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter program name")),
      );
      return;
    }

    setState(() => _saving = true);

    try {
      final ref = FirebaseFirestore.instance
          .collection('doctors')
          .doc(_doctorId)
          .collection('programs')
          .doc();

      final now = FieldValue.serverTimestamp();

      await ref.set({
        'name': name,
        'injuryType': _selectedInjuryType ?? 'Stroke',
        'sessionDurationMin': _sessionDuration,
        'targetFingerFlexionDeg': _fingerAngle,
        'motorAssistancePercent': _motorAssist,
        'emgActivationThresholdPercentMvc': _emgThreshold,
        'patientsCount': 0, // ✅ جديد
        'createdAt': now,
        'updatedAt': now,
      });

      final created = TherapyProgramModel(
        id: ref.id,
        name: name,
        injuryType: _selectedInjuryType ?? "Stroke",
        sessionDuration: _sessionDuration,
        fingerAngle: _fingerAngle,
        motorAssist: _motorAssist,
        emgThreshold: _emgThreshold,
      );

      if (!mounted) return;
      Navigator.pop(context, created);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to create program: $e")));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}
