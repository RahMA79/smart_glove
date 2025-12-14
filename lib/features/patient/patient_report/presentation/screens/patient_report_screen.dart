import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../data/models/patient_report_model.dart';
import '../widgets/download_button.dart';
import '../widgets/report_expand_row.dart';
import '../widgets/report_summary_card.dart';

class PatientReportScreen extends StatelessWidget {
  final PatientReportModel report;

  const PatientReportScreen({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.background, // matches your AppColors
      appBar: AppBar(
        title: const Text("Patient Report"),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            // TODO: open drawer/menu
          },
        ),
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
                title: "Excel Patients",
                onTap: () {
                  // TODO
                },
              ),
              Divider(height: 1, color: Colors.black.withOpacity(0.08)),

              ReportExpandRow(
                title: "session Accuracy",
                trailingText: report.accuracyLabel,
                onTap: () {},
              ),
              Divider(height: 1, color: Colors.black.withOpacity(0.08)),

              ReportExpandRow(
                title: "progress rate",
                trailingText: report.progressLabel,
                onTap: () {},
              ),
              Divider(height: 1, color: Colors.black.withOpacity(0.08)),

              Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Row(
                  children: [
                    Expanded(
                      child: Text("patient Level", style: textTheme.bodyMedium),
                    ),
                    Text(report.patientLevel, style: textTheme.bodySmall),
                  ],
                ),
              ),

              const Spacer(),

              Padding(
                padding: const EdgeInsets.only(bottom: 18),
                child: DownloadButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Downloading...")),
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
