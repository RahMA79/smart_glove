import 'package:flutter/material.dart';
import 'package:smart_glove/core/utils/size_config.dart';
import 'package:smart_glove/features/patient/presentation/widgets/patient_profile_header.dart';
import 'package:smart_glove/features/patient/presentation/widgets/patient_program_card.dart';
import 'package:smart_glove/features/patient/presentation/widgets/patient_bottom_nav.dart';
import 'package:smart_glove/features/patient/session/presentation/screens/session_details_screen.dart';

import '../widgets/patient_drawer.dart';
import '../widgets/get_patient_name.dart';

class PatientHomeScreen extends StatefulWidget {
  final String userId;
  const PatientHomeScreen({super.key, required this.userId});

  @override
  State<PatientHomeScreen> createState() => _PatientHomeScreenState();
}

class _PatientHomeScreenState extends State<PatientHomeScreen> {
  String _patientName = '...';

  @override
  void initState() {
    super.initState();
    _loadName();
  }

  Future<void> _loadName() async {
    final name = await getPatientName(widget.userId);
    if (!mounted) return;
    setState(() => _patientName = name ?? 'Patient');
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);

    return Scaffold(
      drawer: PatientDrawer(patientName: _patientName),
      appBar: AppBar(
        toolbarHeight: SizeConfig.blockHeight * 10,
        title: PatientProfileHeader(patientName: _patientName),
        actions: const [SizedBox(width: 8)],
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: SizeConfig.blockWidth * 4,
          vertical: SizeConfig.blockHeight * 2,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Therapy Programs',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            SizedBox(height: SizeConfig.blockHeight * 2),

            PatientProgramCard(
              title: 'Burn Rehab',
              subtitle: '3 sessions / week',
              onTap: () {
                // TODO: open program details
              },
            ),

            SizedBox(height: SizeConfig.blockHeight * 1.5),

            PatientProgramCard(
              title: 'Nerve Therapy',
              subtitle: '4 sessions / week',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const SessionDetailsScreen(
                      sessionTitle: 'Session',
                      description:
                          "Designed to improve hand mobility by stimulating the flexor and extensor muscles.\nHelps restore nerve function and enhance activation.",
                      durationMinutes: 1,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: PatientBottomNav(
        currentIndex: 0,
        onTap: (index) {
          if (index == 0) return;

          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const SessionDetailsScreen(
                  sessionTitle: 'Session',
                  description:
                      "Designed to improve hand mobility by stimulating the flexor and extensor muscles.\nHelps restore nerve function and enhance activation.",
                  durationMinutes: 1,
                ),
              ),
            );
          }

          if (index == 2) {
            Navigator.pushNamed(context, '/profile');
          }
        },
      ),
    );
  }
}
