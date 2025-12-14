import 'package:flutter/material.dart';
import 'package:smart_glove/features/doctor/presentation/screens/assign_program_screen.dart';
import 'package:smart_glove/features/doctor/presentation/screens/patient_overview_screen.dart';

import '../../data/models/doctor_patient_model.dart';
import '../widgets/doctor_bottom_nav.dart';
import '../widgets/patient_list_card.dart';

class MyPatientsScreen extends StatefulWidget {
  const MyPatientsScreen({super.key});

  @override
  State<MyPatientsScreen> createState() => _MyPatientsScreenState();
}

class _MyPatientsScreenState extends State<MyPatientsScreen> {
  int _navIndex = 0;

  // TODO: replace with API data
  final List<DoctorPatientModel> _patients = const [
    DoctorPatientModel(name: "John Doe", condition: "Stroke", sessionsCount: 4),
    DoctorPatientModel(
      name: "Emily Wilson",
      condition: "Burn Injury",
      sessionsCount: 8,
    ),
    DoctorPatientModel(
      name: "Mark Smith",
      condition: "New Injury",
      sessionsCount: 7,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("My Patients"),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            // TODO: open drawer
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.arrow_forward),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Expanded(
                child: ListView.separated(
                  itemCount: _patients.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 14),
                  itemBuilder: (context, index) {
                    final patient = _patients[index];

                    return PatientListCard(
                      patient: patient,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PatientOverviewScreen(
                              patientId: "1",
                              patientName: patient.name,
                              condition: patient.condition,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: DoctorBottomNav(
        currentIndex: _navIndex,
        onChanged: (i) => setState(() => _navIndex = i),
      ),
    );
  }
}
