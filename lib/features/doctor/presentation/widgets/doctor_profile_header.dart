import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:smart_glove/core/utils/size_config.dart';
import 'package:smart_glove/core/localization/app_localizations.dart';
import 'package:smart_glove/core/widgets/avatar_widget.dart';
import 'package:smart_glove/supabase_client.dart';

class DoctorProfileHeader extends StatefulWidget {
  const DoctorProfileHeader({super.key});

  @override
  State<DoctorProfileHeader> createState() => _DoctorProfileHeaderState();
}

class _DoctorProfileHeaderState extends State<DoctorProfileHeader> {
  Map<String, dynamic>? _doctorData;

  @override
  void initState() {
    super.initState();
    _loadDoctor();
  }

  Future<void> _loadDoctor() async {
    final uid = Supabase.instance.client.auth.currentUser?.id;
    if (uid == null) return;
    final data = await supabase
        .from('users')
        .select('name, avatar_url')
        .eq('id', uid)
        .maybeSingle();
    if (!mounted) return;
    setState(() => _doctorData = data);
  }

  String _getGreeting(BuildContext context) {
    final hour = DateTime.now().hour;
    if (hour < 12) return context.tr('good_morning');
    if (hour < 17) return context.tr('good_afternoon');
    if (hour < 21) return context.tr('good_evening');
    return context.tr('good_night');
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final name = _doctorData?['name']?.toString() ?? 'Doctor';
    final avatarUrl = _doctorData?['avatar_url']?.toString();
    final greeting = _getGreeting(context);

    return Row(
      children: [
        AvatarWidget(
          imageUrl: avatarUrl,
          name: name,
          radius: SizeConfig.blockWidth * 8,
        ),
        SizedBox(width: SizeConfig.blockWidth * 4),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                greeting,
                style: textTheme.bodySmall?.copyWith(
                  fontSize: 13,
                  color: cs.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                name,
                style: textTheme.titleMedium?.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                context.tr('hand_rehab_specialist'),
                style: textTheme.bodySmall?.copyWith(fontSize: 13),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
