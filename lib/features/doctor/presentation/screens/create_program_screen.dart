import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/size_config.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/primary_button.dart';
import '../widgets/labeled_slider.dart';

class CreateProgramScreen extends StatefulWidget {
  const CreateProgramScreen({super.key});

  @override
  State<CreateProgramScreen> createState() => _CreateProgramScreenState();
}

class _CreateProgramScreenState extends State<CreateProgramScreen> {
  final TextEditingController _programNameController = TextEditingController();
  String? _selectedInjuryType = 'Stroke';

  double _sessionDuration = 30; // minutes
  double _fingerAngle = 60; // genral angle
  double _motorAssist = 50; // %
  double _emgThreshold = 30; // %

  @override
  void dispose() {
    _programNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Create Program')),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: SizeConfig.blockWidth * 4, // 4% from width
          vertical: SizeConfig.blockHeight * 2, // 2% from height
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Program Name
            AppTextField(
              label: 'Program Name',
              hint: 'Enter program name',
              controller: _programNameController,
            ),
            SizedBox(height: SizeConfig.blockHeight * 2),

            // Injury Type
            const Text(
              'Type of Injury',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textMain,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _selectedInjuryType,
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
              onChanged: (value) {
                setState(() {
                  _selectedInjuryType = value;
                });
              },
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),

            SizedBox(height: SizeConfig.blockHeight * 3),

            const Text(
              'Session Settings',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textMain,
              ),
            ),
            SizedBox(height: SizeConfig.blockHeight * 1.5),

            // Session Duration
            LabeledSlider(
              title: 'Session Duration',
              value: _sessionDuration,
              min: 10,
              max: 60,
              divisions: 5,
              unit: 'min',
              onChanged: (v) {
                setState(() {
                  _sessionDuration = v;
                });
              },
            ),

            SizedBox(height: SizeConfig.blockHeight * 2),

            const Text(
              'Finger Angles & Assistance',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textMain,
              ),
            ),
            SizedBox(height: SizeConfig.blockHeight * 1.5),

            // Finger angles
            LabeledSlider(
              title: 'Target Finger Flexion',
              value: _fingerAngle,
              min: 0,
              max: 90,
              divisions: 9,
              unit: '°',
              onChanged: (v) {
                setState(() {
                  _fingerAngle = v;
                });
              },
            ),

            SizedBox(height: SizeConfig.blockHeight * 1.5),

            // Motor assistance
            LabeledSlider(
              title: 'Motor Assistance Level',
              value: _motorAssist,
              min: 0,
              max: 100,
              divisions: 10,
              unit: '%',
              onChanged: (v) {
                setState(() {
                  _motorAssist = v;
                });
              },
            ),

            SizedBox(height: SizeConfig.blockHeight * 3),

            const Text(
              'EMG Threshold',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textMain,
              ),
            ),
            SizedBox(height: SizeConfig.blockHeight * 1.5),

            // EMG threshold
            LabeledSlider(
              title: 'EMG Activation Threshold',
              value: _emgThreshold,
              min: 0,
              max: 100,
              divisions: 10,
              unit: '%MVC',
              onChanged: (v) {
                setState(() {
                  _emgThreshold = v;
                });
              },
            ),

            SizedBox(height: SizeConfig.blockHeight * 4),

            PrimaryButton(text: 'Create Program', onPressed: _onCreatePressed),
          ],
        ),
      ),
    );
  }

  void _onCreatePressed() {
    // for now, just print the values and check they are correct
    debugPrint('Program Name: ${_programNameController.text}');
    debugPrint('Injury Type: $_selectedInjuryType');
    debugPrint('Duration: $_sessionDuration');
    debugPrint('Finger Angle: $_fingerAngle');
    debugPrint('Motor Assist: $_motorAssist');
    debugPrint('EMG Threshold: $_emgThreshold');
  }
}
