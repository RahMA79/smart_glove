import 'package:flutter/material.dart';
import 'package:smart_glove/core/utils/size_config.dart';
import 'package:smart_glove/core/widgets/app_text_field.dart';
import 'package:smart_glove/core/widgets/primary_button.dart';
import '../widgets/labeled_slider.dart';

// ✅ add this
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
              onChanged: (value) => setState(() => _selectedInjuryType = value),
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
              onChanged: (v) => setState(() => _sessionDuration = v),
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
              onChanged: (v) => setState(() => _fingerAngle = v),
            ),

            SizedBox(height: SizeConfig.blockHeight * 1.5),

            LabeledSlider(
              title: 'Motor Assistance Level',
              value: _motorAssist,
              min: 0,
              max: 100,
              divisions: 10,
              unit: '%',
              onChanged: (v) => setState(() => _motorAssist = v),
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
              onChanged: (v) => setState(() => _emgThreshold = v),
            ),

            SizedBox(height: SizeConfig.blockHeight * 4),

            PrimaryButton(text: 'Create Program', onPressed: _onCreatePressed),
          ],
        ),
      ),
    );
  }

  void _onCreatePressed() {
    final name = _programNameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter program name")),
      );
      return;
    }

    final created = TherapyProgramModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(), // مؤقت لحد API
      name: name,
      injuryType: _selectedInjuryType ?? "Stroke",
      sessionDuration: _sessionDuration,
      fingerAngle: _fingerAngle,
      motorAssist: _motorAssist,
      emgThreshold: _emgThreshold,
    );

    // ✅ رجّعي البرنامج للشاشة اللي فتحت CreateProgramScreen
    Navigator.pop(context, created);
  }
}
