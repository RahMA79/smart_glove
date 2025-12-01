import 'package:flutter/material.dart';
import '../../../../core/widgets/primary_card.dart';
import '../../../../core/theme/app_colors.dart';

class ProgramCard extends StatelessWidget {
  final String title;
  final int patientsCount;
  final VoidCallback onTap;

  const ProgramCard({
    super.key,
    required this.title,
    required this.patientsCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return PrimaryCard(
      onTap: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textMain,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$patientsCount patients',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const Icon(
            Icons.arrow_forward_ios,
            size: 18,
            color: AppColors.textSecondary,
          ),
        ],
      ),
    );
  }
}
