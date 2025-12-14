import 'package:flutter/material.dart';
import 'package:smart_glove/core/utils/size_config.dart';
import 'package:smart_glove/core/widgets/primary_button.dart';
import 'package:smart_glove/features/doctor/data/models/therapy_program_model.dart';

import '../widgets/patient_header_card.dart';
import '../widgets/program_select_card.dart';

// ✅ add this import (مسارك الحالي)
import 'package:smart_glove/features/doctor/presentation/screens/create_program_screen.dart';

class AssignProgramScreen extends StatefulWidget {
  final String patientId;
  final String patientName;
  final String condition;

  final List<TherapyProgramModel>? programs;

  const AssignProgramScreen({
    super.key,
    required this.patientId,
    required this.patientName,
    required this.condition,
    this.programs,
  });

  @override
  State<AssignProgramScreen> createState() => _AssignProgramScreenState();
}

class _AssignProgramScreenState extends State<AssignProgramScreen> {
  String? _selectedProgramId;

  late final List<TherapyProgramModel> _programs = [
    ...(widget.programs ??
        const [
          TherapyProgramModel(
            id: "p1",
            name: "Hand Mobility - Beginner",
            injuryType: "Stroke",
            sessionDuration: 30,
            fingerAngle: 60,
            motorAssist: 50,
            emgThreshold: 30,
          ),
          TherapyProgramModel(
            id: "p2",
            name: "Grip Strength - Intermediate",
            injuryType: "Tendon Repair",
            sessionDuration: 45,
            fingerAngle: 70,
            motorAssist: 40,
            emgThreshold: 35,
          ),
        ]),
  ];

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    final theme = Theme.of(context);
    final canAssign = _selectedProgramId != null;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(title: const Text("Assign Program"), centerTitle: true),
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: SizeConfig.blockWidth * 4,
          vertical: SizeConfig.blockHeight * 2,
        ),
        child: Column(
          children: [
            PatientHeaderCard(
              patientName: widget.patientName,
              condition: widget.condition,
            ),
            SizedBox(height: SizeConfig.blockHeight * 2),

            Row(
              children: [
                Expanded(
                  child: Text(
                    "Select a program",
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: _openCreateProgram,
                  child: Text(
                    "Create New",
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: SizeConfig.blockHeight * 1.2),

            Expanded(
              child: ListView.separated(
                itemCount: _programs.length,
                separatorBuilder: (_, __) =>
                    SizedBox(height: SizeConfig.blockHeight * 1.6),
                itemBuilder: (context, i) {
                  final p = _programs[i];
                  return ProgramSelectCard(
                    program: p,
                    selected: _selectedProgramId == p.id,
                    onTap: () => setState(() => _selectedProgramId = p.id),
                  );
                },
              ),
            ),

            SizedBox(height: SizeConfig.blockHeight * 2),

            PrimaryButton(
              text: "Assign Program",
              onPressed: () {
                if (canAssign) {
                  _onAssignPressed();
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openCreateProgram() async {
    final TherapyProgramModel? created = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CreateProgramScreen()),
    );

    if (created == null) return;

    setState(() {
      _programs.insert(0, created);
      _selectedProgramId = created.id;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Program created and selected")),
    );
  }

  void _onAssignPressed() {
    final programId = _selectedProgramId!;
    debugPrint(
      "Assign Program => patientId=${widget.patientId}, programId=$programId",
    );

    // TODO: API call assign here

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Program assigned successfully")),
    );
    Navigator.pop(context);
  }
}
