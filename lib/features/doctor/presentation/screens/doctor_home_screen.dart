import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:smart_glove/core/utils/size_config.dart';
import 'package:smart_glove/core/widgets/primary_button.dart';
import 'package:smart_glove/features/doctor/data/models/therapy_program_model.dart';
import 'package:smart_glove/features/doctor/presentation/screens/create_program_screen.dart';
import 'package:smart_glove/features/doctor/presentation/screens/program_config_screen.dart';
import 'package:smart_glove/features/doctor/presentation/widgets/doctor_profile_header.dart';
import 'package:smart_glove/features/doctor/presentation/widgets/drawer_menu.dart';
import 'package:smart_glove/features/doctor/presentation/widgets/program_card.dart';
import 'package:smart_glove/features/doctor/presentation/widgets/doctor_bottom_nav.dart';
import 'package:smart_glove/features/doctor/presentation/screens/new_patient_request_screen.dart';
import 'package:smart_glove/features/doctor/presentation/screens/settings_screen.dart';
import 'package:smart_glove/core/localization/app_localizations.dart';

class DoctorHomeScreen extends StatefulWidget {
  const DoctorHomeScreen({super.key});

  @override
  State<DoctorHomeScreen> createState() => _DoctorHomeScreenState();
}

class _DoctorHomeScreenState extends State<DoctorHomeScreen> {
  String? _doctorId;
  int _navIndex = 0;

  @override
  void initState() {
    super.initState();
    _doctorId = FirebaseAuth.instance.currentUser?.uid;
  }

  double _toDouble(dynamic v, double fallback) {
    if (v is num) return v.toDouble();
    return fallback;
  }

  int _toInt(dynamic v, int fallback) {
    if (v is num) return v.toInt();
    return fallback;
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    final textTheme = Theme.of(context).textTheme;

    if (_doctorId == null) {
      return Scaffold(
        body: Center(
          child: Text(context.tr('No logged-in doctor. Please login again.')),
        ),
      );
    }

    return Scaffold(
      drawer: const DoctorDrawer(),
      appBar: AppBar(title: Text(context.tr('Home'))),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: SizeConfig.blockWidth * 4,
          vertical: SizeConfig.blockHeight * 2,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const DoctorProfileHeader(),
            SizedBox(height: SizeConfig.blockHeight * 3),
            Text(
              context.tr('Therapy Programs'),
              style: textTheme.titleMedium?.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: SizeConfig.blockHeight * 2),

            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('doctors')
                  .doc(_doctorId)
                  .collection('programs')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Text(
                    context.tr(
                      'error_with_details',
                      params: {'error': '${snapshot.error}'},
                    ),
                  );
                }

                final docs = snapshot.data?.docs ?? [];
                if (docs.isEmpty) {
                  return Text(context.tr('no_programs_yet'));
                }

                return Column(
                  children: docs.map((d) {
                    final data = d.data() as Map<String, dynamic>;

                    final program = TherapyProgramModel(
                      id: d.id,
                      name: (data['name'] ?? '').toString(),
                      injuryType: (data['injuryType'] ?? 'Stroke').toString(),
                      sessionDuration: _toDouble(
                        data['sessionDurationMin'],
                        30,
                      ),
                      fingerAngle: _toDouble(
                        data['targetFingerFlexionDeg'],
                        60,
                      ),
                      motorAssist: _toDouble(
                        data['motorAssistancePercent'],
                        50,
                      ),
                      emgThreshold: _toDouble(
                        data['emgActivationThresholdPercentMvc'],
                        30,
                      ),
                    );

                    final patientsCount = _toInt(data['patientsCount'], 0);

                    return Padding(
                      padding: EdgeInsets.only(
                        bottom: SizeConfig.blockHeight * 1.5,
                      ),
                      child: ProgramCard(
                        title: program.name,
                        patientsCount: patientsCount,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ProgramConfigScreen(
                                programId: program.id,
                                programName: program.name,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  }).toList(),
                );
              },
            ),

            SizedBox(height: SizeConfig.blockHeight * 3),

            PrimaryButton(
              text: context.tr('Create New Program'),
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CreateProgramScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: DoctorBottomNav(
        currentIndex: _navIndex,
        onChanged: (index) {
          setState(() => _navIndex = index);
          if (index == 0) return;

          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CreateProgramScreen()),
            );
          }

          if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const NewPatientRequestScreen(),
              ),
            );
          }

          if (index == 3) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            );
          }
        },
      ),
    );
  }
}
