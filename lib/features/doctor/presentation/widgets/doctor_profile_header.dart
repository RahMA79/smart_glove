import 'package:flutter/material.dart';
import 'package:smart_glove/core/utils/size_config.dart';

class DoctorProfileHeader extends StatelessWidget {
  const DoctorProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        CircleAvatar(
          radius: SizeConfig.blockWidth * 8,
          backgroundImage: const AssetImage('assets/images/doc.jpg'),
        ),
        SizedBox(width: SizeConfig.blockWidth * 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dr. Sarah Ahmed',
              style: textTheme.titleMedium?.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Hand Rehabilitation Specialist',
              style: textTheme.bodySmall?.copyWith(fontSize: 13),
            ),
          ],
        ),
      ],
    );
  }
}
