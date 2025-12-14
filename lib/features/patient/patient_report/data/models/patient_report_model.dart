class PatientReportModel {
  final String conditionTitle;
  final Duration duration;
  final int exercisesDone;
  final int painLevel;
  final double sessionAccuracy; // 0..1
  final double progressRate; // 0..1
  final String patientLevel;

  const PatientReportModel({
    required this.conditionTitle,
    required this.duration,
    required this.exercisesDone,
    required this.painLevel,
    required this.sessionAccuracy,
    required this.progressRate,
    required this.patientLevel,
  });

  String get durationLabel => "${duration.inMinutes}m";
  String get accuracyLabel => "${(sessionAccuracy * 100).round()}%";
  String get progressLabel => "${(progressRate * 100).round()}%";
}
