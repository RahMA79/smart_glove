import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smart_glove/core/utils/size_config.dart';
import 'package:smart_glove/core/services/storage_service.dart';
import 'package:smart_glove/core/widgets/avatar_widget.dart';
import 'package:smart_glove/features/doctor/presentation/screens/settings_screen.dart';
import 'package:smart_glove/features/patient/presentation/widgets/patient_program_card.dart';
import 'package:smart_glove/features/patient/presentation/widgets/patient_bottom_nav.dart';
import 'package:smart_glove/features/patient/reqestscreen.dart';
import 'package:smart_glove/features/patient/session/presentation/screens/session_details_screen.dart';
import 'package:smart_glove/core/localization/app_localizations.dart';
import 'package:smart_glove/supabase_client.dart';
import '../widgets/patient_drawer.dart';

class PatientHomeScreen extends StatefulWidget {
  final String userId;
  const PatientHomeScreen({super.key, required this.userId});

  @override
  State<PatientHomeScreen> createState() => _PatientHomeScreenState();
}

class _PatientHomeScreenState extends State<PatientHomeScreen> {
  int _navIndex = 0;
  String _patientName = '';
  String? _avatarUrl;
  bool _uploadingAvatar = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final data = await supabase
          .from('users')
          .select('name, avatar_url')
          .eq('id', widget.userId)
          .maybeSingle();
      if (!mounted) return;
      setState(() {
        _patientName = data?['name']?.toString() ?? '';
        _avatarUrl = data?['avatar_url']?.toString();
      });
    } catch (_) {}
  }

  Future<void> _pickAndUploadAvatar() async {
    try {
      final XFile? picked = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (picked == null) return;

      setState(() => _uploadingAvatar = true);

      final url = await StorageService.uploadAvatar(
        userId: widget.userId,
        file: File(picked.path),
      );

      if (url != null) {
        // Update both users and patients tables
        await supabase
            .from('users')
            .update({'avatar_url': url})
            .eq('id', widget.userId);
        await supabase
            .from('patients')
            .update({'avatar_url': url})
            .eq('id', widget.userId);

        if (!mounted) return;
        setState(() => _avatarUrl = url);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Profile photo updated!'),
            backgroundColor: Colors.green.shade600,
          ),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to upload photo. Try again.')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not open gallery: $e')));
    } finally {
      if (mounted) setState(() => _uploadingAvatar = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    final theme = Theme.of(context);
    final displayName = _patientName.isEmpty
        ? context.tr('Patient')
        : _patientName;

    return Scaffold(
      drawer: PatientDrawer(
        patientName: displayName,
        userId: widget.userId,
        avatarUrl: _avatarUrl,
      ),
      appBar: AppBar(title: Text(context.tr('Home'))),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: SizeConfig.blockWidth * 4,
          vertical: SizeConfig.blockHeight * 2,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top bar with avatar
            _PatientTopBar(
              name: displayName,
              avatarUrl: _avatarUrl,
              uploading: _uploadingAvatar,
              onAvatarTap: _pickAndUploadAvatar,
            ),

            SizedBox(height: SizeConfig.blockHeight * 3),

            Text(
              context.tr('Your Therapy Programs'),
              style: theme.textTheme.titleMedium?.copyWith(
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
              onTap: () => Navigator.push(
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
              ),
            ),

            SizedBox(height: SizeConfig.blockHeight * 1.5),

            PatientProgramCard(
              title: context.tr('Nerve Therapy'),
              subtitle: context.tr(
                '{count} sessions / week',
                params: {'count': '4'},
              ),
              onTap: () => Navigator.push(
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
              ),
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
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            );
          }
        },
      ),
    );
  }
}

// ── Top bar widget ──────────────────────────────────────────────────────────
class _PatientTopBar extends StatelessWidget {
  final String name;
  final String? avatarUrl;
  final bool uploading;
  final VoidCallback onAvatarTap;

  const _PatientTopBar({
    required this.name,
    this.avatarUrl,
    required this.uploading,
    required this.onAvatarTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Row(
      children: [
        Stack(
          children: [
            AvatarWidget(
              imageUrl: avatarUrl,
              name: name,
              radius: 28,
              onTap: uploading ? null : onAvatarTap,
              showEditBadge: true,
            ),
            if (uploading)
              const Positioned.fill(
                child: CircleAvatar(
                  backgroundColor: Colors.black38,
                  child: SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(width: 14),
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
                  color: cs.onSurface.withOpacity(0.55),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
