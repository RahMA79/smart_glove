import 'package:flutter/material.dart';
import 'package:smart_glove/core/theme/app_colors.dart';
import 'package:smart_glove/core/utils/size_config.dart';
import 'package:smart_glove/core/widgets/primary_button.dart';
import 'package:smart_glove/features/doctor/presentation/widgets/doctor_profile_header.dart';
import 'package:smart_glove/features/doctor/presentation/widgets/drawer_menu.dart';
import 'package:smart_glove/features/doctor/presentation/widgets/program_card.dart';

class DoctorHomeScreen extends StatelessWidget {
  const DoctorHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);

    return Scaffold(
      drawer: const DoctorDrawer(),
      appBar: AppBar(title: const Text('Home')),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: SizeConfig.blockWidth * 4, // 4% from width
          vertical: SizeConfig.blockHeight * 2, // 2% from height
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const DoctorProfileHeader(),
            SizedBox(height: SizeConfig.blockHeight * 3),

            const Text(
              'Therapy Programs',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textMain,
              ),
            ),
            SizedBox(height: SizeConfig.blockHeight * 2),

            ProgramCard(
              title: 'Stroke Recovery',
              patientsCount: 20,
              onTap: () {
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //     builder: (_) => const ProgramConfigScreen(
                //       programName: 'Stroke Recovery',
                //     ),
                //   ),
                // );
              },
            ),
            SizedBox(height: SizeConfig.blockHeight * 1.5),
            ProgramCard(
              title: 'Therapy for Children',
              patientsCount: 15,
              onTap: () {
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //     builder: (_) => const ProgramConfigScreen(
                //       programName: 'Stroke Recovery',
                //     ),
                //   ),
                // );
              },
            ),

            SizedBox(height: SizeConfig.blockHeight * 3),

            PrimaryButton(
              text: 'Create New Program',
              onPressed: () {
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(builder: (_) => const CreateProgramScreen()),
                // );
              },
            ),
          ],
        ),
      ),
    );
  }
}
