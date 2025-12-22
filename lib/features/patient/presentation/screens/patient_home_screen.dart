import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_glove/core/utils/size_config.dart';
import 'package:smart_glove/features/doctor/presentation/screens/settings_screen.dart';
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
  int _navIndex = 0;

  String _patientName = '...';
  File? _profileImage;

  @override
  void initState() {
    super.initState();
    _loadName();
    _loadProfileImage();
  }

  Future<void> _loadName() async {
    final name = await getPatientName(widget.userId);
    if (!mounted) return;
    setState(() => _patientName = name ?? 'Patient');
  }

  Future<void> _loadProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    final path = prefs.getString('profile_image_path_${widget.userId}');
    if (path != null && path.isNotEmpty && File(path).existsSync()) {
      if (!mounted) return;
      setState(() => _profileImage = File(path));
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      drawer: PatientDrawer(patientName: _patientName, userId: widget.userId),
      appBar: AppBar(title: const Text('Home')),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: SizeConfig.blockWidth * 4,
          vertical: SizeConfig.blockHeight * 2,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ Header بسيط (مش Card Profile كبير)
            _PatientTopBar(name: _patientName, imageFile: _profileImage),

            SizedBox(height: SizeConfig.blockHeight * 3),

            Text(
              'Your Therapy Programs',
              style: textTheme.titleMedium?.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: SizeConfig.blockHeight * 2),

            PatientProgramCard(
              title: 'Burn Rehab',
              subtitle: '3 sessions / week',
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
        currentIndex: _navIndex,
        onTap: (index) {
          setState(() => _navIndex = index);

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
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) {
                  return SettingsScreen();
                },
              ),
            );
          }
        },
      ),
    );
  }
}

class _PatientTopBar extends StatelessWidget {
  final String name;
  final File? imageFile;

  const _PatientTopBar({required this.name, required this.imageFile});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Row(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: cs.primary.withOpacity(0.12),
          backgroundImage: imageFile != null ? FileImage(imageFile!) : null,
          child: imageFile == null
              ? Icon(Icons.person_rounded, color: cs.primary, size: 26)
              : null,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Patient',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: cs.onSurface.withOpacity(0.60),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
