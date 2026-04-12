import 'package:flutter/material.dart';
import 'package:smart_glove/features/patient/presentation/widgets/patient_bottom_nav.dart';
import 'package:smart_glove/features/patient/presentation/screens/patient_home_screen.dart';
import 'package:smart_glove/features/patient/reqestscreen.dart';
import 'package:smart_glove/features/doctor/presentation/screens/settings_screen.dart';
import 'package:smart_glove/supabase_client.dart';
import 'package:smart_glove/core/utils/size_config.dart';
import 'package:smart_glove/core/localization/app_localizations.dart';
import 'package:smart_glove/features/patient/patient_report/data/models/patient_report_model.dart';
import 'package:smart_glove/features/patient/patient_report/presentation/screens/patient_report_screen.dart';

class _SessionEntry {
  final String title;
  final String dateTime;
  final int durationMin;
  final int? accuracy; // null = missed
  final bool missed;

  const _SessionEntry({
    required this.title,
    required this.dateTime,
    required this.durationMin,
    this.accuracy,
    this.missed = false,
  });
}

class SessionHistoryScreen extends StatefulWidget {
  const SessionHistoryScreen({super.key});
  @override
  State<SessionHistoryScreen> createState() => _SessionHistoryScreenState();
}

class _SessionHistoryScreenState extends State<SessionHistoryScreen> {
  final int _navIndex = 1;

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

  static const _sessions = [
    _SessionEntry(
      title: 'Stroke Rehabilitation',
      dateTime: 'Today, 10:30 AM',
      durationMin: 28,
      accuracy: 94,
    ),
    _SessionEntry(
      title: 'Post-Stroke Recovery',
      dateTime: 'Yesterday, 3:00 PM',
      durationMin: 19,
      accuracy: 87,
    ),
    _SessionEntry(
      title: 'Stroke Rehabilitation',
      dateTime: 'Apr 7, 9:00 AM',
      durationMin: 30,
      accuracy: 91,
    ),
    _SessionEntry(
      title: 'Post-Stroke Recovery',
      dateTime: 'Apr 5, 4:00 PM',
      durationMin: 44,
      missed: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    const overallProgress = 0.78;

    return Scaffold(
      appBar: AppBar(title: Text(context.tr('Session History'))),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: SizeConfig.blockWidth * 4,
          vertical: SizeConfig.blockHeight * 2,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Overall progress card ──────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: cs.primary.withOpacity(isDark ? 0.15 : 0.08),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.tr('Overall Progress'),
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: cs.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: overallProgress,
                            minHeight: 10,
                            backgroundColor: cs.primary.withOpacity(0.20),
                            color: cs.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '${(overallProgress * 100).toInt()}%',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: cs.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    context.tr('78% completion rate this month'),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: cs.onSurface.withOpacity(0.55),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: SizeConfig.blockHeight * 3),

            Text(
              context.tr('Recent Sessions'),
              style: theme.textTheme.titleMedium?.copyWith(
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: SizeConfig.blockHeight * 1.5),

            ..._sessions.map(
              (s) => _SessionTile(
                session: s,
                onTap: s.missed
                    ? null
                    : () {
                        final report = PatientReportModel(
                          conditionTitle: s.title,
                          duration: Duration(minutes: s.durationMin),
                          exercisesDone: 5,
                          painLevel: 2,
                          sessionAccuracy: (s.accuracy ?? 0) / 100.0,
                          patientLevel: 'Intermediate',
                          progressRate: overallProgress,
                        );
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PatientReportScreen(report: report),
                          ),
                        );
                      },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: PatientBottomNav(
        currentIndex: _navIndex,
        onTap: (index) {
          if (index == _navIndex) return;
          final uid = supabase.auth.currentUser?.id ?? '';
          if (index == 0) _fadeTo(context, PatientHomeScreen(userId: uid));
          if (index == 2) _fadeTo(context, const DoctorRequestScreen());
          if (index == 3)
            _fadeTo(context, const SettingsScreen(role: 'patient'));
        },
      ),
    );
  }
}

class _SessionTile extends StatelessWidget {
  final _SessionEntry session;
  final VoidCallback? onTap;

  const _SessionTile({required this.session, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final isMissed = session.missed;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: theme.dividerColor.withOpacity(isDark ? 0.15 : 0.08),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.08 : 0.04),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isMissed
                    ? cs.error.withOpacity(0.12)
                    : const Color(0xFF43A047).withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isMissed
                    ? Icons.cancel_outlined
                    : Icons.check_circle_outline_rounded,
                color: isMissed ? cs.error : const Color(0xFF43A047),
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    session.title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        size: 13,
                        color: cs.onSurface.withOpacity(0.45),
                      ),
                      const SizedBox(width: 3),
                      Text(
                        session.dateTime,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: cs.onSurface.withOpacity(0.55),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Icon(
                        Icons.timer_outlined,
                        size: 13,
                        color: cs.onSurface.withOpacity(0.45),
                      ),
                      const SizedBox(width: 3),
                      Text(
                        '${session.durationMin} min',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: cs.onSurface.withOpacity(0.55),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (isMissed)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: cs.error.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: cs.error.withOpacity(0.30)),
                ),
                child: Text(
                  context.tr('Missed'),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: cs.error,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              )
            else
              Row(
                children: [
                  Text(
                    '${session.accuracy}%',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: const Color(0xFF43A047),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: cs.onSurface.withOpacity(0.35),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
