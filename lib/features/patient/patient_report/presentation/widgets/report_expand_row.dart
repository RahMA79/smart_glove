import 'package:flutter/material.dart';

class ReportExpandRow extends StatelessWidget {
  final String title;
  final String? trailingText;
  final VoidCallback? onTap;

  const ReportExpandRow({
    super.key,
    required this.title,
    this.trailingText,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            const Icon(Icons.chevron_right, size: 22),
            const SizedBox(width: 8),
            Expanded(child: Text(title, style: textTheme.bodyMedium)),
            if (trailingText != null)
              Text(trailingText!, style: textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
