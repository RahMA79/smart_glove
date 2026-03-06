import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_glove/core/utils/size_config.dart';
import 'package:smart_glove/features/doctor/presentation/screens/settings_screen.dart';
import 'package:smart_glove/features/patient/presentation/widgets/patient_program_card.dart';
import 'package:smart_glove/features/patient/presentation/widgets/patient_bottom_nav.dart';
import 'package:smart_glove/features/patient/reqestscreen.dart';
import 'package:smart_glove/features/patient/session/presentation/screens/session_details_screen.dart';
import 'package:smart_glove/core/localization/app_localizations.dart';

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

  String _patientName = '';
  File? _profileImage;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadName();
    _loadProfileImage();
  }

  Future<void> _loadName() async {
    final name = await getPatientName(widget.userId);
    if (!mounted) return;
    // Don't hardcode a fallback here because localization depends on context.
    setState(() => _patientName = name ?? '');
  }

  Future<void> _loadProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    final path = prefs.getString('profile_image_path_${widget.userId}');
    if (path != null && path.isNotEmpty && File(path).existsSync()) {
      if (!mounted) return;
      setState(() => _profileImage = File(path));
    }
  }

  Future<void> _pickAndSaveProfileImage() async {
    try {
      final XFile? picked = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (picked == null) return;

      final dir = await getApplicationDocumentsDirectory();
      final ext = picked.path.split('.').last.toLowerCase();
      final safeExt = (ext == 'jpg' || ext == 'jpeg' || ext == 'png')
          ? ext
          : 'jpg';
      final newPath = '${dir.path}/profile_${widget.userId}.$safeExt';

      final saved = await File(picked.path).copy(newPath);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('profile_image_path_${widget.userId}', saved.path);

      if (!mounted) return;
      setState(() => _profileImage = saved);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.tr(
              'Could not open gallery: {error}',
              params: {'error': '$e'},
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    final displayName = _patientName.isEmpty
        ? context.tr('Patient')
        : _patientName;

    return Scaffold(
      drawer: PatientDrawer(patientName: displayName, userId: widget.userId),
      appBar: AppBar(title: Text(context.tr('Home'))),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: SizeConfig.blockWidth * 4,
          vertical: SizeConfig.blockHeight * 2,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _PatientTopBar(
              name: displayName,
              imageFile: _profileImage,
              onAvatarTap: _pickAndSaveProfileImage,
            ),

            SizedBox(height: SizeConfig.blockHeight * 3),

            Text(
              context.tr('Your Therapy Programs'),
              style: textTheme.titleMedium?.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: SizeConfig.blockHeight * 2),

            PatientProgramCard(
              title: context.tr('Burn Rehab'),
              subtitle: context.tr(
                '{count} sessions / week',
                params: {'count': '3'},
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SessionDetailsScreen(
                      sessionTitle: context.tr('Session'),
                      description: context.tr(
                        'Designed to improve hand mobility by stimulating the flexor and extensor muscles.\nHelps restore nerve function and enhance activation.',
                      ),
                      durationMinutes: 1,
                    ),
                  ),
                );
              },
            ),

            SizedBox(height: SizeConfig.blockHeight * 1.5),

            PatientProgramCard(
              title: context.tr('Nerve Therapy'),
              subtitle: context.tr(
                '{count} sessions / week',
                params: {'count': '4'},
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SessionDetailsScreen(
                      sessionTitle: context.tr('Session'),
                      description: context.tr(
                        'Designed to improve hand mobility by stimulating the flexor and extensor muscles.\nHelps restore nerve function and enhance activation.',
                      ),
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
                builder: (_) => SessionDetailsScreen(
                  sessionTitle: context.tr('Session'),
                  description: context.tr(
                    'Designed to improve hand mobility by stimulating the flexor and extensor muscles.\nHelps restore nerve function and enhance activation.',
                  ),
                  durationMinutes: 1,
                ),
              ),
            );
          }

          if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const DoctorRequestScreen()),
            );
          }
          if (index == 3) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => SettingsScreen()),
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
  final VoidCallback onAvatarTap;

  const _PatientTopBar({
    required this.name,
    required this.imageFile,
    required this.onAvatarTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    //final isDark = theme.brightness == Brightness.dark;

    return Row(
      children: [
        Material(
          color: Colors.transparent,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onAvatarTap,
            child: CircleAvatar(
              radius: 24,
              backgroundColor: cs.primary.withOpacity(0.12),
              backgroundImage: imageFile != null ? FileImage(imageFile!) : null,
              child: imageFile == null
                  ? Icon(Icons.add_a_photo_rounded, color: cs.primary, size: 22)
                  : null,
            ),
          ),
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
