import 'package:flutter/material.dart';
import '../../data/models/patient_request_model.dart';
import '../widgets/notifications_patient_card.dart';
import '../widgets/patient_request_card.dart';

class NewPatientRequestScreen extends StatefulWidget {
  const NewPatientRequestScreen({super.key});

  @override
  State<NewPatientRequestScreen> createState() =>
      _NewPatientRequestScreenState();
}

class _NewPatientRequestScreenState extends State<NewPatientRequestScreen> {
  final List<PatientRequestModel> _requests = [
    const PatientRequestModel(condition: "Stroke", patientName: "John Smith"),
    const PatientRequestModel(condition: "Stroke", patientName: "John Smith"),
  ];

  void _accept(int index) {
    setState(() => _requests.removeAt(index));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Request accepted")));
  }

  void _reject(int index) {
    setState(() => _requests.removeAt(index));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Request rejected")));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("New Patient Request"),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            // TODO: open drawer
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.arrow_forward),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: ListView(
            children: [
              const SizedBox(height: 8),

              ...List.generate(_requests.length, (i) {
                final req = _requests[i];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: PatientRequestCard(
                    request: req,
                    onAccept: () => _accept(i),
                    onReject: () => _reject(i),
                  ),
                );
              }),

              const SizedBox(height: 12),

              // notifications card (bottom)
              NotificationsPatientCard(
                title: "Notes Regulorss Rurn",
                subtitle: "Enacrity Eirport",
                trailing: "0 m",
                onTap: () {
                  // TODO: navigate to notifications list
                },
              ),

              const SizedBox(height: 22),
            ],
          ),
        ),
      ),
    );
  }
}
