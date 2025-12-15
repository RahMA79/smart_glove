import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:smart_glove/features/doctor/presentation/screens/patient_overview_screen.dart';
import 'package:smart_glove/features/doctor/presentation/widgets/drawer_menu.dart';
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

  // مؤقت لحد FirebaseAuth
  static const String _doctorId = 'vhDs4fPhUjKvJVqVqJImj7';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      drawer: const DoctorDrawer(),
      appBar: AppBar(
        title: const Text("My Patients"),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('doctors')
                .doc(_doctorId)
                .collection('patients')
                .orderBy('createdAt', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text("Error: ${snapshot.error}"));
              }

              final docs = snapshot.data?.docs ?? [];
              if (docs.isEmpty) {
                return const Center(child: Text("No patients yet."));
              }

              final patients = docs.map((d) {
                final data = d.data() as Map<String, dynamic>;
                return DoctorPatientModel(
                  name: (data['name'] ?? '').toString(),
                  condition: (data['condition'] ?? '').toString(),
                  sessionsCount: (data['sessionsCount'] ?? 0) as int,
                );
              }).toList();

              return ListView.separated(
                itemCount: patients.length,
                separatorBuilder: (_, __) => const SizedBox(height: 14),
                itemBuilder: (context, index) {
                  final patient = patients[index];
                  final patientId = docs[index].id;

                  return PatientListCard(
                    patient: patient,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PatientOverviewScreen(
                            patientId: patientId,
                            patientName: patient.name,
                            condition: patient.condition,
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
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
