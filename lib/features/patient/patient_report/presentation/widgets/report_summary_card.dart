import 'package:flutter/material.dart';
import '../../data/models/patient_report_model.dart';
import 'report_info_row.dart';

class ReportSummaryCard extends StatelessWidget {
  final PatientReportModel report;

  const ReportSummaryCard({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(
          0xFFDCEBFF,
        ), // light blue tint (fits primaryBlue mood)
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(report.conditionTitle, style: textTheme.titleMedium),
          const SizedBox(height: 10),
          Divider(height: 1, color: Colors.black.withOpacity(0.08)),
          const SizedBox(height: 10),
          ReportInfoRow(label: "Duration", value: report.durationLabel),
          ReportInfoRow(
            label: "Exercises Done",
            value: "${report.exercisesDone}",
          ),
          ReportInfoRow(label: "Pain Level", value: "${report.painLevel}"),
        ],
      ),
    );
  }
}
