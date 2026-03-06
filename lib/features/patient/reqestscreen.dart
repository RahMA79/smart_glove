import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:smart_glove/core/localization/app_localizations.dart';
import 'package:smart_glove/core/utils/size_config.dart';
import 'package:smart_glove/core/widgets/primary_button.dart';

class DoctorRequestScreen extends StatefulWidget {
  const DoctorRequestScreen({super.key});

  @override
  State<DoctorRequestScreen> createState() => _DoctorRequestScreenState();
}

class _DoctorRequestScreenState extends State<DoctorRequestScreen> {
  String _query = '';
  String? _selectedDoctorId;
  String? _selectedDoctorName;

  String? get _patientId => FirebaseAuth.instance.currentUser?.uid;

  Future<Map<String, dynamic>?> _getPatientProfile() async {
    final pid = _patientId;
    if (pid == null) return null;
    final snap = await FirebaseFirestore.instance.collection('users').doc(pid).get();
    if (!snap.exists) return null;
    return snap.data();
  }

  Future<void> _sendRequest() async {
    final pid = _patientId;
    if (pid == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tr('Login failed'))),
      );
      return;
    }

    if (_selectedDoctorId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tr('Please select a doctor'))),
      );
      return;
    }

    try {
      final patient = await _getPatientProfile();
      final patientName = (patient?['name'] ?? FirebaseAuth.instance.currentUser?.displayName ?? context.tr('Patient'))
          .toString()
          .trim();
      final condition = (patient?['condition'] ?? '-').toString().trim();

      final reqRef = FirebaseFirestore.instance
          .collection('doctors')
          .doc(_selectedDoctorId)
          .collection('patientRequests')
          .doc(pid);

      final existing = await reqRef.get();
      if (existing.exists) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.tr('Request already sent.'))),
        );
        return;
      }

      await reqRef.set({
        'patientId': pid,
        'patientName': patientName,
        'condition': condition,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.tr(
              'Request sent to {doctor}',
              params: {'doctor': _selectedDoctorName ?? ''},
            ),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.tr('Failed: {error}', params: {'error': '$e'}),
          ),
        ),
      );
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
              TextField(
                onChanged: (v) => setState(() => _query = v.trim()),
                decoration: InputDecoration(
                  labelText: context.tr('Search'),
                  hintText: context.tr('Enter doctor name'),
                  prefixIcon: const Icon(Icons.search),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 14),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .where('role', isEqualTo: 'doctor')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          context.tr(
                            'Failed: {error}',
                            params: {'error': '${snapshot.error}'},
                          ),
                        ),
                      );
                    }

                    final docs = snapshot.data?.docs ?? [];
                    final filtered = docs.where((d) {
                      final data = d.data() as Map<String, dynamic>;
                      final name = (data['name'] ?? 'Doctor').toString();
                      if (_query.isEmpty) return true;
                      return name.toLowerCase().contains(_query.toLowerCase());
                    }).toList();

                    if (filtered.isEmpty) {
                      return Center(child: Text(context.tr('No doctors found.')));
                    }

                    return ListView.separated(
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final doc = filtered[index];
                        final data = doc.data() as Map<String, dynamic>;
                        final name = (data['name'] ?? 'Doctor').toString();
                        final email = (data['email'] ?? '').toString();
                        final isSelected = _selectedDoctorId == doc.id;

                        return InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: () {
                            setState(() {
                              _selectedDoctorId = doc.id;
                              _selectedDoctorName = name;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: theme.cardColor,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isSelected
                                    ? cs.primary
                                    : cs.outlineVariant.withOpacity(0.4),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.06),
                                  blurRadius: 12,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 22,
                                  backgroundColor: cs.primary
                                      .withOpacity(isSelected ? 0.18 : 0.10),
                                  child: Icon(
                                    Icons.person,
                                    color: cs.primary,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        name,
                                        style: theme.textTheme.titleMedium
                                            ?.copyWith(fontWeight: FontWeight.w800),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        email,
                                        style: theme.textTheme.bodySmall?.copyWith(
                                          color: cs.onSurface.withOpacity(0.65),
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
                text: context.tr('Send Request'),
                onPressed: _sendRequest,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
