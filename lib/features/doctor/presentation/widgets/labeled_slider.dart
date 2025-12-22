import 'package:flutter/material.dart';

class LabeledSlider extends StatelessWidget {
  final String title;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final String unit;
  final ValueChanged<double> onChanged;

  const LabeledSlider({
    super.key,
    required this.title,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.unit,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final tt = theme.textTheme;

    final titleStyle = tt.bodyMedium?.copyWith(
      fontWeight: FontWeight.w600,
      color: cs.onSurface,
    );

    final valueStyle = tt.bodyMedium?.copyWith(
      fontWeight: FontWeight.w700,
      color: cs.onSurface,
    );

    final subStyle = tt.bodySmall?.copyWith(
      color: cs.onSurface.withOpacity(0.70),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text(title, style: titleStyle)),
            Text('${value.round()}$unit', style: valueStyle),
          ],
        ),
        const SizedBox(height: 6),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: cs.primary,
            inactiveTrackColor: cs.onSurface.withOpacity(0.18),
            thumbColor: cs.primary,
            overlayColor: cs.primary.withOpacity(0.12),
            valueIndicatorTextStyle: tt.bodySmall?.copyWith(
              color: cs.onPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          child: Slider(
            value: value.clamp(min, max),
            min: min,
            max: max,
            divisions: divisions,
            label: '${value.round()}$unit',
            onChanged: onChanged,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('${min.round()}$unit', style: subStyle),
            Text('${max.round()}$unit', style: subStyle),
          ],
        ),
      ],
    );
  }
}
