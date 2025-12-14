import 'package:flutter/material.dart';

class ReportInfoRow extends StatelessWidget {
  final String label;
  final String value;

  const ReportInfoRow({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(child: Text(label, style: textTheme.bodySmall)),
          Text(value, style: textTheme.bodyMedium),
        ],
      ),
    );
  }
}
