import 'package:flutter/material.dart';
import '../../data/models/patient_progress_data.dart';
import '../widgets/progress_line_chart_card.dart';
import '../widgets/progress_tab_switcher.dart';

class PatientProgressScreen extends StatefulWidget {
  final String patientName;

  const PatientProgressScreen({super.key, required this.patientName});

  @override
  State<PatientProgressScreen> createState() => _PatientProgressScreenState();
}

class _PatientProgressScreenState extends State<PatientProgressScreen> {
  int _tabIndex = 0; // 0 EMG, 1 Flex
  late final PatientProgressData _data =
      PatientProgressData.demo(); // TODO: from API

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final chartTitle = _tabIndex == 0 ? "EMG Data" : "Flex Angles";
    final chartUnit = _tabIndex == 0 ? "µV" : "°";
    final chartPoints = _tabIndex == 0 ? _data.emg : _data.flex;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(title: Text(widget.patientName), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            ProgressTabSwitcher(
              index: _tabIndex,
              onChanged: (i) => setState(() => _tabIndex = i),
            ),
            const SizedBox(height: 18),
            Expanded(
              child: ListView(
                children: [
                  ProgressLineChartCard(
                    title: chartTitle,
                    unit: chartUnit,
                    points: chartPoints,
                  ),
                  const SizedBox(height: 16),
                  ProgressLineChartCard(
                    title: "Pain Angles",
                    unit: "",
                    points: _data.pain,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
