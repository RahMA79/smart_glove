import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';
import 'package:smart_glove/core/localization/app_localizations.dart';
import 'package:smart_glove/core/utils/size_config.dart';
import 'package:smart_glove/core/widgets/primary_button.dart';
import 'package:smart_glove/core/widgets/avatar_widget.dart';
import 'package:smart_glove/supabase_client.dart';

class DoctorRequestScreen extends StatefulWidget {
  const DoctorRequestScreen({super.key});
  @override
  State<DoctorRequestScreen> createState() => _DoctorRequestScreenState();
}

class _DoctorRequestScreenState extends State<DoctorRequestScreen> {
  String _query = '';
  String? _selectedDoctorId;
  String? _selectedDoctorName;
  bool _sending = false;

  String? get _patientId =>
      Supabase.instance.client.auth.currentUser?.id;

  Future<Map<String, dynamic>?> _getPatientProfile() async {
    final pid = _patientId;
    if (pid == null) return null;
    return await supabase.from('users').select().eq('id', pid).maybeSingle();
  }

  Future<void> _sendRequest() async {
    final pid = _patientId;
    if (pid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be logged in to send a request.')),
      );
      return;
    }
    if (_selectedDoctorId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a doctor first.')),
      );
      return;
    }

    setState(() => _sending = true);
    try {
      final patient = await _getPatientProfile();
      final patientName = (patient?['name'] ??
              Supabase.instance.client.auth.currentUser?.userMetadata?['name'] ??
              'Patient')
          .toString()
          .trim();
      final condition = (patient?['condition'] ?? '-').toString().trim();
      final patientAvatarUrl = patient?['avatar_url']?.toString();

      final existing = await supabase
          .from('patient_requests')
          .select('id')
          .eq('doctor_id', _selectedDoctorId!)
          .eq('patient_id', pid)
          .maybeSingle();

      if (existing != null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You already sent a request to this doctor.')),
        );
        return;
      }

      final insertData = <String, dynamic>{
        'doctor_id': _selectedDoctorId,
        'patient_id': pid,
        'patient_name': patientName,
        'condition': condition,
        'status': 'pending',
      };
      if (patientAvatarUrl != null) {
        insertData['patient_avatar_url'] = patientAvatarUrl;
      }
      await supabase.from('patient_requests').insert(insertData);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Request sent to $_selectedDoctorName!'),
          backgroundColor: Colors.green.shade600,
        ),
      );
      setState(() {
        _selectedDoctorId = null;
        _selectedDoctorName = null;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send request: $e')),
      );
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('Select Doctor')),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Search
              TextField(
                onChanged: (v) => setState(() => _query = v.trim()),
                decoration: InputDecoration(
                  labelText: context.tr('Search'),
                  hintText: context.tr('Enter doctor name'),
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: theme.cardColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 14),

              Expanded(
                child: StreamBuilder<List<Map<String, dynamic>>>(
                  stream: supabase
                      .from('users')
                      .stream(primaryKey: ['id'])
                      .eq('role', 'doctor'),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }

                    final docs = snapshot.data ?? [];
                    final filtered = docs.where((d) {
                      final name = (d['name'] ?? 'Doctor').toString();
                      if (_query.isEmpty) return true;
                      return name.toLowerCase().contains(_query.toLowerCase());
                    }).toList();

                    if (filtered.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.person_search,
                                size: 48,
                                color: cs.onSurface.withOpacity(0.3)),
                            const SizedBox(height: 12),
                            Text(
                              context.tr('No doctors found.'),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: cs.onSurface.withOpacity(0.5),
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.separated(
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final data = filtered[index];
                        final id = data['id'].toString();
                        final name = (data['name'] ?? 'Doctor').toString();
                        final email = (data['email'] ?? '').toString();
                        final avatarUrl = data['avatar_url']?.toString();
                        final isSelected = _selectedDoctorId == id;

                        return InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: () => setState(() {
                            _selectedDoctorId = id;
                            _selectedDoctorName = name;
                          }),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 12),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? cs.primary.withOpacity(0.08)
                                  : theme.cardColor,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isSelected
                                    ? cs.primary
                                    : cs.outline.withOpacity(0.2),
                                width: isSelected ? 1.5 : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                AvatarWidget(
                                    imageUrl: avatarUrl, name: name, radius: 24),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        name,
                                        style: theme.textTheme.titleSmall
                                            ?.copyWith(
                                                fontWeight: FontWeight.w700),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        email,
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(
                                          color: cs.onSurface.withOpacity(0.55),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (isSelected)
                                  Icon(Icons.check_circle, color: cs.primary),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),

              const SizedBox(height: 12),
              PrimaryButton(
                text: _sending ? 'Sending...' : context.tr('Send Request'),
                onPressed: () { if (!_sending) _sendRequest(); },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
