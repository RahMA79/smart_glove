import 'package:flutter/material.dart';
import 'package:smart_glove/core/localization/app_localizations.dart';

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

  String _timeLabel(BuildContext context, DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    if (diff.inMinutes < 60) {
      final n = diff.inMinutes;
      return isAr ? "$n د" : "$n m";
    }
    if (diff.inHours < 24) {
      final n = diff.inHours;
      return isAr ? "$n س" : "$n h";
    }
    final n = diff.inDays;
    return isAr ? "$n ي" : "$n d";
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;
    final muted = onSurface.withOpacity(0.65);

    final icon = _iconForType(item.type);
    final time = _timeLabel(context, item.createdAt);

    // Treat item.title/subtitle as localization keys (fallback to same string if not found)
    final title = context.tr(item.title);
    final subtitle = context.tr(item.subtitle);

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
                            title,
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
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: muted,
                        height: 1.35,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              if (!item.isRead)
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
