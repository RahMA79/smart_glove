import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';
import 'package:smart_glove/core/utils/size_config.dart';
import 'package:smart_glove/features/doctor/data/models/therapy_program_model.dart';
import 'package:smart_glove/features/doctor/presentation/screens/create_program_screen.dart';
import 'package:smart_glove/features/doctor/presentation/screens/program_config_screen.dart';
import 'package:smart_glove/features/doctor/presentation/widgets/doctor_profile_header.dart';
import 'package:smart_glove/features/doctor/presentation/widgets/drawer_menu.dart';
import 'package:smart_glove/features/doctor/presentation/widgets/program_card.dart';
import 'package:smart_glove/features/doctor/presentation/widgets/doctor_bottom_nav.dart';
import 'package:smart_glove/features/doctor/presentation/widgets/doctor_nav_helper.dart';
import 'package:smart_glove/features/doctor/presentation/screens/new_patient_request_screen.dart';
import 'package:smart_glove/features/doctor/presentation/screens/settings_screen.dart';
import 'package:smart_glove/core/localization/app_localizations.dart';
import 'package:smart_glove/supabase_client.dart';

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
    _doctorId = Supabase.instance.client.auth.currentUser?.id;
  }

  double _toDouble(dynamic v, double fallback) =>
      v is num ? v.toDouble() : fallback;
  int _toInt(dynamic v, int fallback) => v is num ? v.toInt() : fallback;

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CreateProgramScreen()),
        ),
        icon: const Icon(Icons.add),
        label: Text(context.tr('New Protocol')),
        backgroundColor: cs.primary,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: supabase
            .from('programs')
            .stream(primaryKey: ['id'])
            .eq('doctor_id', _doctorId!)
            .order('created_at', ascending: false),
        builder: (context, snapshot) {
          final docs = snapshot.data ?? [];
          final totalPatients = docs.fold<int>(
            0,
            (sum, d) => sum + _toInt(d['patients_count'], 0),
          );
          final activePrograms = docs.length;

          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: SizeConfig.blockWidth * 4,
              vertical: SizeConfig.blockHeight * 2,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const DoctorProfileHeader(),
                SizedBox(height: SizeConfig.blockHeight * 3),

                // ── Stats row ───────────────────────────────────
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        icon: Icons.people_outline_rounded,
                        iconColor: cs.primary,
                        bgColor: cs.primary.withOpacity(0.10),
                        value: '$totalPatients',
                        label: context.tr('Patients'),
                        isDark: isDark,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _StatCard(
                        icon: Icons.list_alt_rounded,
                        iconColor: const Color(0xFF00BFA5),
                        bgColor: const Color(0xFF00BFA5).withOpacity(0.10),
                        value: '$activePrograms',
                        label: context.tr('Protocols'),
                        isDark: isDark,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _StatCard(
                        icon: Icons.play_circle_outline_rounded,
                        iconColor: const Color(0xFF43A047),
                        bgColor: const Color(0xFF43A047).withOpacity(0.10),
                        value: '—',
                        label: context.tr('Active'),
                        isDark: isDark,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: SizeConfig.blockHeight * 3),

                // ── Section header ─────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      context.tr('Therapy Programs'),
                      style: textTheme.titleMedium?.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: SizeConfig.blockHeight * 1.5),

                if (snapshot.connectionState == ConnectionState.waiting)
                  const Center(child: CircularProgressIndicator())
                else if (snapshot.hasError)
                  Text('Error: ${snapshot.error}')
                else if (docs.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 24),
                    child: Center(child: Text(context.tr('no_programs_yet'))),
                  )
                else
                  ...docs.map((data) {
                    final program = TherapyProgramModel(
                      id: data['id'].toString(),
                      name: (data['name'] ?? '').toString(),
                      injuryType: (data['injury_type'] ?? 'Stroke').toString(),
                      sessionDuration: _toDouble(
                        data['session_duration_min'],
                        30,
                      ),
                      fingerAngle: _toDouble(
                        data['target_finger_flexion_deg'],
                        60,
                      ),
                      motorAssist: _toDouble(
                        data['motor_assistance_percent'],
                        50,
                      ),
                      emgThreshold: _toDouble(
                        data['emg_activation_threshold_percent_mvc'],
                        30,
                      ),
                    );
                    return Padding(
                      padding: EdgeInsets.only(
                        bottom: SizeConfig.blockHeight * 1.5,
                      ),
                      child: ProgramCard(
                        title: program.name,
                        patientsCount: _toInt(data['patients_count'], 0),
                        injuryType: program.injuryType,
                        durationMinutes: program.sessionDuration,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ProgramConfigScreen(
                              programId: program.id,
                              programName: program.name,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),

                SizedBox(height: SizeConfig.blockHeight * 10),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: DoctorBottomNav(
        currentIndex: _navIndex,
        onChanged: (index) {
          if (index == _navIndex) return;
          setState(() => _navIndex = index);
          if (index == 1) doctorNavPush(context, const CreateProgramScreen());
          if (index == 2)
            doctorNavPush(context, const NewPatientRequestScreen());
          if (index == 3)
            doctorNavPush(context, const SettingsScreen(role: 'doctor'));
        },
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color bgColor;
  final String value;
  final String label;
  final bool isDark;

  const _StatCard({
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
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
