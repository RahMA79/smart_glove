class TherapyProgramModel {
  final String id;
  final String name;
  final String injuryType;

  final double sessionDuration; // minutes
  final double fingerAngle; // degrees
  final double motorAssist; // %
  final double emgThreshold; // %MVC

  const TherapyProgramModel({
    required this.id,
    required this.name,
    required this.injuryType,
    required this.sessionDuration,
    required this.fingerAngle,
    required this.motorAssist,
    required this.emgThreshold,
  });

  String get subtitle =>
      "$injuryType • ${sessionDuration.round()} min • ${motorAssist.round()}% assist";
}
