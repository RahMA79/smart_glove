import 'package:cloud_firestore/cloud_firestore.dart';

/// Reads patient name from Firestore:
/// users/{uid} -> field: name
Future<String?> getPatientName(String uid) async {
  try {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();

    if (!doc.exists) return null;

    final data = doc.data();
    if (data == null) return null;

    final name = data['name'];
    if (name == null) return null;

    return name.toString();
  } catch (e) {
    // اختياري: غيري print بـ logger عندك
    print('getPatientName error: $e');
    return null;
  }
}
