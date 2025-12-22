import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_glove/features/patient/presentation/screens/patient_home_screen.dart';
import '../../../doctor/presentation/screens/doctor_home_screen.dart';

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
  final domain = parts[1];
  return kDoctorDomains.contains(domain);
}

Future<String?> fetchRoleFromFirestore(String uid) async {
  final fs = FirebaseFirestore.instance;

  final userDoc = await fs.collection("users").doc(uid).get();
  if (userDoc.exists) {
    final role = userDoc.data()?["role"]?.toString();
    if (role != null && role.isNotEmpty) return role;
  }

  return null;
}

Future<void> ensureUserProfile({
  required String uid,
  required String email,
}) async {
  final fs = FirebaseFirestore.instance;
  final ref = fs.collection("users").doc(uid);

  final snap = await ref.get();
  if (snap.exists) return;

  final role = isDoctorEmail(email) ? RoleRoutes.doctor : RoleRoutes.patient;

  await ref.set({
    "uid": uid,
    "email": email.trim().toLowerCase(),
    "role": role,
    "createdAt": FieldValue.serverTimestamp(),
  }, SetOptions(merge: true));
}

Future<void> validate_email_password(
  BuildContext context,
  FirebaseAuth auth,
  TextEditingController emailController,
  TextEditingController passwordController,
) async {
  try {
    final email = emailController.text.trim();
    final password = passwordController.text;

    final cred = await auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = cred.user;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Login failed: user is null")),
      );
      return;
    }

    String? role = await fetchRoleFromFirestore(user.uid);

    role ??= isDoctorEmail(user.email ?? email)
        ? RoleRoutes.doctor
        : RoleRoutes.patient;

    await ensureUserProfile(uid: user.uid, email: user.email ?? email);

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
        MaterialPageRoute(builder: (_) => PatientHomeScreen(userId: user.uid)),
      );
    }
  } on FirebaseAuthException catch (e) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(e.message ?? "Login failed")));
  } catch (e) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("Unexpected error: $e")));
  }
}
