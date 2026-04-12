import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';
import 'package:smart_glove/core/utils/size_config.dart';
import 'package:smart_glove/core/widgets/app_text_field.dart';
import 'package:smart_glove/core/widgets/primary_button.dart';
import 'package:smart_glove/core/localization/app_localizations.dart';
import 'package:smart_glove/features/doctor/presentation/widgets/doctor_bottom_nav.dart';
import 'package:smart_glove/features/doctor/presentation/widgets/doctor_nav_helper.dart';
import 'doctor_home_screen.dart';
import 'new_patient_request_screen.dart';
import 'settings_screen.dart';
import '../widgets/labeled_slider.dart';
import 'package:smart_glove/features/doctor/data/models/therapy_program_model.dart';
import 'package:smart_glove/supabase_client.dart';

class _Exercise {
  String name;
  int reps;
  int sets;
  int restSeconds;
  _Exercise({
    required this.name,
    this.reps = 10,
    this.sets = 3,
    this.restSeconds = 15,
  });
}

class CreateProgramScreen extends StatefulWidget {
  const CreateProgramScreen({super.key});
  @override
  State<CreateProgramScreen> createState() => _CreateProgramScreenState();
}

class _CreateProgramScreenState extends State<CreateProgramScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _programNameController = TextEditingController();
  String? _selectedInjuryType = 'Stroke';

  double _sessionDuration = 30;
  double _fingerAngle = 60;
  double _motorAssist = 50;
  double _emgThreshold = 30;

  bool _saving = false;
  String? _doctorId;
  int _navIndex = 1;
  late TabController _tabController;

  final List<_Exercise> _exercises = [
    _Exercise(name: 'Finger Flexion', reps: 10, sets: 3, restSeconds: 15),
  ];

  @override
  void initState() {
    super.initState();
    _doctorId = Supabase.instance.client.auth.currentUser?.id;
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _programNameController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _addExercise() async {
    final result = await showDialog<_Exercise>(
      context: context,
      builder: (ctx) => _AddExerciseDialog(),
    );
    if (result != null) {
      setState(() => _exercises.add(result));
    }
  }

  void _editExercise(int index) async {
    final result = await showDialog<_Exercise>(
      context: context,
      builder: (ctx) => _AddExerciseDialog(existing: _exercises[index]),
    );
    if (result != null) {
      setState(() => _exercises[index] = result);
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final cs = theme.colorScheme;

    if (_doctorId == null) {
      return Scaffold(
        body: Center(child: Text(context.tr('no_logged_in_doctor'))),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('create_program')),
        leading: BackButton(
          onPressed: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) {
                return const DoctorHomeScreen();
              },
            ),
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: cs.primary,
          labelColor: cs.primary,
          unselectedLabelColor: cs.onSurface.withOpacity(0.55),
          tabs: [
            Tab(text: context.tr('Session Settings')),
            Tab(text: context.tr('Exercises')),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // ── Tab 1: Session Settings ──────────────────────────
          SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: SizeConfig.blockWidth * 4,
              vertical: SizeConfig.blockHeight * 2,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppTextField(
                  label: context.tr('program_name'),
                  hint: context.tr('enter_program_name'),
                  controller: _programNameController,
                ),
                SizedBox(height: SizeConfig.blockHeight * 2),
                Text(
                  context.tr('type_of_injury'),
                  style: textTheme.titleMedium?.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _selectedInjuryType,
                  items: [
                    DropdownMenuItem(
                      value: 'Stroke',
                      child: Text(context.tr('injury_stroke')),
                    ),
                    DropdownMenuItem(
                      value: 'Tendon Repair',
                      child: Text(context.tr('injury_tendon_repair')),
                    ),
                    DropdownMenuItem(
                      value: 'Burn',
                      child: Text(context.tr('injury_burn')),
                    ),
                    DropdownMenuItem(
                      value: 'Nerve Injury',
                      child: Text(context.tr('injury_nerve_injury')),
                    ),
                  ],
                  onChanged: _saving
                      ? null
                      : (v) => setState(() => _selectedInjuryType = v),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: theme.cardColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  dropdownColor: theme.cardColor,
                  style: textTheme.bodyMedium,
                ),
                SizedBox(height: SizeConfig.blockHeight * 3),
                Text(
                  context.tr('session_settings'),
                  style: textTheme.titleMedium?.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: SizeConfig.blockHeight * 1.5),
                LabeledSlider(
                  title: context.tr('session_duration'),
                  value: _sessionDuration,
                  min: 10,
                  max: 60,
                  divisions: 5,
                  unit: context.tr('minutes_unit'),
                  onChanged: _saving
                      ? (_) {}
                      : (v) => setState(() => _sessionDuration = v),
                ),
                SizedBox(height: SizeConfig.blockHeight * 2),
                Text(
                  context.tr('finger_angles_and_assistance'),
                  style: textTheme.titleMedium?.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: SizeConfig.blockHeight * 1.5),
                LabeledSlider(
                  title: context.tr('target_finger_flexion'),
                  value: _fingerAngle,
                  min: 0,
                  max: 90,
                  divisions: 9,
                  unit: context.tr('degree_unit'),
                  onChanged: _saving
                      ? (_) {}
                      : (v) => setState(() => _fingerAngle = v),
                ),
                SizedBox(height: SizeConfig.blockHeight * 1.5),
                LabeledSlider(
                  title: context.tr('motor_assistance_level'),
                  value: _motorAssist,
                  min: 0,
                  max: 100,
                  divisions: 10,
                  unit: '%',
                  onChanged: _saving
                      ? (_) {}
                      : (v) => setState(() => _motorAssist = v),
                ),
                SizedBox(height: SizeConfig.blockHeight * 3),
                Text(
                  context.tr('emg_threshold'),
                  style: textTheme.titleMedium?.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: SizeConfig.blockHeight * 1.5),
                LabeledSlider(
                  title: context.tr('emg_activation_threshold'),
                  value: _emgThreshold,
                  min: 0,
                  max: 100,
                  divisions: 10,
                  unit: '%MVC',
                  onChanged: _saving
                      ? (_) {}
                      : (v) => setState(() => _emgThreshold = v),
                ),
                SizedBox(height: SizeConfig.blockHeight * 4),
                PrimaryButton(
                  text: _saving
                      ? context.tr('saving')
                      : context.tr('create_program'),
                  onPressed: () {
                    if (!_saving) _onCreatePressed();
                  },
                ),
                SizedBox(height: SizeConfig.blockHeight * 2),
              ],
            ),
          ),

          // ── Tab 2: Exercises ─────────────────────────────────
          Column(
            children: [
              Expanded(
                child: _exercises.isEmpty
                    ? Center(child: Text(context.tr('no_exercises_yet')))
                    : ReorderableListView.builder(
                        padding: EdgeInsets.symmetric(
                          horizontal: SizeConfig.blockWidth * 4,
                          vertical: SizeConfig.blockHeight * 2,
                        ),
                        itemCount: _exercises.length,
                        onReorder: (oldIndex, newIndex) {
                          setState(() {
                            if (newIndex > oldIndex) newIndex--;
                            final item = _exercises.removeAt(oldIndex);
                            _exercises.insert(newIndex, item);
                          });
                        },
                        itemBuilder: (ctx, i) {
                          final ex = _exercises[i];
                          return _ExerciseTile(
                            key: ValueKey(i),
                            index: i,
                            exercise: ex,
                            onEdit: () => _editExercise(i),
                            onDelete: () =>
                                setState(() => _exercises.removeAt(i)),
                          );
                        },
                      ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  SizeConfig.blockWidth * 4,
                  0,
                  SizeConfig.blockWidth * 4,
                  SizeConfig.blockHeight * 3,
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _addExercise,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: cs.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      context.tr('Add Exercise'),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: DoctorBottomNav(
        currentIndex: _navIndex,
        onChanged: (index) {
          if (index == _navIndex) return;
          setState(() => _navIndex = index);
          if (index == 0) doctorNavPush(context, const DoctorHomeScreen());
          if (index == 2)
            doctorNavPush(context, const NewPatientRequestScreen());
          if (index == 3)
            doctorNavPush(context, const SettingsScreen(role: 'doctor'));
        },
      ),
    );
  }

  Future<void> _onCreatePressed() async {
    final name = _programNameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tr('please_enter_program_name'))),
      );
      return;
    }
    if (_doctorId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tr('no_logged_in_doctor_short'))),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      final response = await supabase
          .from('programs')
          .insert({
            'doctor_id': _doctorId,
            'name': name,
            'injury_type': _selectedInjuryType ?? 'Stroke',
            'session_duration_min': _sessionDuration,
            'target_finger_flexion_deg': _fingerAngle,
            'motor_assistance_percent': _motorAssist,
            'emg_activation_threshold_percent_mvc': _emgThreshold,
            'patients_count': 0,
          })
          .select()
          .single();

      final created = TherapyProgramModel(
        id: response['id'].toString(),
        name: name,
        injuryType: _selectedInjuryType ?? 'Stroke',
        sessionDuration: _sessionDuration,
        fingerAngle: _fingerAngle,
        motorAssist: _motorAssist,
        emgThreshold: _emgThreshold,
      );
      if (!mounted) return;
      Navigator.pop(context, created);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.tr('failed_to_create_program', params: {'error': '$e'}),
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}

// ── Exercise tile ─────────────────────────────────────────────────────────
class _ExerciseTile extends StatelessWidget {
  final int index;
  final _Exercise exercise;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ExerciseTile({
    super.key,
    required this.index,
    required this.exercise,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: theme.dividerColor.withOpacity(isDark ? 0.18 : 0.10),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.10 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: cs.primary.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: cs.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exercise.name,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${exercise.reps} reps × ${exercise.sets} sets  •  ${exercise.restSeconds}s Rest (seconds)',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: cs.onSurface.withOpacity(0.55),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onEdit,
            icon: Icon(Icons.edit_outlined, size: 18, color: cs.primary),
          ),
          IconButton(
            onPressed: onDelete,
            icon: Icon(Icons.delete_outline, size: 18, color: cs.error),
          ),
          Icon(
            Icons.drag_handle_rounded,
            color: cs.onSurface.withOpacity(0.35),
          ),
        ],
      ),
    );
  }
}

// ── Add/Edit exercise dialog ──────────────────────────────────────────────
class _AddExerciseDialog extends StatefulWidget {
  final _Exercise? existing;
  const _AddExerciseDialog({this.existing});
  @override
  State<_AddExerciseDialog> createState() => _AddExerciseDialogState();
}

class _AddExerciseDialogState extends State<_AddExerciseDialog> {
  late TextEditingController _nameCtrl;
  late int _reps, _sets, _rest;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.existing?.name ?? '');
    _reps = widget.existing?.reps ?? 10;
    _sets = widget.existing?.sets ?? 3;
    _rest = widget.existing?.restSeconds ?? 15;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(
        widget.existing == null
            ? context.tr('Add Exercise')
            : context.tr('Edit Exercise'),
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w700,
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameCtrl,
              decoration: InputDecoration(
                labelText: context.tr('Exercise Name'),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 14),
            _CounterRow(
              label: context.tr('Reps'),
              value: _reps,
              onDec: () {
                if (_reps > 1) setState(() => _reps--);
              },
              onInc: () => setState(() => _reps++),
            ),
            const SizedBox(height: 10),
            _CounterRow(
              label: context.tr('Sets'),
              value: _sets,
              onDec: () {
                if (_sets > 1) setState(() => _sets--);
              },
              onInc: () => setState(() => _sets++),
            ),
            const SizedBox(height: 10),
            _CounterRow(
              label: context.tr('Rest (s)'),
              value: _rest,
              onDec: () {
                if (_rest > 5) setState(() => _rest -= 5);
              },
              onInc: () => setState(() => _rest += 5),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(context.tr('Cancel')),
        ),
        ElevatedButton(
          onPressed: () {
            final name = _nameCtrl.text.trim();
            if (name.isEmpty) return;
            Navigator.pop(
              context,
              _Exercise(
                name: name,
                reps: _reps,
                sets: _sets,
                restSeconds: _rest,
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: cs.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Text(context.tr('Save')),
        ),
      ],
    );
  }
}

class _CounterRow extends StatelessWidget {
  final String label;
  final int value;
  final VoidCallback onDec;
  final VoidCallback onInc;
  const _CounterRow({
    required this.label,
    required this.value,
    required this.onDec,
    required this.onInc,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        IconButton(
          onPressed: onDec,
          icon: const Icon(Icons.remove_circle_outline),
        ),
        SizedBox(
          width: 36,
          child: Center(
            child: Text(
              '$value',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        IconButton(
          onPressed: onInc,
          icon: const Icon(Icons.add_circle_outline),
        ),
      ],
    );
  }
}
