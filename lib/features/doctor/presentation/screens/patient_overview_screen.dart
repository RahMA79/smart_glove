import 'package:flutter/material.dart';
import 'package:smart_glove/features/doctor/presentation/screens/assign_program_screen.dart';
import 'package:smart_glove/features/doctor/presentation/screens/patient_progress_screen.dart';
import 'package:smart_glove/features/doctor/presentation/screens/patient_details_screen.dart';
import 'package:smart_glove/features/doctor/presentation/widgets/patient_action_card.dart';
import 'package:smart_glove/core/widgets/avatar_widget.dart';
import 'package:smart_glove/supabase_client.dart';

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
  String? _avatarUrl;

  @override
  void initState() {
    super.initState();
    _loadAvatar();
  }

  Future<void> _loadAvatar() async {
    final data = await supabase
        .from('users')
        .select('avatar_url')
        .eq('id', widget.patientId)
        .maybeSingle();
    if (!mounted) return;
    setState(() => _avatarUrl = data?['avatar_url']?.toString());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final isArabic = locale == 'ar';
    final cs = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(title: Text(widget.patientName), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            // Patient header
            Row(
              children: [
                AvatarWidget(
                  imageUrl: _avatarUrl,
                  name: widget.patientName,
                  radius: 32,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.patientName,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (widget.condition.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            widget.condition,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: cs.onSurface.withOpacity(0.55),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            PatientActionCard(
              icon: Icons.person_outline,
              title: isArabic ? 'عرض تفاصيل المريض' : 'View Patient Details',
              subtitle: isArabic
                  ? 'الملف الشخصي والسجل الطبي'
                  : 'Profile, age & medical record',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PatientDetailsScreen(
                    patientId: widget.patientId,
                    patientName: widget.patientName,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            PatientActionCard(
              icon: Icons.assignment_turned_in_outlined,
              title: isArabic ? 'تعيين برنامج علاجي' : 'Assign Therapy Program',
              subtitle: isArabic
                  ? 'إنشاء أو تعيين برنامج لهذا المريض'
                  : 'Create or assign a program for this patient',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AssignProgramScreen(
                    patientId: widget.patientId,
                    patientName: widget.patientName,
                    condition: widget.condition,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            PatientActionCard(
              icon: Icons.show_chart,
              title: isArabic ? 'عرض التقدم' : 'View Progress',
              subtitle: isArabic
                  ? 'بيانات EMG، زوايا الأصابع والتقدم'
                  : 'EMG data, finger angles & progress',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      PatientProgressScreen(patientName: widget.patientName),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
