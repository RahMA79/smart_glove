import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SensorScreen extends StatefulWidget {
  const SensorScreen({super.key});

  @override
  State<SensorScreen> createState() => _SensorScreenState();
}

class _SensorScreenState extends State<SensorScreen> {
  final String dataUrl = "http://192.168.4.1/data";
  final String servoUrl = "http://192.168.4.1/servo";

  Timer? timer;
  Timer? servoTimer;

  bool isFetching = false;
  bool isConnected = false;

  // Finger data
  int ebham = 0, sababa = 0, wosta = 0, bensr = 0, khansr = 0;

  // EMG
  int rawEMG = 0;
  double rms = 0, mav = 0, variance = 0;
  int zeroCross = 0, peak = 0;

  // Servo
  double servoEbham = 90;
  double servoSababa = 90;
  double servoWosta = 90;
  double servoBensr = 90;
  double servoKhansr = 90;

  @override
  void initState() {
    super.initState();

    timer = Timer.periodic(const Duration(milliseconds: 300), (_) {
      fetchData();
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    servoTimer?.cancel();
    super.dispose();
  }

  // ================= FETCH =================
  Future<void> fetchData() async {
    if (isFetching) return;
    isFetching = true;

    try {
      final res = await http
          .get(Uri.parse(dataUrl))
          .timeout(const Duration(seconds: 2));

      if (res.statusCode == 200) {
        final d = json.decode(res.body);

        if (!mounted) return;

        setState(() {
          isConnected = true;

          ebham = d['ebham'] ?? 0;
          sababa = d['sababa'] ?? 0;
          wosta = d['wosta'] ?? 0;
          bensr = d['bensr'] ?? 0;
          khansr = d['khansr'] ?? 0;

          rawEMG = d['rawEMG'] ?? 0;
          rms = (d['rms'] ?? 0).toDouble();
          mav = (d['mav'] ?? 0).toDouble();
          variance = (d['variance'] ?? 0).toDouble();
          zeroCross = d['zeroCross'] ?? 0;
          peak = d['peak'] ?? 0;
        });
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => isConnected = false);
    }

    isFetching = false;
  }

  // ================= SERVO =================
  void scheduleServoSend() {
    servoTimer?.cancel();

    servoTimer = Timer(const Duration(milliseconds: 250), () {
      sendServoCommand();
    });
  }

  Future<void> sendServoCommand() async {
    final url =
        "$servoUrl?ebham=${servoEbham.toInt()}&sababa=${servoSababa.toInt()}&wosta=${servoWosta.toInt()}&bensr=${servoBensr.toInt()}&khansr=${servoKhansr.toInt()}";

    try {
      await http.get(Uri.parse(url)).timeout(const Duration(seconds: 2));
    } catch (_) {
      if (!mounted) return;
      setState(() => isConnected = false);
    }
  }

  // ================= UI =================
  Widget card(String title, String value) {
    return Card(
      child: ListTile(title: Text(title), trailing: Text(value)),
    );
  }

  Widget slider(String title, double value, Function(double) onChanged) {
    return Card(
      child: Column(
        children: [
          Text("$title: ${value.toInt()}"),
          Slider(
            value: value,
            min: 0,
            max: 180,
            divisions: 180,
            onChanged: (v) {
              setState(() => onChanged(v));
              scheduleServoSend();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Smart Glove")),

      body: RefreshIndicator(
        onRefresh: fetchData,
        child: ListView(
          padding: const EdgeInsets.all(12),
          children: [
            // Connection
            Container(
              padding: const EdgeInsets.all(10),
              color: isConnected ? Colors.green[100] : Colors.red[100],
              child: Text(
                isConnected ? "Connected" : "Disconnected",
                style: TextStyle(
                  color: isConnected ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 10),

            // Finger Data
            const Text("Finger Data", style: TextStyle(fontSize: 20)),
            card("Thumb", "$ebham°"),
            card("Index", "$sababa°"),
            card("Middle", "$wosta°"),
            card("Ring", "$bensr°"),
            card("Pinky", "$khansr°"),

            const SizedBox(height: 10),

            // EMG
            const Text("EMG Data", style: TextStyle(fontSize: 20)),
            card("Raw", rawEMG.toString()),
            card("RMS", rms.toStringAsFixed(2)),
            card("MAV", mav.toStringAsFixed(2)),
            card("Variance", variance.toStringAsFixed(2)),
            card("ZeroCross", zeroCross.toString()),
            card("Peak", peak.toString()),

            const SizedBox(height: 10),

            // Servo
            const Text("Servo Control", style: TextStyle(fontSize: 20)),

            slider("Thumb", servoEbham, (v) => servoEbham = v),
            slider("Index", servoSababa, (v) => servoSababa = v),
            slider("Middle", servoWosta, (v) => servoWosta = v),
            slider("Ring", servoBensr, (v) => servoBensr = v),
            slider("Pinky", servoKhansr, (v) => servoKhansr = v),
          ],
        ),
      ),
    );
  }
}
