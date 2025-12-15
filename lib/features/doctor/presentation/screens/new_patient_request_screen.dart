import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:smart_glove/features/doctor/presentation/widgets/drawer_menu.dart';
import '../../data/models/patient_request_model.dart';
import '../widgets/notifications_patient_card.dart';
import '../widgets/patient_request_card.dart';

class NewPatientRequestScreen extends StatefulWidget {
  const NewPatientRequestScreen({super.key});

  @override
  State<NewPatientRequestScreen> createState() =>
      _NewPatientRequestScreenState();
}

class _NewPatientRequestScreenState extends State<NewPatientRequestScreen> {
  // مؤقت لحد FirebaseAuth
  static const String _doctorId = 'vhDs4fPhUjKvJVqVqJImj7';

  Future<void> _accept({
    required String requestId,
    required PatientRequestModel req,
    required String patientIdFromRequest,
  }) async {
    try {
      final db = FirebaseFirestore.instance;

      final patientsCol = db
          .collection('doctors')
          .doc(_doctorId)
          .collection('patients');

      final patientRef = patientIdFromRequest.trim().isEmpty
          ? patientsCol.doc()
          : patientsCol.doc(patientIdFromRequest.trim());

      final requestRef = db
          .collection('doctors')
          .doc(_doctorId)
          .collection('patientRequests')
          .doc(requestId);

      await db.runTransaction((tx) async {
        tx.set(patientRef, {
          'name': req.patientName,
          'condition': req.condition,
          'sessionsCount': 0,
          'createdAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        // ✅ حذف الريكوست بعد القبول (بدون Index)
        tx.delete(requestRef);
      });

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Request accepted")));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed: $e")));
    }
  }

  Future<void> _reject({required String requestId}) async {
    try {
      await FirebaseFirestore.instance
          .collection('doctors')
          .doc(_doctorId)
          .collection('patientRequests')
          .doc(requestId)
          .delete();

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Request rejected")));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      drawer: const DoctorDrawer(),
      appBar: AppBar(
        title: const Text("New Patient Request"),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: StreamBuilder<QuerySnapshot>(
            // ✅ بدون where عشان ما يحتاجش Composite Index
            stream: FirebaseFirestore.instance
                .collection('doctors')
                .doc(_doctorId)
                .collection('patientRequests')
                .orderBy('createdAt', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text("Error: ${snapshot.error}"));
              }

              final allDocs = snapshot.data?.docs ?? [];

              // ✅ فلترة pending في الكود بدل where
              final docs = allDocs.where((d) {
                final data = d.data() as Map<String, dynamic>;
                return (data['status'] ?? '') == 'pending';
              }).toList();

              if (docs.isEmpty) {
                return ListView(
                  children: const [
                    SizedBox(height: 60),
                    Center(child: Text("No new requests.")),
                  ],
                );
              }

              return ListView(
                children: [
                  const SizedBox(height: 8),

                  ...docs.map((d) {
                    final data = d.data() as Map<String, dynamic>;

                    final patientName = (data['patientName'] ?? '')
                        .toString()
                        .trim();
                    final condition = (data['condition'] ?? '')
                        .toString()
                        .trim();
                    final patientIdFromRequest = (data['patientId'] ?? '')
                        .toString();

                    final req = PatientRequestModel(
                      patientName: patientName.isEmpty
                          ? 'Unknown Patient'
                          : patientName,
                      condition: condition.isEmpty ? '-' : condition,
                    );

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: PatientRequestCard(
                        request: req,
                        onAccept: () => _accept(
                          requestId: d.id,
                          req: req,
                          patientIdFromRequest: patientIdFromRequest,
                        ),
                        onReject: () => _reject(requestId: d.id),
                      ),
                    );
                  }),

                  const SizedBox(height: 12),

                  NotificationsPatientCard(
                    title: "Notes",
                    subtitle: "Patient notifications",
                    trailing: "",
                    onTap: () {},
                  ),

                  const SizedBox(height: 22),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
