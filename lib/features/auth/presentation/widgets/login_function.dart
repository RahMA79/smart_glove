import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_glove/features/patient/presentation/screens/patient_home_screen.dart';
import '../../../doctor/presentation/screens/doctor_home_screen.dart';
import 'package:smart_glove/supabase_client.dart';
import 'package:smart_glove/core/utils/auth_error_handler.dart';

class RoleRoutes {
  static const doctor = "doctor";
  static const patient = "patient";
}

const List<String> kDoctorDomains = [
  "clinic.com",
  "hospital.com",
  "smartgloves.org",
  "doc.com",
];

bool isDoctorEmail(String email) {
  final e = email.trim().toLowerCase();
  final parts = e.split("@");
  if (parts.length != 2) return false;
  return kDoctorDomains.contains(parts[1]);
}

Future<String?> fetchRoleFromSupabase(String uid) async {
  final response = await supabase
      .from('users')
      .select('role')
      .eq('id', uid)
      .maybeSingle();
  return response?['role']?.toString();
}

Future<void> ensureUserProfile({
  required String uid,
  required String email,
  String? name,
  int? age,
  String? avatarUrl,
}) async {
  final role = isDoctorEmail(email) ? RoleRoutes.doctor : RoleRoutes.patient;
  final data = <String, dynamic>{
    'id': uid,
    'email': email.trim().toLowerCase(),
    'role': role,
    'name': name ?? '',
    'age': age,
  };
  if (avatarUrl != null) data['avatar_url'] = avatarUrl;
  await supabase.from('users').upsert(data, onConflict: 'id');
}

Future<void> ensureRoleDoc({
  required String uid,
  required String email,
  required String role,
  String? name,
  String? avatarUrl,
  String? medicalRecordUrl,
}) async {
  final safeName = (name ?? '').trim();
  if (role == RoleRoutes.doctor) {
    final data = <String, dynamic>{
      'id': uid,
      'email': email.trim().toLowerCase(),
      'name': safeName.isEmpty ? 'Doctor' : safeName,
    };
    if (avatarUrl != null) data['avatar_url'] = avatarUrl;
    await supabase.from('doctors').upsert(data, onConflict: 'id');
  } else {
    final data = <String, dynamic>{
      'id': uid,
      'email': email.trim().toLowerCase(),
      'name': safeName.isEmpty ? 'Patient' : safeName,
    };
    if (avatarUrl != null) data['avatar_url'] = avatarUrl;
    if (medicalRecordUrl != null) data['medical_record_url'] = medicalRecordUrl;
    await supabase.from('patients').upsert(data, onConflict: 'id');
  }
}

Future<void> validate_email_password(
  BuildContext context,
  TextEditingController emailController,
  TextEditingController passwordController,
) async {
  try {
    final email = emailController.text.trim();
    final password = passwordController.text;

    final response = await Supabase.instance.client.auth.signInWithPassword(
      email: email,
      password: password,
    );

    final user = response.user;
    if (user == null) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login failed. Please try again.')),
      );
      return;
    }

    final metadata = user.userMetadata ?? {};
    final name = metadata['name']?.toString();
    final age = metadata['age'] is int
        ? metadata['age']
        : int.tryParse(metadata['age']?.toString() ?? '');

    String? role = await fetchRoleFromSupabase(user.id);
    role ??= isDoctorEmail(email) ? RoleRoutes.doctor : RoleRoutes.patient;

    await ensureUserProfile(uid: user.id, email: email, name: name, age: age);
    await ensureRoleDoc(uid: user.id, email: email, role: role, name: name);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("isLoggedIn", true);
    await prefs.setString("role", role);

    if (!context.mounted) return;

    if (role == RoleRoutes.doctor) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const DoctorHomeScreen()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => PatientHomeScreen(userId: user.id)),
      );
    }
  } on AuthException catch (e) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(friendlyAuthError(e.message))),
    );
  } catch (e) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(friendlyAuthError(e.toString()))),
    );
  }
}
