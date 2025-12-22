import 'package:flutter/material.dart';
import 'package:smart_glove/core/utils/size_config.dart';

class PatientProgramCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const PatientProgramCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: EdgeInsets.all(SizeConfig.blockWidth * 4),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: theme.dividerColor.withOpacity(isDark ? 0.22 : 0.18),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.18 : 0.06),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            // ✅ Icon container أقرب لستايل الدكتور
            Container(
              width: SizeConfig.blockWidth * 12,
              height: SizeConfig.blockWidth * 12,
              decoration: BoxDecoration(
                color: cs.primary.withOpacity(isDark ? 0.18 : 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(Icons.healing_rounded, color: cs.primary, size: 26),
            ),

            SizedBox(width: SizeConfig.blockWidth * 3),

            // ✅ Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: SizeConfig.blockHeight * 0.5),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: cs.onSurface.withOpacity(0.65),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            // ✅ Arrow أنعم
            Icon(
              Icons.chevron_right_rounded,
              size: 22,
              color: cs.onSurface.withOpacity(0.55),
            ),
          ],
        ),
      ),
    );
  }
}
