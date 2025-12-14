class PatientRequestModel {
  final String patientName;
  final String condition; // e.g. Stroke

  const PatientRequestModel({
    required this.patientName,
    required this.condition,
  });
}
