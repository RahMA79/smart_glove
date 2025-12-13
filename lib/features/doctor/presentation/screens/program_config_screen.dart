import 'package:flutter/material.dart';
import 'package:smart_glove/core/utils/size_config.dart';
import 'package:smart_glove/core/widgets/primary_button.dart';
import '../../presentation/widgets/labeled_slider.dart';
import '../../../../core/widgets/app_text_field.dart';

class ProgramConfigScreen extends StatefulWidget {
  final String programName;

  const ProgramConfigScreen({super.key, required this.programName});

  @override
  State<ProgramConfigScreen> createState() => _ProgramConfigScreenState();
}

class _ProgramConfigScreenState extends State<ProgramConfigScreen> {
  double _sessionDuration = 30;

  final TextEditingController _setsController = TextEditingController(
    text: '3',
  );
  final TextEditingController _repsController = TextEditingController(
    text: '10',
  );

  double _thumbFlex = 45;
  double _indexFlex = 60;
  double _middleFlex = 60;

  double _assistMin = 20;
  double _assistMax = 80;

  double _flexorThreshold = 30;
  double _extensorThreshold = 25;

  @override
  void dispose() {
    _setsController.dispose();
    _repsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    final textTheme = Theme.of(context).textTheme;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(widget.programName)),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: SizeConfig.blockWidth * 4,
          vertical: SizeConfig.blockHeight * 2,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section: Session basics
            Text(
              'Session Basics',
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

            SizedBox(height: SizeConfig.blockHeight * 1.5),

            Row(
              children: [
                Expanded(
                  child: AppTextField(
                    label: 'Sets',
                    hint: 'e.g. 3',
                    controller: _setsController,
                    keyboardType: TextInputType.number,
                  ),
                ),
                SizedBox(width: SizeConfig.blockWidth * 4),
                Expanded(
                  child: AppTextField(
                    label: 'Reps per set',
                    hint: 'e.g. 10',
                    controller: _repsController,
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),

            SizedBox(height: SizeConfig.blockHeight * 3),

            // Section: Finger angles
            Text(
              'Target Finger Angles',
              style: textTheme.titleMedium?.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: SizeConfig.blockHeight * 1.5),

            LabeledSlider(
              title: 'Thumb Flexion',
              value: _thumbFlex,
              min: 0,
              max: 90,
              divisions: 9,
              unit: '°',
              onChanged: (v) => setState(() => _thumbFlex = v),
            ),
            LabeledSlider(
              title: 'Index Flexion',
              value: _indexFlex,
              min: 0,
              max: 90,
              divisions: 9,
              unit: '°',
              onChanged: (v) => setState(() => _indexFlex = v),
            ),
            LabeledSlider(
              title: 'Middle Flexion',
              value: _middleFlex,
              min: 0,
              max: 90,
              divisions: 9,
              unit: '°',
              onChanged: (v) => setState(() => _middleFlex = v),
            ),

            SizedBox(height: SizeConfig.blockHeight * 3),

            // Section: Motor assistance
            Text(
              'Motor Assistance',
              style: textTheme.titleMedium?.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: SizeConfig.blockHeight * 1.5),

            LabeledSlider(
              title: 'Min Assistance',
              value: _assistMin,
              min: 0,
              max: 100,
              divisions: 10,
              unit: '%',
              onChanged: (v) => setState(() => _assistMin = v),
            ),
            LabeledSlider(
              title: 'Max Assistance',
              value: _assistMax,
              min: 0,
              max: 100,
              divisions: 10,
              unit: '%',
              onChanged: (v) => setState(() => _assistMax = v),
            ),

            SizedBox(height: SizeConfig.blockHeight * 3),

            // Section: EMG thresholds
            Text(
              'EMG Thresholds',
              style: textTheme.titleMedium?.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: SizeConfig.blockHeight * 1.5),

            LabeledSlider(
              title: 'Flexor Activation',
              value: _flexorThreshold,
              min: 0,
              max: 100,
              divisions: 10,
              unit: '%MVC',
              onChanged: (v) => setState(() => _flexorThreshold = v),
            ),
            LabeledSlider(
              title: 'Extensor Activation',
              value: _extensorThreshold,
              min: 0,
              max: 100,
              divisions: 10,
              unit: '%MVC',
              onChanged: (v) => setState(() => _extensorThreshold = v),
            ),

            SizedBox(height: SizeConfig.blockHeight * 4),

            PrimaryButton(text: 'Save Changes', onPressed: _onSavePressed),
          ],
        ),
      ),
    );
  }

  void _onSavePressed() {
    final theme = Theme.of(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: theme.colorScheme.primary,
        content: const Text('Program settings saved'),
      ),
    );

    Navigator.pop(context);
  }
}
