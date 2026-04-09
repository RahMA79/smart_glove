import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';
import 'package:smart_glove/core/widgets/avatar_widget.dart';
import 'package:smart_glove/features/doctor/presentation/widgets/drawer_menu.dart';
import '../../data/models/patient_request_model.dart';
import 'package:smart_glove/core/localization/app_localizations.dart';
import 'package:smart_glove/features/doctor/presentation/widgets/doctor_bottom_nav.dart';
import 'doctor_home_screen.dart';
import 'create_program_screen.dart';
import 'settings_screen.dart';
import 'patient_details_screen.dart';
import 'package:smart_glove/supabase_client.dart';

class NewPatientRequestScreen extends StatefulWidget {
  const NewPatientRequestScreen({super.key});
  @override
  State<NewPatientRequestScreen> createState() =>
      _NewPatientRequestScreenState();
}

class _NewPatientRequestScreenState extends State<NewPatientRequestScreen> {
  String? _doctorId;
  int _navIndex = 2;

  @override
  void initState() {
    super.initState();
    _doctorId = Supabase.instance.client.auth.currentUser?.id;
  }

  Future<void> _accept({
    required String requestId,
    required PatientRequestModel req,
    required String patientId,
  }) async {
    try {
      if (_doctorId == null) return;
      await supabase.from('doctor_patients').upsert({
        'doctor_id': _doctorId,
        'patient_id': patientId,
        'name': req.patientName,
        'condition': req.condition,
        'sessions_count': 0,
      }, onConflict: 'doctor_id,patient_id');

      await supabase.from('patient_requests').delete().eq('id', requestId);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Request accepted successfully!'),
          backgroundColor: Colors.green.shade600,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to accept: $e')),
      );
    }
  }

  Future<void> _reject({required String requestId}) async {
    try {
      if (_doctorId == null) return;
      await supabase.from('patient_requests').delete().eq('id', requestId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Request rejected.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (_doctorId == null) {
      return Scaffold(
        body: Center(child: Text(context.tr('No logged-in doctor. Please login again.'))),
      );
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      drawer: const DoctorDrawer(),
      appBar: AppBar(
        title: Text(context.tr('New Patient Request')),
        centerTitle: true,
      ),
      body: SafeArea(
        child: StreamBuilder<List<Map<String, dynamic>>>(
          stream: supabase
              .from('patient_requests')
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

            final allDocs = snapshot.data ?? [];
            final docs = allDocs
                .where((d) => (d['status'] ?? '') == 'pending')
                .toList();

            if (docs.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.inbox_outlined,
                        size: 64,
                        color: theme.colorScheme.onSurface.withOpacity(0.3)),
                    const SizedBox(height: 16),
                    Text(
                      context.tr('No new requests.'),
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: docs.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final data = docs[index];
                final patientName =
                    (data['patient_name'] ?? '').toString().trim();
                final condition = (data['condition'] ?? '').toString().trim();
                final patientId = (data['patient_id'] ?? '').toString();
                final requestId = data['id'].toString();
                final avatarUrl = data['patient_avatar_url']?.toString();

                final req = PatientRequestModel(
                  patientName: patientName.isEmpty ? 'Unknown Patient' : patientName,
                  condition: condition.isEmpty ? '-' : condition,
                );

                return _RequestCard(
                  req: req,
                  avatarUrl: avatarUrl,
                  patientId: patientId,
                  onAccept: () => _accept(
                    requestId: requestId,
                    req: req,
                    patientId: patientId,
                  ),
                  onReject: () => _reject(requestId: requestId),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PatientDetailsScreen(
                        patientId: patientId,
                        patientName: req.patientName,
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
      bottomNavigationBar: DoctorBottomNav(
        currentIndex: _navIndex,
        onChanged: (index) {
          if (index == _navIndex) return;
          setState(() => _navIndex = index);
          if (index == 0) Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (_) => const DoctorHomeScreen()));
          if (index == 1) Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (_) => const CreateProgramScreen()));
          if (index == 3) Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()));
        },
      ),
    );
  }
}

// ── Request Card ────────────────────────────────────────────────────────────
class _RequestCard extends StatelessWidget {
  final PatientRequestModel req;
  final String? avatarUrl;
  final String patientId;
  final VoidCallback onAccept;
  final VoidCallback onReject;
  final VoidCallback onTap;

  const _RequestCard({
    required this.req,
    this.avatarUrl,
    required this.patientId,
    required this.onAccept,
    required this.onReject,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: cs.outline.withOpacity(0.15)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  AvatarWidget(
                    imageUrl: avatarUrl,
                    name: req.patientName,
                    radius: 26,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: onTap,
                          child: Text(
                            req.patientName,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: cs.primary,
                            ),
                          ),
                        ),
                        if (req.condition.isNotEmpty && req.condition != '-')
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(
                              req.condition,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: cs.onSurface.withOpacity(0.6),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right,
                      color: cs.onSurface.withOpacity(0.35)),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onAccept,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: cs.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      child: const Text(
                        'Accept',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onReject,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: cs.error,
                        side: BorderSide(color: cs.error.withOpacity(0.5)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      child: const Text(
                        'Reject',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
