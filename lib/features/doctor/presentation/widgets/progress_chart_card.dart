import 'package:flutter/material.dart';

class ProgressChartCard extends StatelessWidget {
  final String title;
  final String valueLabel;
  final String unit;

  const ProgressChartCard({
    super.key,
    required this.title,
    required this.valueLabel,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurface.withOpacity(0.65);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),
          Container(
            height: 120,
            alignment: Alignment.center,
            child: Text(
              "Chart Placeholder",
              style: theme.textTheme.bodySmall?.copyWith(color: muted),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "$valueLabel $unit",
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
