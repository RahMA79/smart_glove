import 'package:flutter/material.dart';
import 'package:smart_glove/core/utils/size_config.dart';

class PatientProfileHeader extends StatelessWidget {
  final String patientName;
  const PatientProfileHeader({super.key, required this.patientName});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: SizeConfig.blockWidth * 5.5,
          backgroundImage: const AssetImage('assets/images/person.png'),
        ),
        SizedBox(width: SizeConfig.blockWidth * 3),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              patientName,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            Text(
              'Patient',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(
                  context,
                ).textTheme.bodySmall?.color?.withOpacity(0.65),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
