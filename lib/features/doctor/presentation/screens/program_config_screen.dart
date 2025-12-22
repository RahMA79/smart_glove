import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:smart_glove/core/utils/size_config.dart';
import 'package:smart_glove/core/widgets/primary_button.dart';
import '../../presentation/widgets/labeled_slider.dart';

class ProgramConfigScreen extends StatefulWidget {
  final String programId;
  final String programName;

  const ProgramConfigScreen({
    super.key,
    required this.programId,
    required this.programName,
  });

  @override
  State<ProgramConfigScreen> createState() => _ProgramConfigScreenState();
}

class _ProgramConfigScreenState extends State<ProgramConfigScreen> {
  bool _loading = true;
  bool _saving = false;
  bool _deleting = false;

  String? _doctorId;

  double _sessionDurationMin = 30;
  double _targetFingerFlexionDeg = 60;
  double _motorAssistancePercent = 50;
  double _emgActivationThresholdPercentMvc = 30;

  @override
  void initState() {
    super.initState();
    _doctorId = FirebaseAuth.instance.currentUser?.uid;
    _loadProgram();
  }

  double _toDouble(dynamic v, double fallback) {
    if (v is num) return v.toDouble();
    return fallback;
  }

  Future<void> _loadProgram() async {
    setState(() => _loading = true);

    try {
      if (_doctorId == null) return;

      final doc = await FirebaseFirestore.instance
          .collection('doctors')
          .doc(_doctorId)
          .collection('programs')
          .doc(widget.programId)
          .get();

      if (!doc.exists) return;

      final data = doc.data() as Map<String, dynamic>;

      setState(() {
        _sessionDurationMin = _toDouble(
          data['sessionDurationMin'],
          _sessionDurationMin,
        );

        _targetFingerFlexionDeg = _toDouble(
          data['targetFingerFlexionDeg'],
          _targetFingerFlexionDeg,
        );

        _motorAssistancePercent = _toDouble(
          data['motorAssistancePercent'],
          _motorAssistancePercent,
        );

        _emgActivationThresholdPercentMvc = _toDouble(
          data['emgActivationThresholdPercentMvc'],
          _emgActivationThresholdPercentMvc,
        );
      });
    } catch (_) {
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final cs = theme.colorScheme;

    final disabled = _saving || _deleting;

    final destructiveColor = cs.error;
    final iconBaseColor = theme.brightness == Brightness.dark
        ? cs.onSurface.withOpacity(0.85)
        : cs.onSurface.withOpacity(0.70);

    if (_doctorId == null) {
      return const Scaffold(
        body: Center(child: Text("No logged-in doctor. Please login again.")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.programName),
        actions: [
          Padding(
            padding: const EdgeInsetsDirectional.only(end: 6),
            child: Material(
              color: Colors.transparent,
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                hoverColor: destructiveColor.withOpacity(0.14),
                splashColor: destructiveColor.withOpacity(0.22),
                onTap: disabled ? null : _confirmDelete,
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Icon(
                    Icons.delete_forever_rounded,
                    size: 26,
                    color: disabled
                        ? cs.onSurface.withOpacity(0.35)
                        : iconBaseColor,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: SizeConfig.blockWidth * 4,
                vertical: SizeConfig.blockHeight * 2,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Session Settings',
                    style: textTheme.titleMedium?.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: cs.onSurface,
                    ),
                  ),
                  SizedBox(height: SizeConfig.blockHeight * 1.5),

                  LabeledSlider(
                    title: 'Session Duration',
                    value: _sessionDurationMin,
                    min: 10,
                    max: 60,
                    divisions: 5,
                    unit: 'min',
                    onChanged: disabled
                        ? (_) {}
                        : (v) => setState(() => _sessionDurationMin = v),
                  ),

                  SizedBox(height: SizeConfig.blockHeight * 2),

                  Text(
                    'Finger Angles & Assistance',
                    style: textTheme.titleMedium?.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: cs.onSurface,
                    ),
                  ),
                  SizedBox(height: SizeConfig.blockHeight * 1.5),

                  LabeledSlider(
                    title: 'Target Finger Flexion',
                    value: _targetFingerFlexionDeg,
                    min: 0,
                    max: 90,
                    divisions: 9,
                    unit: '°',
                    onChanged: disabled
                        ? (_) {}
                        : (v) => setState(() => _targetFingerFlexionDeg = v),
                  ),

                  SizedBox(height: SizeConfig.blockHeight * 1.5),

                  LabeledSlider(
                    title: 'Motor Assistance Level',
                    value: _motorAssistancePercent,
                    min: 0,
                    max: 100,
                    divisions: 10,
                    unit: '%',
                    onChanged: disabled
                        ? (_) {}
                        : (v) => setState(() => _motorAssistancePercent = v),
                  ),

                  SizedBox(height: SizeConfig.blockHeight * 3),

                  Text(
                    'EMG Threshold',
                    style: textTheme.titleMedium?.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: cs.onSurface,
                    ),
                  ),
                  SizedBox(height: SizeConfig.blockHeight * 1.5),

                  LabeledSlider(
                    title: 'EMG Activation Threshold',
                    value: _emgActivationThresholdPercentMvc,
                    min: 0,
                    max: 100,
                    divisions: 10,
                    unit: '%MVC',
                    onChanged: disabled
                        ? (_) {}
                        : (v) => setState(
                            () => _emgActivationThresholdPercentMvc = v,
                          ),
                  ),

                  SizedBox(height: SizeConfig.blockHeight * 4),

                  PrimaryButton(
                    text: _saving ? 'Saving...' : 'Save Changes',
                    onPressed: () {
                      if (disabled) return;
                      _onSavePressed();
                    },
                  ),
                ],
              ),
            ),
    );
  }

  Future<void> _onSavePressed() async {
    setState(() => _saving = true);

    try {
      await FirebaseFirestore.instance
          .collection('doctors')
          .doc(_doctorId)
          .collection('programs')
          .doc(widget.programId)
          .update({
            'sessionDurationMin': _sessionDurationMin,
            'targetFingerFlexionDeg': _targetFingerFlexionDeg,
            'motorAssistancePercent': _motorAssistancePercent,
            'emgActivationThresholdPercentMvc':
                _emgActivationThresholdPercentMvc,
            'updatedAt': FieldValue.serverTimestamp(),
          });

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Program settings saved')));
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to save: $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _confirmDelete() async {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: cs.surface,
        title: Text(
          'Delete Program',
          style: TextStyle(fontWeight: FontWeight.w700, color: cs.onSurface),
        ),
        content: Text(
          'Are you sure you want to permanently delete this program?\nThis action cannot be undone.',
          style: TextStyle(color: cs.onSurface.withOpacity(0.85)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel', style: TextStyle(color: cs.primary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: cs.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (ok == true) {
      await _deleteProgram();
    }
  }

  Future<void> _deleteProgram() async {
    setState(() => _deleting = true);

    try {
      await FirebaseFirestore.instance
          .collection('doctors')
          .doc(_doctorId)
          .collection('programs')
          .doc(widget.programId)
          .delete();

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Program deleted')));
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to delete: $e')));
    } finally {
      if (mounted) setState(() => _deleting = false);
    }
  }
}
