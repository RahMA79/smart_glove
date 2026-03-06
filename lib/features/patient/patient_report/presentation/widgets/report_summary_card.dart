import 'package:flutter/material.dart';
import '../../data/models/patient_report_model.dart';
import 'report_info_row.dart';
import 'package:smart_glove/core/localization/app_localizations.dart';

class ReportSummaryCard extends StatelessWidget {
  final PatientReportModel report;

  const ReportSummaryCard({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            report.conditionTitle,
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 10),
          Divider(height: 1, color: colorScheme.outline.withOpacity(0.20)),
          const SizedBox(height: 10),
          ReportInfoRow(
            label: context.tr('duration'),
            value: report.durationLabel,
          ),
          ReportInfoRow(
            label: context.tr('exercises_done'),
            value: '${report.exercisesDone}',
          ),
          ReportInfoRow(
            label: context.tr('pain_level'),
            value: '${report.painLevel}',
          ),
        ],
      ),
    );
  }
}
