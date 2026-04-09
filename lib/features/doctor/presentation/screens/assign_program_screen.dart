import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';
import 'package:smart_glove/core/utils/size_config.dart';
import 'package:smart_glove/core/widgets/primary_button.dart';
import 'package:smart_glove/features/doctor/data/models/therapy_program_model.dart';
import '../widgets/patient_header_card.dart';
import '../widgets/program_select_card.dart';
import 'package:smart_glove/features/doctor/presentation/screens/create_program_screen.dart';
import 'package:smart_glove/core/localization/app_localizations.dart';
import 'package:smart_glove/supabase_client.dart';

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
  String? _doctorId;

  @override
  void initState() {
    super.initState();
    _doctorId = Supabase.instance.client.auth.currentUser?.id;
  }

  double _toDouble(dynamic v, double fallback) {
    if (v is num) return v.toDouble();
    return fallback;
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    final theme = Theme.of(context);
    final canAssign = _selectedProgramId != null && !_assigning;

    if (_doctorId == null) {
      return Scaffold(
        body: Center(child: Text(context.tr('no_logged_in_doctor'))),
      );
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(context.tr('assign_program')),
        centerTitle: true,
      ),
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
                    context.tr('select_program'),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: _assigning ? null : _openCreateProgram,
                  child: Text(
                    context.tr('create_new'),
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
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: supabase
                    .from('programs')
                    .stream(primaryKey: ['id'])
                    .eq('doctor_id', _doctorId!)
                    .order('created_at', ascending: false),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        context.tr(
                          'error_with_details',
                          params: {'error': '${snapshot.error}'},
                        ),
                      ),
                    );
                  }

                  final docs = snapshot.data ?? [];
                  if (docs.isEmpty) {
                    return Center(child: Text(context.tr('no_programs_yet')));
                  }

                  final programs = docs.map((data) {
                    return TherapyProgramModel(
                      id: data['id'].toString(),
                      name: (data['name'] ?? '').toString(),
                      injuryType:
                          (data['injury_type'] ?? 'Stroke').toString(),
                      sessionDuration:
                          _toDouble(data['session_duration_min'], 30),
                      fingerAngle:
                          _toDouble(data['target_finger_flexion_deg'], 60),
                      motorAssist:
                          _toDouble(data['motor_assistance_percent'], 50),
                      emgThreshold: _toDouble(
                        data['emg_activation_threshold_percent_mvc'],
                        30,
                      ),
                    );
                  }).toList();

                  final stillExists =
                      programs.any((p) => p.id == _selectedProgramId);
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
              text: _assigning
                  ? context.tr('assigning')
                  : context.tr('assign_program_button'),
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
      SnackBar(content: Text(context.tr('program_created_selected'))),
    );
  }

  Future<void> _onAssignPressed() async {
    final programId = _selectedProgramId!;
    final doctorId = _doctorId!;
    setState(() => _assigning = true);

    try {
      // Get old assigned program for this patient
      final patientRow = await supabase
          .from('doctor_patients')
          .select('assigned_program_id')
          .eq('doctor_id', doctorId)
          .eq('patient_id', widget.patientId)
          .maybeSingle();

      final oldProgramId =
          patientRow?['assigned_program_id']?.toString();

      // Decrement old program patients count
      if (oldProgramId != null &&
          oldProgramId.isNotEmpty &&
          oldProgramId != programId) {
        await supabase.rpc('decrement_patients_count', params: {
          'program_id': oldProgramId,
        });
      }

      // Update patient row
      await supabase.from('doctor_patients').upsert({
        'doctor_id': doctorId,
        'patient_id': widget.patientId,
        'name': widget.patientName,
        'condition': widget.condition,
        'assigned_program_id': programId,
        'assigned_at': DateTime.now().toIso8601String(),
      }, onConflict: 'doctor_id,patient_id');

      // Increment new program patients count
      if (oldProgramId != programId) {
        await supabase.rpc('increment_patients_count', params: {
          'program_id': programId,
        });
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.tr('program_assigned_successfully')),
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.tr('failed_to_assign', params: {'error': '$e'}),
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _assigning = false);
    }
  }
}
