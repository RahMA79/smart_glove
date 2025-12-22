import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_glove/core/utils/size_config.dart';
import 'package:smart_glove/features/patient/presentation/widgets/patient_program_card.dart';
import 'package:smart_glove/features/patient/presentation/widgets/patient_bottom_nav.dart';
import 'package:smart_glove/features/patient/session/presentation/screens/session_details_screen.dart';

import '../widgets/patient_drawer.dart';
import '../widgets/get_patient_name.dart';

class PatientHomeScreen extends StatefulWidget {
  final String userId;
  const PatientHomeScreen({super.key, required this.userId});

  @override
  State<PatientHomeScreen> createState() => _PatientHomeScreenState();
}

class _PatientHomeScreenState extends State<PatientHomeScreen> {
  String _patientName = '...';
  File? _image;
  final ImagePicker _picker = ImagePicker();
  String? imageUrl;
  Future<void> pickAndSaveImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile == null) return; // لو المستخدم ما اختارش حاجة

    final directory = await getApplicationDocumentsDirectory();
    final String newPath = '${directory.path}/profile_image.png';

    final File newImage = await File(pickedFile.path).copy(newPath);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profile_image', newImage.path); // حفظ المسار

    setState(() {
      _image = newImage; // تحديث الصورة على الشاشة
    });
  }

  Future<void> loadSavedImage() async {
    final prefs = await SharedPreferences.getInstance();
    final path = prefs.getString('profile_image');

    if (path != null && File(path).existsSync()) {
      setState(() {
        _image = File(path);
      });
    }
  }

  Widget buildProfileImage() {
    if (_image != null) {
      return Image.file(_image!, fit: BoxFit.cover, width: 120, height: 120);
    } else {
      return Image.asset(
        'assets/images/logo.png',
        fit: BoxFit.cover,
        width: 120,
        height: 120,
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _loadName();
  }

  Future<void> _loadName() async {
    final name = await getPatientName(widget.userId);
    if (!mounted) return;
    setState(() => _patientName = name ?? 'Patient');
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);

    return Scaffold(
      drawer: PatientDrawer(patientName: _patientName),
      appBar: AppBar(
        toolbarHeight: SizeConfig.blockHeight * 10,
        title: Row(
          children: [
            // CircleAvatar(
            //   radius: SizeConfig.blockWidth * 5.5,
            //   backgroundImage: const AssetImage('assets/images/person.png'),
            // ),
            GestureDetector(
              onTap: pickAndSaveImage, // عند الضغط نفتح المعرض لاختيار صورة
              child: CircleAvatar(
                radius: 60,
                backgroundColor: Colors.grey[300],
                backgroundImage: _image != null ? FileImage(_image!) : null,
                child: _image == null
                    ? Icon(Icons.add_a_photo, size: 40, color: Colors.white)
                    : null,
              ),
            ),

            SizedBox(width: SizeConfig.blockWidth * 3),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _patientName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
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
        ),
        actions: const [SizedBox(width: 8)],
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: SizeConfig.blockWidth * 4,
          vertical: SizeConfig.blockHeight * 2,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Therapy Programs',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            SizedBox(height: SizeConfig.blockHeight * 2),

            PatientProgramCard(
              title: 'Burn Rehab',
              subtitle: '3 sessions / week',
              onTap: () {
                // TODO: open program details
              },
            ),

            SizedBox(height: SizeConfig.blockHeight * 1.5),

            PatientProgramCard(
              title: 'Nerve Therapy',
              subtitle: '4 sessions / week',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const SessionDetailsScreen(
                      sessionTitle: 'Session',
                      description:
                          "Designed to improve hand mobility by stimulating the flexor and extensor muscles.\nHelps restore nerve function and enhance activation.",
                      durationMinutes: 1,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: PatientBottomNav(
        currentIndex: 0,
        onTap: (index) {
          if (index == 0) return;

          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const SessionDetailsScreen(
                  sessionTitle: 'Session',
                  description:
                      "Designed to improve hand mobility by stimulating the flexor and extensor muscles.\nHelps restore nerve function and enhance activation.",
                  durationMinutes: 1,
                ),
              ),
            );
          }

          if (index == 2) {
            Navigator.pushNamed(context, '/profile');
          }
        },
      ),
    );
  }
}
