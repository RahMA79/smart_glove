import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';
import 'package:smart_glove/core/widgets/avatar_widget.dart';
import 'package:smart_glove/features/doctor/presentation/screens/patient_overview_screen.dart';
import 'package:smart_glove/features/doctor/presentation/widgets/drawer_menu.dart';
import 'package:smart_glove/core/localization/app_localizations.dart';
import 'package:smart_glove/supabase_client.dart';

class MyPatientsScreen extends StatefulWidget {
  const MyPatientsScreen({super.key});

  @override
  State<MyPatientsScreen> createState() => _MyPatientsScreenState();
}

class _MyPatientsScreenState extends State<MyPatientsScreen> {
  String? _doctorId;

  @override
  void initState() {
    super.initState();
    _doctorId = Supabase.instance.client.auth.currentUser?.id;
  }

  int _toInt(dynamic v, int fallback) {
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v) ?? fallback;
    return fallback;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    if (_doctorId == null) {
      return Scaffold(
        body: Center(child: Text(context.tr('no_logged_in_doctor'))),
      );
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      drawer: const DoctorDrawer(),
      appBar: AppBar(title: Text(context.tr('my_patients')), centerTitle: true),
      body: SafeArea(
        child: StreamBuilder<List<Map<String, dynamic>>>(
          stream: supabase
              .from('doctor_patients')
              .stream(primaryKey: ['id'])
              .eq('doctor_id', _doctorId!)
              .order('created_at', ascending: false),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            final docs = snapshot.data ?? [];
            if (docs.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.people_outline,
                      size: 64,
                      color: cs.onSurface.withOpacity(0.3),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No patients yet.',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: cs.onSurface.withOpacity(0.55),
                      ),
                    ),
                  ],
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: docs.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final data = docs[index];
                final patientId = data['patient_id']?.toString() ?? '';
                final name = (data['name'] ?? '').toString();
                final condition = (data['condition'] ?? '').toString();
                final sessionsCount = _toInt(data['sessions_count'], 0);
                final avatarUrl = data['avatar_url']?.toString();

                return _PatientListTile(
                  patientId: patientId,
                  name: name,
                  condition: condition,
                  sessionsCount: sessionsCount,
                  avatarUrl: avatarUrl,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PatientOverviewScreen(
                        patientId: patientId,
                        patientName: name,
                        condition: condition,
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _PatientListTile extends StatelessWidget {
  final String patientId;
  final String name;
  final String condition;
  final int sessionsCount;
  final String? avatarUrl;
  final VoidCallback onTap;

  const _PatientListTile({
    required this.patientId,
    required this.name,
    required this.condition,
    required this.sessionsCount,
    this.avatarUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: cs.outline.withOpacity(0.15)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        onTap: onTap,
        leading: AvatarWidget(imageUrl: avatarUrl, name: name, radius: 24),
        title: Text(
          name,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        subtitle: condition.isNotEmpty
            ? Text(
                condition,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: cs.onSurface.withOpacity(0.55),
                ),
              )
            : null,
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$sessionsCount',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: cs.primary,
              ),
            ),
            Text(
              'sessions',
              style: theme.textTheme.bodySmall?.copyWith(
                color: cs.onSurface.withOpacity(0.5),
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
