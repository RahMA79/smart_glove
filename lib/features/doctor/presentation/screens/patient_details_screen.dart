import 'package:flutter/material.dart';
import 'package:smart_glove/core/widgets/avatar_widget.dart';
import 'package:smart_glove/supabase_client.dart';
import 'package:cached_network_image/cached_network_image.dart';

class PatientDetailsScreen extends StatefulWidget {
  final String patientId;
  final String patientName;

  const PatientDetailsScreen({
    super.key,
    required this.patientId,
    required this.patientName,
  });

  @override
  State<PatientDetailsScreen> createState() => _PatientDetailsScreenState();
}

class _PatientDetailsScreenState extends State<PatientDetailsScreen> {
  Map<String, dynamic>? _user;
  Map<String, dynamic>? _patient;
  bool _loading = true;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _loadError = null;
    });
    try {
      final user = await supabase
          .from('users')
          .select('id, name, email, age, avatar_url')
          .eq('id', widget.patientId)
          .maybeSingle();

      final patient = await supabase
          .from('patients')
          .select('id, name, medical_record_url, condition, avatar_url')
          .eq('id', widget.patientId)
          .maybeSingle();

      debugPrint('widget.patientId = ${widget.patientId}');
      debugPrint('user row = $user');
      debugPrint('patient row = $patient');
      debugPrint('medical_record_url = ${patient?['medical_record_url']}');

      if (!mounted) return;
      setState(() {
        _user = user;
        _patient = patient;
        _loading = false;
      });
    } catch (e) {
      debugPrint('LOAD ERROR = $e');
      if (!mounted) return;
      setState(() {
        _loading = false;
        _loadError = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    // Resolve values from both tables with fallbacks
    final name = _user?['name']?.toString().trim().isNotEmpty == true
        ? _user!['name'].toString()
        : (_patient?['name']?.toString().trim().isNotEmpty == true
              ? _patient!['name'].toString()
              : widget.patientName);

    final email = _user?['email']?.toString() ?? '';
    final age = _user?['age']?.toString() ?? '-';

    // Avatar: prefer users table, fall back to patients table
    final avatarUrl = (_user?['avatar_url']?.toString()?.isNotEmpty == true
        ? _user!['avatar_url'].toString()
        : _patient?['avatar_url']?.toString());

    final condition =
        _patient?['condition']?.toString().trim().isNotEmpty == true
        ? _patient!['condition'].toString()
        : '-';

    // FIX: Explicitly cast and clean the medical_record_url
    final rawMedUrl = _patient?['medical_record_url'];
    final medicalRecordUrl =
        (rawMedUrl is String && rawMedUrl.trim().isNotEmpty)
        ? rawMedUrl.trim()
        : null;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Patient Details'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _load,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _loadError != null
          ? _ErrorState(error: _loadError!, onRetry: _load)
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Profile header ────────────────────────────
                  Center(
                    child: Column(
                      children: [
                        AvatarWidget(
                          imageUrl: avatarUrl,
                          name: name,
                          radius: 52,
                        ),
                        const SizedBox(height: 14),
                        Text(
                          name,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        if (condition != '-')
                          Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: cs.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                condition,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: cs.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // ── Info card ─────────────────────────────────
                  _SectionTitle(title: 'Patient Information'),
                  const SizedBox(height: 10),
                  _InfoCard(
                    children: [
                      _InfoRow(
                        icon: Icons.person_outline,
                        label: 'Name',
                        value: name,
                      ),
                      _InfoDivider(),
                      _InfoRow(
                        icon: Icons.email_outlined,
                        label: 'Email',
                        value: email.isEmpty ? 'Not provided' : email,
                      ),
                      _InfoDivider(),
                      _InfoRow(
                        icon: Icons.cake_outlined,
                        label: 'Age',
                        value: age == '-' ? 'Not provided' : '$age years',
                      ),
                      _InfoDivider(),
                      _InfoRow(
                        icon: Icons.medical_services_outlined,
                        label: 'Condition',
                        value: condition,
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // ── Medical record ────────────────────────────
                  _SectionTitle(title: 'Medical Record'),
                  const SizedBox(height: 10),

                  if (medicalRecordUrl != null)
                    _MedicalRecordCard(imageUrl: medicalRecordUrl)
                  else
                    _InfoCard(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          child: Center(
                            child: Column(
                              children: [
                                Icon(
                                  Icons.folder_off_outlined,
                                  size: 44,
                                  color: cs.onSurface.withOpacity(0.3),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  'No medical record uploaded',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: cs.onSurface.withOpacity(0.5),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Patient hasn\'t uploaded a record yet',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: cs.onSurface.withOpacity(0.35),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
    );
  }
}

// ── Error state ─────────────────────────────────────────────────────────────
class _ErrorState extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;
  const _ErrorState({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: cs.error),
            const SizedBox(height: 12),
            Text(
              'Could not load patient data',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: theme.textTheme.bodySmall?.copyWith(
                color: cs.onSurface.withOpacity(0.55),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Reusable card wrapper ────────────────────────────────────────────────────
class _InfoCard extends StatelessWidget {
  final List<Widget> children;
  const _InfoCard({required this.children});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: cs.outline.withOpacity(0.15)),
      ),
      child: Column(children: children),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(
        context,
      ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icon, size: 20, color: cs.primary.withOpacity(0.8)),
          const SizedBox(width: 12),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: cs.onSurface.withOpacity(0.55),
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      indent: 48,
      color: Theme.of(context).colorScheme.outline.withOpacity(0.12),
    );
  }
}

// ── Medical record image card ────────────────────────────────────────────────
class _MedicalRecordCard extends StatefulWidget {
  final String imageUrl;
  const _MedicalRecordCard({required this.imageUrl});

  @override
  State<_MedicalRecordCard> createState() => _MedicalRecordCardState();
}

class _MedicalRecordCardState extends State<_MedicalRecordCard> {
  bool _expanded = false;

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
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          CachedNetworkImage(
            imageUrl: widget.imageUrl,
            width: double.infinity,
            height: _expanded ? null : 220,
            fit: BoxFit.cover,
            placeholder: (_, __) => Container(
              height: 220,
              color: cs.surfaceVariant,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 10),
                  Text(
                    'Loading medical record...',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            errorWidget: (_, url, err) => Container(
              height: 220,
              color: cs.errorContainer.withOpacity(0.3),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.broken_image_outlined,
                      size: 44,
                      color: cs.error.withOpacity(0.6),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Could not load image',
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 6),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'URL: ${url.length > 60 ? '${url.substring(0, 60)}...' : url}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: cs.onSurface.withOpacity(0.45),
                          fontSize: 10,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Expand/collapse button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: TextButton.icon(
              onPressed: () => setState(() => _expanded = !_expanded),
              icon: Icon(
                _expanded ? Icons.expand_less : Icons.expand_more,
                size: 18,
              ),
              label: Text(_expanded ? 'Show less' : 'View full image'),
            ),
          ),
        ],
      ),
    );
  }
}
