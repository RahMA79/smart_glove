import 'package:flutter/material.dart';
import '../../data/models/patient_report_model.dart';
import '../widgets/download_button.dart';
import '../widgets/report_expand_row.dart';
import '../widgets/report_summary_card.dart';
import 'package:smart_glove/core/localization/app_localizations.dart';

class PatientReportScreen extends StatelessWidget {
  final PatientReportModel report;

  const PatientReportScreen({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    final bg = colorScheme.surface;
    final dividerColor = colorScheme.onSurface.withOpacity(0.10);
    final mutedText = colorScheme.onSurface.withOpacity(0.70);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(context.tr('patient_report')),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Column(
            children: [
              const SizedBox(height: 10),

              ReportSummaryCard(report: report),

              const SizedBox(height: 18),

              ReportExpandRow(
                title: context.tr('excel_patients'),
                onTap: () {
                  // TODO
                },
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
                    Expanded(
                      child: Text(
                        context.tr('patient_level'),
                        style: textTheme.bodyMedium?.copyWith(color: mutedText),
                      ),
                    ),
                    Text(
                      report.patientLevel,
                      style: textTheme.bodySmall?.copyWith(color: mutedText),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              Padding(
                padding: const EdgeInsets.only(bottom: 18),
                child: DownloadButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(context.tr('downloading')),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: colorScheme.inverseSurface,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
