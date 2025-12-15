import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:smart_glove/core/utils/size_config.dart';
import 'package:smart_glove/core/widgets/primary_button.dart';
import 'package:smart_glove/features/doctor/data/models/therapy_program_model.dart';

import '../widgets/patient_header_card.dart';
import '../widgets/program_select_card.dart';
import 'package:smart_glove/features/doctor/presentation/screens/create_program_screen.dart';

class AssignProgramScreen extends StatefulWidget {
  final String patientId;
  final String patientName;
  final String condition;

  const AssignProgramScreen({
    super.key,
    required this.patientId,
    required this.patientName,
    required this.condition,
  });

  @override
  State<AssignProgramScreen> createState() => _AssignProgramScreenState();
}

class _AssignProgramScreenState extends State<AssignProgramScreen> {
  String? _selectedProgramId;
  bool _assigning = false;

  // مؤقت لحد Auth
  static const String _doctorId = 'vhDs4fPhUjKvJVqVqJImj7';

  double _toDouble(dynamic v, double fallback) {
    if (v is num) return v.toDouble();
    return fallback;
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    final theme = Theme.of(context);
    final canAssign = _selectedProgramId != null && !_assigning;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(title: const Text("Assign Program"), centerTitle: true),
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: SizeConfig.blockWidth * 4,
          vertical: SizeConfig.blockHeight * 2,
        ),
        child: Column(
          children: [
            PatientHeaderCard(
              patientName: widget.patientName,
              condition: widget.condition,
            ),
            SizedBox(height: SizeConfig.blockHeight * 2),
            Row(
              children: [
                Expanded(
                  child: Text(
                    "Select a program",
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: _assigning ? null : _openCreateProgram,
                  child: Text(
                    "Create New",
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: SizeConfig.blockHeight * 1.2),

            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('doctors')
                    .doc(_doctorId)
                    .collection('programs')
                    .orderBy('createdAt', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text("Error: ${snapshot.error}"));
                  }

                  final docs = snapshot.data?.docs ?? [];
                  if (docs.isEmpty) {
                    return const Center(child: Text("No programs yet."));
                  }

                  final programs = docs.map((d) {
                    final data = d.data() as Map<String, dynamic>;
                    return TherapyProgramModel(
                      id: d.id,
                      name: (data['name'] ?? '').toString(),
                      injuryType: (data['injuryType'] ?? 'Stroke').toString(),
                      sessionDuration: _toDouble(
                        data['sessionDurationMin'],
                        30,
                      ),
                      fingerAngle: _toDouble(
                        data['targetFingerFlexionDeg'],
                        60,
                      ),
                      motorAssist: _toDouble(
                        data['motorAssistancePercent'],
                        50,
                      ),
                      emgThreshold: _toDouble(
                        data['emgActivationThresholdPercentMvc'],
                        30,
                      ),
                    );
                  }).toList();

                  // ✅ لو البرنامج المختار اتحذف من Firebase، امسح الاختيار
                  final stillExists = programs.any(
                    (p) => p.id == _selectedProgramId,
                  );
                  if (_selectedProgramId != null && !stillExists) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted) setState(() => _selectedProgramId = null);
                    });
                  }

                  return ListView.separated(
                    itemCount: programs.length,
                    separatorBuilder: (_, __) =>
                        SizedBox(height: SizeConfig.blockHeight * 1.6),
                    itemBuilder: (context, i) {
                      final p = programs[i];
                      return ProgramSelectCard(
                        program: p,
                        selected: _selectedProgramId == p.id,
                        onTap: () {
                          setState(() => _selectedProgramId = p.id);
                        },
                      );
                    },
                  );
                },
              ),
            ),

            SizedBox(height: SizeConfig.blockHeight * 2),

            PrimaryButton(
              text: _assigning ? "Assigning..." : "Assign Program",
              onPressed: () {
                if (canAssign) _onAssignPressed();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openCreateProgram() async {
    final TherapyProgramModel? created = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CreateProgramScreen()),
    );

    if (created == null) return;

    setState(() => _selectedProgramId = created.id);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Program created and selected")),
    );
  }

  Future<void> _onAssignPressed() async {
    final programId = _selectedProgramId!;
    final db = FirebaseFirestore.instance;

    final patientRef = db
        .collection('doctors')
        .doc(_doctorId)
        .collection('patients')
        .doc(widget.patientId);

    final newProgramRef = db
        .collection('doctors')
        .doc(_doctorId)
        .collection('programs')
        .doc(programId);

    setState(() => _assigning = true);

    try {
      await db.runTransaction((tx) async {
        // ✅ تأكد إن البرنامج الجديد موجود (عشان update مايفشلش)
        final newProgSnap = await tx.get(newProgramRef);
        if (!newProgSnap.exists) {
          throw Exception(
            "Selected program not found. Please refresh and select an existing program.",
          );
        }

        // اقرأ المريض لمعرفة البرنامج القديم
        final patientSnap = await tx.get(patientRef);

        String? oldProgramId;
        if (patientSnap.exists) {
          final pdata = patientSnap.data() as Map<String, dynamic>;
          oldProgramId = pdata['assignedProgramId']?.toString();
        }

        // لو نفس البرنامج -> لا شيء
        if (oldProgramId == programId) return;

        // ✅ نقص القديم لو موجود (بـ set merge بدل update)
        if (oldProgramId != null && oldProgramId.isNotEmpty) {
          final oldProgramRef = db
              .collection('doctors')
              .doc(_doctorId)
              .collection('programs')
              .doc(oldProgramId);

          final oldSnap = await tx.get(oldProgramRef);
          if (oldSnap.exists) {
            tx.set(oldProgramRef, {
              'patientsCount': FieldValue.increment(-1),
              'updatedAt': FieldValue.serverTimestamp(),
            }, SetOptions(merge: true));
          }
        }

        // حدّث/أنشئ بيانات المريض
        tx.set(patientRef, {
          'name': widget.patientName,
          'condition': widget.condition,
          'assignedProgramId': programId,
          'assignedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        // ✅ زوّد الجديد (بـ set merge بدل update)
        tx.set(newProgramRef, {
          'patientsCount': FieldValue.increment(1),
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Program assigned successfully")),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to assign: $e")));
    } finally {
      if (mounted) setState(() => _assigning = false);
    }
  }
}
