enum DoctorNotificationType {
  newPatientRequest,
  programAssigned,
  sessionCompleted,
  reportReady,
  message,
}

class DoctorNotificationModel {
  final String id;
  final DoctorNotificationType type;
  final String title;
  final String subtitle;
  final DateTime createdAt;
  final bool isRead;

  const DoctorNotificationModel({
    required this.id,
    required this.type,
    required this.title,
    required this.subtitle,
    required this.createdAt,
    this.isRead = false,
  });
}
