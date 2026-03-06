/*
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';

class SensorScreen extends StatefulWidget {
  @override
  _SensorScreenState createState() => _SensorScreenState();
}


class _SensorScreenState extends State<SensorScreen> {

  String url = "http://192.168.4.1/data"; // IP ثابت على ESP32 AP

  int ebham = 0;
  int sababa = 0;
  int wosta = 0;
  int bensr = 0;
  int khansr = 0;
  int emg = 0;
  int peak = 0;

  @override
  void initState() {
    super.initState();
    Timer.periodic(Duration(milliseconds: 100), (_) {
      fetchData();
    });
  }

  Future<void> fetchData() async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          ebham = data['ebham'];
          sababa = data['sababa'];
          wosta = data['wosta'];
          bensr = data['bensr'];
          khansr = data['khansr'];
          emg = data['emg'];
          peak = data['peak'];
        });
      }
    } catch (e) {}
  }

  Widget buildText(String title, int value) {
    return Text("$title: $value",
        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.tr('glove_data'))),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            buildText(context.tr('finger_thumb'), ebham),
            buildText(context.tr('finger_index'), sababa),
            buildText(context.tr('finger_middle'), wosta),
            buildText(context.tr('finger_ring'), bensr),
            buildText(context.tr('finger_pinky'), khansr),
            SizedBox(height: 20),
            buildText("EMG Avg", emg),
            buildText("EMG Peak", peak),
          ],
        ),
      ),
    );
  }
}*/
/*

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';

class SensorScreen extends StatefulWidget {
  @override
  _SensorScreenState createState() => _SensorScreenState();
}

class _SensorScreenState extends State<SensorScreen> {

  String dataUrl = "http://192.168.4.1/data";
  String servoUrl = "http://192.168.4.1/servo";

  int ebham = 0;
  int sababa = 0;
  int wosta = 0;
  int bensr = 0;
  int khansr = 0;

  double rms = 0;
  double mav = 0;
  double variance = 0;
  int zeroCross = 0;
  int peak = 0;

  // Servo angles
  double servoEbham = 90;
  double servoSababa = 90;
  double servoWosta = 90;
  double servoBensr = 90;
  double servoKhansr = 90;

  @override
  void initState() {
    super.initState();
    Timer.periodic(Duration(milliseconds: 300), (_) {
      fetchData();
    });
  }

  Future<void> fetchData() async {
    try {
      final response = await http.get(Uri.parse(dataUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        setState(() {
          ebham = data['ebham'];
          sababa = data['sababa'];
          wosta = data['wosta'];
          bensr = data['bensr'];
          khansr = data['khansr'];

          rms = (data['rms'] ?? 0).toDouble();
          mav = (data['mav'] ?? 0).toDouble();
          variance = (data['variance'] ?? 0).toDouble();
          zeroCross = data['zeroCross'] ?? 0;
          peak = data['peak'] ?? 0;
        });
      }
    } catch (e) {}
  }

  Future<void> sendServoCommand() async {
    String fullUrl =
        "$servoUrl?ebham=${servoEbham.toInt()}&sababa=${servoSababa.toInt()}&wosta=${servoWosta.toInt()}&bensr=${servoBensr.toInt()}&khansr=${servoKhansr.toInt()}";

    try {
      await http.get(Uri.parse(fullUrl));
    } catch (e) {}
  }

  Widget buildSlider(String title, double value, Function(double) onChanged) {
    return Column(
      children: [
        Text("$title: ${value.toInt()}",
            style: TextStyle(fontWeight: FontWeight.bold)),
        Slider(
          value: value,
          min: 0,
          max: 180,
          divisions: 180,
          label: value.toInt().toString(),
          onChanged: (newValue) {
            setState(() {
              onChanged(newValue);
            });
            sendServoCommand();
          },
        ),
      ],
    );
  }

  Widget buildText(String title, dynamic value) {
    return Text("$title: $value",
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.tr('glove_control_emg'))),
      body: SingleChildScrollView(
        child: Column(
          children: [

            SizedBox(height: 20),

            // ===== FLEX DATA =====
            buildText(context.tr('finger_thumb'), ebham),
            buildText(context.tr('finger_index'), sababa),
            buildText(context.tr('finger_middle'), wosta),
            buildText(context.tr('finger_ring'), bensr),
            buildText(context.tr('finger_pinky'), khansr),

            SizedBox(height: 20),

            // ===== EMG =====
            buildText("RMS", rms.toStringAsFixed(2)),
            buildText("MAV", mav.toStringAsFixed(2)),
            buildText("Variance", variance.toStringAsFixed(2)),
            buildText("ZeroCross", zeroCross),
            buildText("Peak", peak),

            SizedBox(height: 30),
            Divider(),

            Text(context.tr('servo_control'),
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue)),

            // ===== Servo Sliders =====
            buildSlider(context.tr('finger_thumb_servo'), servoEbham,
                (v) => servoEbham = v),

            buildSlider(context.tr('finger_index_servo'), servoSababa,
                (v) => servoSababa = v),

            buildSlider(context.tr('finger_middle_servo'), servoWosta,
                (v) => servoWosta = v),

            buildSlider(context.tr('finger_ring_servo'), servoBensr,
                (v) => servoBensr = v),

            buildSlider(context.tr('finger_pinky_servo'), servoKhansr,
                (v) => servoKhansr = v),

            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
*/
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:smart_glove/core/localization/app_localizations.dart';

class SensorScreen extends StatefulWidget {
  @override
  _SensorScreenState createState() => _SensorScreenState();
}

class _SensorScreenState extends State<SensorScreen> {
  // ================= URL =================
  String dataUrl = "http://192.168.4.1/data";
  String servoUrl = "http://192.168.4.1/servo";

  // ================= FLEX DATA =================
  int ebham = 0;
  int sababa = 0;
  int wosta = 0;
  int bensr = 0;
  int khansr = 0;

  // ================= EMG DATA =================
  double rms = 0;
  double mav = 0;
  double variance = 0;
  int zeroCross = 0;
  int peak = 0;

  // ================= SERVO ANGLES =================
  double servoEbham = 90;
  double servoSababa = 90;
  double servoWosta = 90;
  double servoBensr = 90;
  double servoKhansr = 90;

  @override
  void initState() {
    super.initState();
    Timer.periodic(Duration(milliseconds: 300), (_) {
      fetchData();
    });
  }

  // ================= FETCH DATA =================
  Future<void> fetchData() async {
    try {
      final response = await http.get(Uri.parse(dataUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          ebham = data['ebham'];
          sababa = data['sababa'];
          wosta = data['wosta'];
          bensr = data['bensr'];
          khansr = data['khansr'];

          rms = (data['rms'] ?? 0).toDouble();
          mav = (data['mav'] ?? 0).toDouble();
          variance = (data['variance'] ?? 0).toDouble();
          zeroCross = data['zeroCross'] ?? 0;
          peak = data['peak'] ?? 0;
        });
      }
    } catch (e) {
      // print("Error fetching data: $e");
    }
  }

  // ================= SEND SERVO COMMAND =================
  Future<void> sendServoCommand() async {
    String fullUrl =
        "$servoUrl?ebham=${servoEbham.toInt()}&sababa=${servoSababa.toInt()}&wosta=${servoWosta.toInt()}&bensr=${servoBensr.toInt()}&khansr=${servoKhansr.toInt()}";

    try {
      await http.get(Uri.parse(fullUrl));
      await Future.delayed(Duration(milliseconds: 50)); // حماية للسيرفر
    } catch (e) {
      // print("Error sending servo command: $e");
    }
  }

  // ================= WIDGETS =================
  Widget buildSlider(String title, double value, Function(double) onChanged) {
    return Column(
      children: [
        Text("$title: ${value.toInt()}",
            style: TextStyle(fontWeight: FontWeight.bold)),
        Slider(
          value: value,
          min: 0,
          max: 180,
          divisions: 180,
          label: value.toInt().toString(),
          onChanged: (newValue) {
            setState(() {
              onChanged(newValue);
            });
          },
          onChangeEnd: (newValue) {
            sendServoCommand(); // يرسل الأمر لما تخلص السحب
          },
        ),
        SizedBox(height: 10),
      ],
    );
  }

  Widget buildText(String title, dynamic value) {
    return Text("$title: $value",
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold));
  }

  // ================= BUILD UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.tr('glove_control_emg'))),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            SizedBox(height: 10),

            // ===== FLEX DATA =====
            buildText(context.tr('finger_thumb'), ebham),
            buildText(context.tr('finger_index'), sababa),
            buildText(context.tr('finger_middle'), wosta),
            buildText(context.tr('finger_ring'), bensr),
            buildText(context.tr('finger_pinky'), khansr),
            SizedBox(height: 20),

            // ===== EMG DATA =====
            buildText("RMS", rms.toStringAsFixed(2)),
            buildText("MAV", mav.toStringAsFixed(2)),
            buildText("Variance", variance.toStringAsFixed(2)),
            buildText("ZeroCross", zeroCross),
            buildText("Peak", peak),
            SizedBox(height: 30),

            Divider(),
            SizedBox(height: 10),
            Text(context.tr('servo_control'),
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue)),
            SizedBox(height: 10),

            // ===== SERVO SLIDERS =====
            buildSlider(context.tr('finger_thumb_servo'), servoEbham, (v) => servoEbham = v),
            buildSlider(context.tr('finger_index_servo'), servoSababa, (v) => servoSababa = v),
            buildSlider(context.tr('finger_middle_servo'), servoWosta, (v) => servoWosta = v),
            buildSlider(context.tr('finger_ring_servo'), servoBensr, (v) => servoBensr = v),
            buildSlider(context.tr('finger_pinky_servo'), servoKhansr, (v) => servoKhansr = v),

            SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
