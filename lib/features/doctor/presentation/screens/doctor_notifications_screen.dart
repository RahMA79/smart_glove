import 'package:flutter/material.dart';
import 'package:smart_glove/core/utils/size_config.dart';
import '../../data/models/doctor_notification_model.dart';
import '../widgets/notification_filter_tabs.dart';
import '../widgets/notification_tile.dart';

class DoctorNotificationsScreen extends StatefulWidget {
  const DoctorNotificationsScreen({super.key});

  @override
  State<DoctorNotificationsScreen> createState() =>
      _DoctorNotificationsScreenState();
}

class _DoctorNotificationsScreenState extends State<DoctorNotificationsScreen> {
  int _filterIndex = 0; // 0 all, 1 unread

  // TODO: replace with API
  final List<DoctorNotificationModel> _all = [
    DoctorNotificationModel(
      id: "n1",
      type: DoctorNotificationType.newPatientRequest,
      title: "New Patient Request",
      subtitle: "John Smith requested to join your care program.",
      createdAt: DateTime.now().subtract(const Duration(minutes: 3)),
      isRead: false,
    ),
    DoctorNotificationModel(
      id: "n2",
      type: DoctorNotificationType.reportReady,
      title: "Report Ready",
      subtitle: "Emily Wilson session report is ready to download.",
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      isRead: true,
    ),
    DoctorNotificationModel(
      id: "n3",
      type: DoctorNotificationType.sessionCompleted,
      title: "Session Completed",
      subtitle: "Mark Smith completed today’s therapy session.",
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      isRead: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    final theme = Theme.of(context);

    final list = _filterIndex == 0
        ? _all
        : _all.where((n) => !n.isRead).toList();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Notifications"),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: () {
              // mark all as read (local)
              setState(() {
                for (var i = 0; i < _all.length; i++) {
                  _all[i] = DoctorNotificationModel(
                    id: _all[i].id,
                    type: _all[i].type,
                    title: _all[i].title,
                    subtitle: _all[i].subtitle,
                    createdAt: _all[i].createdAt,
                    isRead: true,
                  );
                }
              });
            },
            child: Text(
              "Mark all",
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: SizeConfig.blockWidth * 4,
          vertical: SizeConfig.blockHeight * 2,
        ),
        child: Column(
          children: [
            NotificationFilterTabs(
              index: _filterIndex,
              onChanged: (i) => setState(() => _filterIndex = i),
            ),
            SizedBox(height: SizeConfig.blockHeight * 2),

            Expanded(
              child: list.isEmpty
                  ? _EmptyState()
                  : ListView.separated(
                      itemCount: list.length,
                      separatorBuilder: (_, __) =>
                          SizedBox(height: SizeConfig.blockHeight * 1.4),
                      itemBuilder: (context, i) {
                        final item = list[i];
                        return NotificationTile(
                          item: item,
                          onTap: () {
                            // TODO: route by type
                            // newPatientRequest -> NewPatientRequestScreen
                            // reportReady -> PatientReportScreen
                            // message -> chat screen
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;
    final muted = onSurface.withOpacity(0.65);

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.notifications_none, size: 46, color: muted),
          const SizedBox(height: 10),
          Text(
            "No notifications",
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: onSurface,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "You're all caught up.",
            style: theme.textTheme.bodySmall?.copyWith(color: muted),
          ),
        ],
      ),
    );
  }
}
