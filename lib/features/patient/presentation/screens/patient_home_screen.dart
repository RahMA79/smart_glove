import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smart_glove/core/utils/size_config.dart';
import 'package:smart_glove/core/services/storage_service.dart';
import 'package:smart_glove/core/widgets/avatar_widget.dart';
import 'package:smart_glove/features/doctor/presentation/screens/settings_screen.dart';
import 'package:smart_glove/features/patient/presentation/screens/session_history_screen.dart';
import 'package:smart_glove/features/patient/session/presentation/screens/session_details_screen.dart';
import 'package:smart_glove/features/patient/presentation/widgets/patient_bottom_nav.dart';
import 'package:smart_glove/features/patient/reqestscreen.dart';
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

  // Mock stats
  static const int _sessionsDone = 12;
  static const int _thisWeek = 3;
  static const double _progress = 0.78;

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
      }
    } catch (_) {
    } finally {
      if (mounted) setState(() => _uploadingAvatar = false);
    }
  }

  String _getGreeting(BuildContext context) {
    final hour = DateTime.now().hour;
    if (hour < 12) return context.tr('good_morning');
    if (hour < 17) return context.tr('good_afternoon');
    if (hour < 21) return context.tr('good_evening');
    return context.tr('good_night');
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
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
            // ── Patient top bar ─────────────────────────────────
            Row(
              children: [
                Stack(
                  children: [
                    AvatarWidget(
                      imageUrl: _avatarUrl,
                      name: displayName,
                      radius: 28,
                      onTap: _uploadingAvatar ? null : _pickAndUploadAvatar,
                      showEditBadge: true,
                    ),
                    if (_uploadingAvatar)
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
                        _getGreeting(context),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: cs.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        displayName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        context.tr('Patient'),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: cs.onSurface.withOpacity(0.55),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: SizeConfig.blockHeight * 3),

            // ── Stats row ───────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: _PatientStatCard(
                    icon: Icons.check_circle_outline_rounded,
                    iconColor: const Color(0xFF43A047),
                    bgColor: const Color(0xFF43A047).withOpacity(0.10),
                    value: '$_sessionsDone',
                    label: context.tr('Sessions Done'),
                    isDark: isDark,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _PatientStatCard(
                    icon: Icons.calendar_today_outlined,
                    iconColor: cs.primary,
                    bgColor: cs.primary.withOpacity(0.10),
                    value: '$_thisWeek',
                    label: context.tr('This Week'),
                    isDark: isDark,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _PatientStatCard(
                    icon: Icons.trending_up_rounded,
                    iconColor: const Color(0xFF00BFA5),
                    bgColor: const Color(0xFF00BFA5).withOpacity(0.10),
                    value: '${(_progress * 100).toInt()}%',
                    label: context.tr('Progress'),
                    isDark: isDark,
                  ),
                ),
              ],
            ),

            SizedBox(height: SizeConfig.blockHeight * 3),

            Text(
              context.tr('Your Therapy Programs'),
              style: theme.textTheme.titleMedium?.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: SizeConfig.blockHeight * 1.5),

            // ── Stroke Rehab program ────────────────────────────
            _TherapyProgramCard(
              title: context.tr('Stroke Rehab'),
              sessionsPerWeek: 3,
              durationMin: 30,
              difficulty: context.tr('Moderate'),
              difficultyColor: const Color(0xFFFF7043),
              iconColor: const Color(0xFFFF7043),
              icon: Icons.local_fire_department_rounded,
              iconBg: const Color(0xFFFF7043).withOpacity(0.12),
              isDark: isDark,
              onStart: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SessionDetailsScreen(
                    sessionTitle: context.tr('Stroke Rehab'),
                    injuryType: 'Stroke',
                    description: context.tr('stroke_rehab_desc'),
                    durationMinutes: 30,
                    exercises: const [
                      'Finger flexion warm-up',
                      'Wrist rotation',
                      'Grip strengthening',
                      'Finger extension hold',
                      'Cool-down stretches',
                    ],
                  ),
                ),
              ),
            ),

            SizedBox(height: SizeConfig.blockHeight * 1.5),

            // ── Post-Stroke Recovery ────────────────────────────
            _TherapyProgramCard(
              title: context.tr('Post-Stroke Recovery'),
              sessionsPerWeek: 3,
              durationMin: 20,
              difficulty: context.tr('Gentle'),
              difficultyColor: const Color(0xFF00BFA5),
              iconColor: const Color(0xFF00BFA5),
              icon: Icons.bolt_rounded,
              iconBg: const Color(0xFF00BFA5).withOpacity(0.12),
              isDark: isDark,
              onStart: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SessionDetailsScreen(
                    sessionTitle: context.tr('Post-Stroke Recovery'),
                    injuryType: 'Stroke',
                    description: context.tr('stroke_rehab_desc'),
                    durationMinutes: 20,
                    exercises: const [
                      'Gentle finger flexion',
                      'Wrist circles',
                      'Light grip',
                      'Finger tap sequence',
                      'Relaxation stretch',
                    ],
                  ),
                ),
              ),
            ),

            SizedBox(height: SizeConfig.blockHeight * 3),
          ],
        ),
      ),
      bottomNavigationBar: PatientBottomNav(
        currentIndex: _navIndex,
        onTap: (index) {
          if (index == _navIndex) return;
          setState(() => _navIndex = index);
          if (index == 1) _fadeTo(context, const SessionHistoryScreen());
          if (index == 2) _fadeTo(context, const DoctorRequestScreen());
          if (index == 3)
            _fadeTo(context, const SettingsScreen(role: 'patient'));
        },
      ),
    );
  }

  void _fadeTo(BuildContext context, Widget page) {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => page,
        transitionDuration: const Duration(milliseconds: 200),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
      ),
    );
  }
}

// ── Stat card ─────────────────────────────────────────────────────────────
class _PatientStatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color bgColor;
  final String value;
  final String label;
  final bool isDark;

  const _PatientStatCard({
    required this.icon,
    required this.iconColor,
    required this.bgColor,
    required this.value,
    required this.label,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 22),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: iconColor,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.60),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Therapy program card ──────────────────────────────────────────────────
class _TherapyProgramCard extends StatelessWidget {
  final String title;
  final int sessionsPerWeek;
  final int durationMin;
  final String difficulty;
  final Color difficultyColor;
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final bool isDark;
  final VoidCallback onStart;

  const _TherapyProgramCard({
    required this.title,
    required this.sessionsPerWeek,
    required this.durationMin,
    required this.difficulty,
    required this.difficultyColor,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.isDark,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: theme.dividerColor.withOpacity(isDark ? 0.15 : 0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.10 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.loop_rounded,
                      size: 13,
                      color: cs.onSurface.withOpacity(0.45),
                    ),
                    const SizedBox(width: 3),
                    Text(
                      '$sessionsPerWeek sessions / week',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: cs.onSurface.withOpacity(0.55),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.timer_outlined,
                      size: 13,
                      color: cs.onSurface.withOpacity(0.45),
                    ),
                    const SizedBox(width: 3),
                    Text(
                      '$durationMin min',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: cs.onSurface.withOpacity(0.55),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: difficultyColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    difficulty,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: difficultyColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: [
              GestureDetector(
                onTap: onStart,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.12),
                    shape: BoxShape.circle,
                    border: Border.all(color: iconColor.withOpacity(0.30)),
                  ),
                  child: Icon(
                    Icons.play_arrow_rounded,
                    color: iconColor,
                    size: 22,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Start',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: iconColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
