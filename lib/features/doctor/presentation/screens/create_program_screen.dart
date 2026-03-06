import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:smart_glove/core/utils/size_config.dart';
import 'package:smart_glove/core/widgets/app_text_field.dart';
import 'package:smart_glove/core/widgets/primary_button.dart';
import 'package:smart_glove/core/localization/app_localizations.dart';
import 'package:smart_glove/features/doctor/presentation/widgets/doctor_bottom_nav.dart';
import 'doctor_home_screen.dart';
import 'new_patient_request_screen.dart';
import 'settings_screen.dart';
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

  String? _doctorId;
  int _navIndex = 1;

  @override
  void initState() {
    super.initState();
    _doctorId = FirebaseAuth.instance.currentUser?.uid;
  }

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

    if (_doctorId == null) {
      return Scaffold(
        body: Center(child: Text(context.tr('no_logged_in_doctor'))),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(context.tr('create_program'))),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: SizeConfig.blockWidth * 4,
          vertical: SizeConfig.blockHeight * 2,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppTextField(
              label: context.tr('program_name'),
              hint: context.tr('enter_program_name'),
              controller: _programNameController,
            ),
            SizedBox(height: SizeConfig.blockHeight * 2),

            Text(
              context.tr('type_of_injury'),
              style: textTheme.titleMedium?.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),

            DropdownButtonFormField<String>(
              initialValue: _selectedInjuryType,
              items: [
                DropdownMenuItem(
                  value: 'Stroke',
                  child: Text(context.tr('injury_stroke')),
                ),
                DropdownMenuItem(
                  value: 'Tendon Repair',
                  child: Text(context.tr('injury_tendon_repair')),
                ),
                DropdownMenuItem(
                  value: 'Burn',
                  child: Text(context.tr('injury_burn')),
                ),
                DropdownMenuItem(
                  value: 'Nerve Injury',
                  child: Text(context.tr('injury_nerve_injury')),
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
              context.tr('session_settings'),
              style: textTheme.titleMedium?.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: SizeConfig.blockHeight * 1.5),

            LabeledSlider(
              title: context.tr('session_duration'),
              value: _sessionDuration,
              min: 10,
              max: 60,
              divisions: 5,
              unit: context.tr('minutes_unit'),
              onChanged: _saving
                  ? (_) {}
                  : (v) => setState(() => _sessionDuration = v),
            ),

            SizedBox(height: SizeConfig.blockHeight * 2),

            Text(
              context.tr('finger_angles_and_assistance'),
              style: textTheme.titleMedium?.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: SizeConfig.blockHeight * 1.5),

            LabeledSlider(
              title: context.tr('target_finger_flexion'),
              value: _fingerAngle,
              min: 0,
              max: 90,
              divisions: 9,
              unit: context.tr('degree_unit'),
              onChanged: _saving
                  ? (_) {}
                  : (v) => setState(() => _fingerAngle = v),
            ),

            SizedBox(height: SizeConfig.blockHeight * 1.5),

            LabeledSlider(
              title: context.tr('motor_assistance_level'),
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
              context.tr('emg_threshold'),
              style: textTheme.titleMedium?.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: SizeConfig.blockHeight * 1.5),

            LabeledSlider(
              title: context.tr('emg_activation_threshold'),
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
              text: _saving
                  ? context.tr('saving')
                  : context.tr('create_program'),
              onPressed: () {
                if (!_saving) _onCreatePressed();
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: DoctorBottomNav(
        currentIndex: _navIndex,
        onChanged: (index) {
          if (index == _navIndex) return;
          setState(() => _navIndex = index);

          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const DoctorHomeScreen()),
            );
          }

          if (index == 2) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => const NewPatientRequestScreen(),
              ),
            );
          }

          if (index == 3) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            );
          }
        },
      ),
    );
  }

  Future<void> _onCreatePressed() async {
    final name = _programNameController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tr('please_enter_program_name'))),
      );
      return;
    }

    if (_doctorId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tr('no_logged_in_doctor_short'))),
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
        'patientsCount': 0,
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.tr('failed_to_create_program', params: {'error': '$e'}),
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}
