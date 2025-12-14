import 'package:flutter/material.dart';
import '../../data/models/doctor_notification_model.dart';

class NotificationTile extends StatelessWidget {
  final DoctorNotificationModel item;
  final VoidCallback? onTap;

  const NotificationTile({super.key, required this.item, this.onTap});

  IconData _iconForType(DoctorNotificationType type) {
    switch (type) {
      case DoctorNotificationType.newPatientRequest:
        return Icons.person_add_alt_1;
      case DoctorNotificationType.programAssigned:
        return Icons.assignment_turned_in;
      case DoctorNotificationType.sessionCompleted:
        return Icons.check_circle_outline;
      case DoctorNotificationType.reportReady:
        return Icons.description_outlined;
      case DoctorNotificationType.message:
        return Icons.mail_outline;
    }
  }

  String _timeLabel(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);

    if (diff.inMinutes < 60) return "${diff.inMinutes} m";
    if (diff.inHours < 24) return "${diff.inHours} h";
    return "${diff.inDays} d";
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;
    final muted = onSurface.withOpacity(0.65);

    final icon = _iconForType(item.type);
    final time = _timeLabel(item.createdAt);

    return Material(
      color: theme.cardColor,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: theme.colorScheme.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: onSurface,
                              fontWeight: item.isRead
                                  ? FontWeight.w600
                                  : FontWeight.w800,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          time,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: muted,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item.subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(color: muted),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.chevron_right, color: muted),
            ],
          ),
        ),
      ),
    );
  }
}
