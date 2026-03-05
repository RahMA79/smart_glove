import 'package:flutter/material.dart';

class doctorrequest extends StatefulWidget {
  const doctorrequest({super.key});

  @override
  State<doctorrequest> createState() => _doctorrequestState();
}

class _doctorrequestState extends State<doctorrequest> {
  // ليستة دكاترة (مؤقتة – بعدين تربطها بـ Firebase أو API)
  final List<String> doctors = [
    
    "Dr Mohamed",
    "Dr Seif",
    "Dr Rahma",
    "Dr Sara",
    "Dr Ali",
  ];

  List<String> filteredDoctors = [];
  String? selectedDoctor;

  @override
  void initState() {
    super.initState();
    filteredDoctors = doctors;
  }

  void searchDoctor(String value) {
    setState(() {
      filteredDoctors = doctors
          .where((doctor) =>
              doctor.toLowerCase().contains(value.toLowerCase()))
          .toList();
    });
  }

  void sendRequest() {
    if (selectedDoctor == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a doctor")),
      );
      return;
    }

    // هنا مكان إرسال الريكويست (Firebase / API)
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Request sent to $selectedDoctor")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text("Select Doctor",style: TextStyle(color: Colors.white),),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// 🔍 Search Bar
            TextField(
              onChanged: searchDoctor,
              decoration: const InputDecoration(
                labelText: 'Search',
                hintText: "Enter doctor name",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            /// 👨‍⚕️ Doctors List
            Expanded(
              child: ListView.builder(
                itemCount: filteredDoctors.length,
                itemBuilder: (context, index) {
                  final doctor = filteredDoctors[index];
                  return Card(
                    child: ListTile(
                      title: Text(doctor),
                      trailing: selectedDoctor == doctor
                          ? const Icon(Icons.check, color: Colors.green)
                          : null,
                      onTap: () {
                        setState(() {
                          selectedDoctor = doctor;
                        });
                      },
                    ),
                  );
                },
              ),
            ),

            /// 📩 Send Request Button
            SizedBox(
              width: double.infinity,
              child: MaterialButton(
                color: Colors.blue,
                onPressed: sendRequest,
                child: const Text(
                  "Send Request",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
