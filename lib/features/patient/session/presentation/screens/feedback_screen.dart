import 'package:flutter/material.dart';
import 'package:smart_glove/core/utils/size_config.dart';
import 'package:smart_glove/core/localization/app_localizations.dart';
import 'package:smart_glove/features/patient/patient_report/data/models/patient_report_model.dart';
import 'package:smart_glove/features/patient/patient_report/presentation/screens/patient_report_screen.dart';

class FeedbackScreen extends StatefulWidget {
  final String sessionTitle;
  final int exercisesCount;
  final int durationSeconds;

  const FeedbackScreen({
    super.key,
    required this.sessionTitle,
    this.exercisesCount = 5,
    this.durationSeconds = 60,
  });

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  int _painRating = 0;
  int _easeRating = 0;
  int _effortRating = 0;
  final TextEditingController _notesCtrl = TextEditingController();

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  String _formatDuration(int seconds) {
    if (seconds < 60) return '${seconds}s';
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return s == 0 ? '${m}m' : '${m}m ${s}s';
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final sessionAccuracy = 1.0;

    return Scaffold(
      appBar: AppBar(title: Text(context.tr('Feedback'))),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: SizeConfig.blockWidth * 5,
          vertical: SizeConfig.blockHeight * 2,
        ),
        child: Column(
          children: [
            // ── Header ─────────────────────────────────────────
            Text(context.tr('Session Complete!'),
                style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900)),
            const SizedBox(height: 4),
            Text(widget.sessionTitle,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: cs.onSurface.withOpacity(0.65))),

            SizedBox(height: SizeConfig.blockHeight * 2),

            // ── Stats row ──────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
              decoration: BoxDecoration(
                color: cs.primary.withOpacity(isDark ? 0.12 : 0.07),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _StatChip(icon: Icons.check_circle_outline_rounded,
                      value: '${widget.exercisesCount}/${widget.exercisesCount}',
                      label: context.tr('Exercises'), color: cs.primary),
                  _StatChip(icon: Icons.timer_outlined,
                      value: _formatDuration(widget.durationSeconds),
                      label: context.tr('Time taken'), color: cs.primary),
                  _StatChip(icon: Icons.percent_rounded,
                      value: '${(sessionAccuracy * 100).toInt()}%',
                      label: context.tr('Session Accuracy'), color: cs.primary),
                ],
              ),
            ),

            SizedBox(height: SizeConfig.blockHeight * 2),

            // ── Ratings card ───────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: theme.dividerColor.withOpacity(isDark ? 0.18 : 0.10)),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? 0.10 : 0.04),
                    blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: Column(
                children: [
                  _RatingRow(
                    label: context.tr('How was your pain level?'),
                    value: _painRating,
                    activeColor: cs.error,
                    onSelect: (v) => setState(() => _painRating = v),
                  ),
                  const SizedBox(height: 14),
                  _RatingRow(
                    label: context.tr('How easy was the session?'),
                    value: _easeRating,
                    activeColor: const Color(0xFFFFB300),
                    onSelect: (v) => setState(() => _easeRating = v),
                  ),
                  const SizedBox(height: 14),
                  _RatingRow(
                    label: context.tr('How much effort did you put in?'),
                    value: _effortRating,
                    activeColor: const Color(0xFF43A047),
                    onSelect: (v) => setState(() => _effortRating = v),
                  ),
                ],
              ),
            ),

            SizedBox(height: SizeConfig.blockHeight * 2),

            // ── Notes ──────────────────────────────────────────
            Align(
              alignment: Alignment.centerLeft,
              child: Text(context.tr('Notes'),
                  style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _notesCtrl,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: context.tr('Any notes for your doctor...'),
                filled: true,
                fillColor: theme.cardColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: theme.dividerColor.withOpacity(0.20)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: theme.dividerColor.withOpacity(0.20)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: cs.primary),
                ),
              ),
            ),

            SizedBox(height: SizeConfig.blockHeight * 3),

            // ── View Report button ─────────────────────────────
            SizedBox(
              width: double.infinity, height: 52,
              child: ElevatedButton(
                onPressed: () {
                  final report = PatientReportModel(
                    conditionTitle: widget.sessionTitle,
                    duration: Duration(seconds: widget.durationSeconds),
                    exercisesDone: widget.exercisesCount,
                    painLevel: _painRating,
                    sessionAccuracy: sessionAccuracy,
                    patientLevel: 'Intermediate',
                    progressRate: 0.78,
                  );
                  Navigator.pushReplacement(context, MaterialPageRoute(
                    builder: (_) => PatientReportScreen(report: report),
                  ));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: cs.primary, foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: Text(context.tr('View Report'),
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              ),
            ),
            SizedBox(height: SizeConfig.blockHeight * 2),
          ],
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  const _StatChip({required this.icon, required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(height: 4),
        Text(value, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800, color: color)),
        Text(label, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.55))),
      ],
    );
  }
}

class _RatingRow extends StatelessWidget {
  final String label;
  final int value;
  final Color activeColor;
  final ValueChanged<int> onSelect;
  const _RatingRow({required this.label, required this.value, required this.activeColor, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(label, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (i) {
            final idx = i + 1;
            return GestureDetector(
              onTap: () => onSelect(idx),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Icon(
                  idx <= value ? Icons.star_rounded : Icons.star_border_rounded,
                  color: idx <= value ? activeColor : theme.colorScheme.onSurface.withOpacity(0.25),
                  size: 30,
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}
