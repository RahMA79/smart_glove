import 'package:flutter/material.dart';
import 'package:smart_glove/core/utils/size_config.dart';

class PatientHeaderCard extends StatelessWidget {
  final String patientName;
  final String condition;

  const PatientHeaderCard({
    super.key,
    required this.patientName,
    required this.condition,
  });

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;
    final muted = onSurface.withOpacity(0.65);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(SizeConfig.blockWidth * 4),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: theme.colorScheme.primary.withOpacity(0.12),
            child: Icon(Icons.person, color: theme.colorScheme.primary),
          ),
          SizedBox(width: SizeConfig.blockWidth * 3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  patientName,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  condition,
                  style: theme.textTheme.bodySmall?.copyWith(color: muted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
