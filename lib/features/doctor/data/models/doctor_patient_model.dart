class DoctorPatientModel {
  final String name;
  final String condition;
  final int sessionsCount;

  const DoctorPatientModel({
    required this.name,
    required this.condition,
    required this.sessionsCount,
  });

  String get sessionsLabel => "$sessionsCount Sessions";
}
