import 'package:flutter/material.dart';
import '../../data/models/patient_report_model.dart';
import '../widgets/download_button.dart';
import '../widgets/report_expand_row.dart';
import '../widgets/report_summary_card.dart';
import 'package:smart_glove/core/localization/app_localizations.dart';
import 'package:smart_glove/features/patient/presentation/screens/patient_home_screen.dart';
import 'package:smart_glove/supabase_client.dart';

class PatientReportScreen extends StatelessWidget {
  final PatientReportModel report;

  const PatientReportScreen({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final bg = colorScheme.surface;
    final dividerColor = colorScheme.onSurface.withOpacity(0.10);
    final mutedText = colorScheme.onSurface.withOpacity(0.70);

    final userId = supabase.auth.currentUser?.id ?? '';

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(context.tr('patient_report')),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Column(
            children: [
              const SizedBox(height: 10),

              ReportSummaryCard(report: report),
              const SizedBox(height: 18),

              // ── Expandable rows ─────────────────────────────
              ReportExpandRow(
                title: context.tr('excel_patients'),
                onTap: () {},
              ),
              Divider(height: 1, color: dividerColor),

              ReportExpandRow(
                title: context.tr('session_accuracy'),
                trailingText: report.accuracyLabel,
                onTap: () {},
              ),
              Divider(height: 1, color: dividerColor),

              ReportExpandRow(
                title: context.tr('progress_rate'),
                trailingText: report.progressLabel,
                onTap: () {},
              ),
              Divider(height: 1, color: dividerColor),

              Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Row(
                  children: [
                    Expanded(child: Text(context.tr('patient_level'),
                        style: textTheme.bodyMedium?.copyWith(color: mutedText))),
                    Text(report.patientLevel,
                        style: textTheme.bodySmall?.copyWith(color: mutedText)),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ── Report sent notice ──────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withOpacity(isDark ? 0.12 : 0.07),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: colorScheme.primary.withOpacity(0.20)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 34, height: 34,
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.add_box_outlined, color: colorScheme.primary, size: 18),
                    ),
                    const SizedBox(width: 12),
                    Text(context.tr('Report sent to your doctor'),
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.primary, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // ── Download button ─────────────────────────────
              DownloadButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(context.tr('downloading')),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: colorScheme.inverseSurface,
                  ));
                },
              ),

              const SizedBox(height: 12),

              // ── Back to Home ────────────────────────────────
              SizedBox(
                width: double.infinity, height: 50,
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => PatientHomeScreen(userId: userId)),
                    (r) => false,
                  ),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    side: BorderSide(color: colorScheme.outline.withOpacity(0.40)),
                  ),
                  child: Text(context.tr('Back to Home'),
                      style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700)),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
