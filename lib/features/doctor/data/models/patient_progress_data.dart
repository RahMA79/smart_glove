import 'progress_point.dart';

class PatientProgressData {
  final List<ProgressPoint> emg; // e.g. µV
  final List<ProgressPoint> flex; // e.g. degrees
  final List<ProgressPoint> pain; // e.g. 0..10

  const PatientProgressData({
    required this.emg,
    required this.flex,
    required this.pain,
  });

  // Demo data (استبدليها ببيانات API)
  factory PatientProgressData.demo() {
    return const PatientProgressData(
      emg: [
        ProgressPoint(1, 12),
        ProgressPoint(2, 18),
        ProgressPoint(3, 14),
        ProgressPoint(4, 16),
        ProgressPoint(5, 22),
        ProgressPoint(6, 19),
        ProgressPoint(7, 17),
        ProgressPoint(8, 15),
        ProgressPoint(9, 16),
        ProgressPoint(10, 14),
      ],
      flex: [
        ProgressPoint(1, 35),
        ProgressPoint(2, 42),
        ProgressPoint(3, 40),
        ProgressPoint(4, 48),
        ProgressPoint(5, 55),
        ProgressPoint(6, 52),
        ProgressPoint(7, 57),
        ProgressPoint(8, 60),
        ProgressPoint(9, 58),
        ProgressPoint(10, 62),
      ],
      pain: [
        ProgressPoint(1, 6),
        ProgressPoint(2, 5.5),
        ProgressPoint(3, 5),
        ProgressPoint(4, 4.8),
        ProgressPoint(5, 4.2),
        ProgressPoint(6, 4),
        ProgressPoint(7, 3.8),
        ProgressPoint(8, 3.5),
        ProgressPoint(9, 3.2),
        ProgressPoint(10, 3),
      ],
    );
  }
}
