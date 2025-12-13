import 'package:flutter/material.dart';
import 'package:smart_glove/core/utils/size_config.dart';
import 'package:smart_glove/core/widgets/primary_button.dart';
import 'package:smart_glove/features/doctor/presentation/screens/create_program_screen.dart';
import 'package:smart_glove/features/doctor/presentation/screens/program_config_screen.dart';
import 'package:smart_glove/features/doctor/presentation/widgets/doctor_profile_header.dart';
import 'package:smart_glove/features/doctor/presentation/widgets/drawer_menu.dart';
import 'package:smart_glove/features/doctor/presentation/widgets/program_card.dart';

class DoctorHomeScreen extends StatelessWidget {
  const DoctorHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      drawer: const DoctorDrawer(),
      appBar: AppBar(title: const Text('Home')),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: SizeConfig.blockWidth * 4,
          vertical: SizeConfig.blockHeight * 2,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const DoctorProfileHeader(),
            SizedBox(height: SizeConfig.blockHeight * 3),

            Text(
              'Therapy Programs',
              style: textTheme.titleMedium?.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),

            SizedBox(height: SizeConfig.blockHeight * 2),

            ProgramCard(
              title: 'Stroke Recovery',
              patientsCount: 20,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ProgramConfigScreen(
                      programName: 'Stroke Recovery',
                    ),
                  ),
                );
              },
            ),

            SizedBox(height: SizeConfig.blockHeight * 1.5),

            ProgramCard(
              title: 'Therapy for Children',
              patientsCount: 15,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ProgramConfigScreen(
                      programName: 'Therapy for Children',
                    ),
                  ),
                );
              },
            ),

            SizedBox(height: SizeConfig.blockHeight * 3),

            PrimaryButton(
              text: 'Create New Program',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CreateProgramScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
