import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../doctor/presentation/screens/doctor_home_screen.dart';

Future<void> validate_email_password(
  BuildContext context,
  FirebaseAuth auth,
  TextEditingController emailController,
  TextEditingController passwordController,
) async {
  try {
    final cred = await auth.signInWithEmailAndPassword(
      email: emailController.text.trim(),
      password: passwordController.text,
    );

    final uid = cred.user!.uid;
    final firestore = FirebaseFirestore.instance;

    final snap = await firestore.collection("users").doc(uid).get();
    final role = snap.data()?["role"] ?? "patient";

    if (!context.mounted) return;

    if (role == "doctor") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const DoctorHomeScreen()),
      );
    } else {
      // PatientHomeScreen
    }
  } on FirebaseAuthException catch (e) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(e.message ?? "Login failed")));
  }
}
