import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';
import 'package:smart_glove/core/localization/app_localizations.dart';
import 'package:smart_glove/core/utils/size_config.dart';
import 'package:smart_glove/core/widgets/primary_button.dart';
import 'package:smart_glove/core/widgets/avatar_widget.dart';
import 'package:smart_glove/supabase_client.dart';
import 'package:smart_glove/features/patient/presentation/widgets/patient_bottom_nav.dart';
import 'package:smart_glove/features/patient/presentation/screens/patient_home_screen.dart';
import 'package:smart_glove/features/patient/presentation/screens/session_history_screen.dart';
import 'package:smart_glove/features/doctor/presentation/screens/settings_screen.dart';

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

  // This screen is tab index 2
  final int _navIndex = 2;

  String? get _patientId => Supabase.instance.client.auth.currentUser?.id;

  void _fadeTo(Widget page) {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => page,
        transitionDuration: const Duration(milliseconds: 200),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
      ),
    );
  }

  Future<Map<String, dynamic>?> _getPatientProfile() async {
    final pid = _patientId;
    if (pid == null) return null;
    return await supabase.from('users').select().eq('id', pid).maybeSingle();
  }

  Future<void> _sendRequest() async {
    final pid = _patientId;
    if (pid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tr('must_be_logged_in'))),
      );
      return;
    }
    if (_selectedDoctorId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tr('Please select a doctor'))),
      );
      return;
    }

    setState(() => _sending = true);
    try {
      final patient = await _getPatientProfile();
      final patientName = (patient?['name'] ??
              Supabase.instance.client.auth.currentUser?.userMetadata?['name'] ??
              context.tr('Patient'))
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
          SnackBar(content: Text(context.tr('Request already sent.'))),
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
          content: Text(context.tr(
            'Request sent to {doctor}',
            params: {'doctor': _selectedDoctorName ?? ''},
          )),
          backgroundColor: Theme.of(context).colorScheme.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
      setState(() {
        _selectedDoctorId = null;
        _selectedDoctorName = null;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.tr('Failed: {error}', params: {'error': e.toString()}),
          ),
        ),
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
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('Select Doctor')),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: SizeConfig.blockWidth * 4,
            vertical: SizeConfig.blockHeight * 2,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Search bar ──────────────────────────────────────
              TextField(
                onChanged: (v) => setState(() => _query = v.trim()),
                decoration: InputDecoration(
                  labelText: context.tr('Search'),
                  hintText: context.tr('Enter doctor name'),
                  prefixIcon: const Icon(Icons.search_rounded),
                  filled: true,
                  fillColor: theme.cardColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: cs.outline.withOpacity(0.2),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: cs.primary, width: 1.5),
                  ),
                ),
              ),

              SizedBox(height: SizeConfig.blockHeight * 2),

              // ── Doctor list ─────────────────────────────────────
              Expanded(
                child: StreamBuilder<List<Map<String, dynamic>>>(
                  stream: supabase
                      .from('doctors')
                      .stream(primaryKey: ['id']),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.error_outline_rounded,
                                size: 48,
                                color: cs.error.withOpacity(0.6)),
                            const SizedBox(height: 12),
                            Text(
                              '${snapshot.error}',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: cs.onSurface.withOpacity(0.6),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    }

                    final docs = snapshot.data ?? [];
                    final filtered = docs.where((d) {
                      final name = (d['name'] ?? '').toString();
                      if (_query.isEmpty) return true;
                      return name
                          .toLowerCase()
                          .contains(_query.toLowerCase());
                    }).toList();

                    if (filtered.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.person_search_rounded,
                                size: 56,
                                color: cs.onSurface.withOpacity(0.25)),
                            const SizedBox(height: 14),
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
                      separatorBuilder: (_, __) =>
                          SizedBox(height: SizeConfig.blockHeight * 1),
                      itemBuilder: (context, index) {
                        final data = filtered[index];
                        final id = data['id'].toString();
                        final name = (data['name'] ?? context.tr('Doctor'))
                            .toString();
                        final email = (data['email'] ?? '').toString();
                        final avatarUrl = data['avatar_url']?.toString();
                        final isSelected = _selectedDoctorId == id;

                        return _DoctorCard(
                          id: id,
                          name: name,
                          email: email,
                          avatarUrl: avatarUrl,
                          isSelected: isSelected,
                          isDark: isDark,
                          onTap: () => setState(() {
                            _selectedDoctorId = id;
                            _selectedDoctorName = name;
                          }),
                        );
                      },
                    );
                  },
                ),
              ),

              SizedBox(height: SizeConfig.blockHeight * 1.5),

              // ── Selected doctor chip ─────────────────────────────
              if (_selectedDoctorName != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle_rounded,
                          color: cs.primary, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _selectedDoctorName!,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: cs.primary,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => setState(() {
                          _selectedDoctorId = null;
                          _selectedDoctorName = null;
                        }),
                        child: Icon(Icons.close_rounded,
                            color: cs.onSurface.withOpacity(0.4), size: 18),
                      ),
                    ],
                  ),
                ),

              // ── Send button ─────────────────────────────────────
              PrimaryButton(
                text: _sending
                    ? context.tr('Loading...')
                    : context.tr('Send Request'),
                onPressed: () {
                  if (!_sending) _sendRequest();
                },
              ),

              SizedBox(height: SizeConfig.blockHeight * 1),
            ],
          ),
        ),
      ),

      // ── Bottom nav ──────────────────────────────────────────────
      bottomNavigationBar: PatientBottomNav(
        currentIndex: _navIndex,
        onTap: (index) {
          if (index == _navIndex) return;
          final uid = supabase.auth.currentUser?.id ?? '';
          if (index == 0) _fadeTo(PatientHomeScreen(userId: uid));
          if (index == 1) _fadeTo(const SessionHistoryScreen());
          if (index == 3) _fadeTo(const SettingsScreen(role: 'patient'));
        },
      ),
    );
  }
}

// ── Doctor selection card ─────────────────────────────────────────────────
class _DoctorCard extends StatelessWidget {
  final String id;
  final String name;
  final String email;
  final String? avatarUrl;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  const _DoctorCard({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? cs.primary.withOpacity(isDark ? 0.15 : 0.08)
              : theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? cs.primary
                : cs.outline.withOpacity(isDark ? 0.2 : 0.15),
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: cs.primary.withOpacity(0.12),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.08 : 0.04),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Row(
          children: [
            AvatarWidget(imageUrl: avatarUrl, name: name, radius: 26),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: isSelected ? cs.primary : null,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    email,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: cs.onSurface.withOpacity(0.55),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: isSelected
                  ? Icon(Icons.check_circle_rounded,
                      key: const ValueKey('checked'),
                      color: cs.primary,
                      size: 22)
                  : Icon(Icons.radio_button_unchecked_rounded,
                      key: const ValueKey('unchecked'),
                      color: cs.onSurface.withOpacity(0.25),
                      size: 22),
            ),
          ],
        ),
      ),
    );
  }
}
