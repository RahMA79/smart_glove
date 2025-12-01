import 'package:flutter/material.dart';
import 'package:smart_glove/core/theme/app_colors.dart';
import 'package:smart_glove/core/utils/size_config.dart';

class DoctorProfileHeader extends StatelessWidget {
  const DoctorProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: SizeConfig.blockWidth * 8,
          backgroundImage: const AssetImage('assets/images/doc.jpg'),
        ),
        SizedBox(width: SizeConfig.blockWidth * 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Dr. Sarah Ahmed',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textMain,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Hand Rehabilitation Specialist',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
          ],
        ),
      ],
    );
  }
}
