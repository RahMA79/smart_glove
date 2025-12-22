import 'package:flutter/material.dart';
import 'package:smart_glove/features/doctor/presentation/screens/assign_program_screen.dart';
import 'package:smart_glove/features/doctor/presentation/screens/patient_progress_screen.dart';
import 'package:smart_glove/features/doctor/presentation/widgets/patient_action_card.dart';

class PatientOverviewScreen extends StatefulWidget {
  final String patientId;
  final String patientName;
  final String condition;

  const PatientOverviewScreen({
    super.key,
    required this.patientId,
    required this.patientName,
    required this.condition,
  });

  @override
  State<PatientOverviewScreen> createState() => _PatientOverviewScreenState();
}

class _PatientOverviewScreenState extends State<PatientOverviewScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(title: Text(widget.patientName), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            PatientActionCard(
              icon: Icons.assignment_turned_in_outlined,
              title: "Assign Therapy Program",
              subtitle: "Create or assign a program for this patient",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AssignProgramScreen(
                      patientId: widget.patientId,
                      patientName: widget.patientName,
                      condition: widget.condition,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            PatientActionCard(
              icon: Icons.show_chart,
              title: "View Progress",
              subtitle: "EMG data, finger angles & progress",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        PatientProgressScreen(patientName: widget.patientName),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
