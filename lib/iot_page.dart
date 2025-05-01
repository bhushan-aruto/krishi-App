
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mqtt_client/mqtt_client.dart' as mqtt;
import 'm_cli.dart';
import 'temp_analytical.dart';
import 'soil_analytical.dart';

class IotPage extends StatefulWidget {
  const IotPage({super.key});

  @override
  _IotPageState createState() => _IotPageState();
}

class _IotPageState extends State<IotPage> {
  bool showForm = false;
  final List<String> crops = ['Wheat', 'Rice', 'Corn', 'Sugarcane', 'Barley'];
  final List<int> values = List.generate(11, (index) => index * 10);
  String? selectedCrop;
  int? selectedMinValue;
  int? selectedMaxValue;

  MqttClientManager mqttClientManager = MqttClientManager();
  bool isConnected = false;

  @override
  void initState() {
    super.initState();
    mqttClientManager
        .initializeMqtt("agriconnect/update/moisture", "iotClientId")
        .then((_) {
      setState(() {
        isConnected = mqttClientManager.client?.connectionStatus?.state ==
            mqtt.MqttConnectionState.connected;
      });
    });
  }

  void openForm() {
    setState(() {
      showForm = true;
    });
  }

  void submitForm() {
    if (selectedMinValue != null && selectedMaxValue != null) {
      String payload = jsonEncode({
        "min": selectedMinValue,
        "max": selectedMaxValue,
      });

      mqttClientManager.publishMessage(
        topic: "agriconnect/update/moisture",
        message: payload,
      );

      setState(() {
        showForm = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'IoT Dashboard',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: showForm ? _buildForm() : _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          _buildConnectionIndicator(),
          const SizedBox(height: 40),
          _buildSection(
            icon: FontAwesomeIcons.temperatureHalf,
            title: 'Temperature',
            onAnalyticalPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const TempAnalyticalPage()),
              );
            },
            onSettingsPressed: () {},
          ),
          const SizedBox(height: 20),
          _buildSection(
            icon: FontAwesomeIcons.water,
            title: 'Soil Moisture',
            onAnalyticalPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const SoilAnalyticalPage()),
              );
            },
            onSettingsPressed: openForm,
          ),
        ],
      ),
    );
  }

  Widget _buildConnectionIndicator() {
    return Column(
      children: [
        const SizedBox(height: 10),
        Icon(
          isConnected ? Icons.check_circle : Icons.cancel,
          size: 40,
          color: isConnected ? Colors.green : Colors.red,
        ),
        const SizedBox(height: 10),
        Text(
          isConnected ? "Connected" : "Disconnected",
          style: TextStyle(
            color: isConnected ? Colors.green : Colors.red,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildSection({
    required IconData icon,
    required String title,
    required VoidCallback onAnalyticalPressed,
    required VoidCallback onSettingsPressed,
  }) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            FaIcon(icon, size: 60, color: Colors.green),
            const SizedBox(height: 20),
            Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: onAnalyticalPressed,
                  icon: const FaIcon(FontAwesomeIcons.chartLine,
                      size: 30, color: Color(0xFF009688)),
                ),
                const SizedBox(width: 20),
                IconButton(
                  onPressed: onSettingsPressed,
                  icon: const Icon(Icons.settings_rounded,
                      size: 30, color: Color(0xFF7A7A7A)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Card(
        elevation: 10,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Set Crop & Thresholds',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              DropdownButtonFormField<String>(
                decoration: _inputDecoration('Select Crop'),
                value: selectedCrop,
                items: crops
                    .map((crop) => DropdownMenuItem(
                          value: crop,
                          child: Text(crop),
                        ))
                    .toList(),
                onChanged: (value) => setState(() => selectedCrop = value),
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<int>(
                decoration: _inputDecoration('Select Min Value'),
                value: selectedMinValue,
                items: values
                    .map((val) => DropdownMenuItem(
                          value: val,
                          child: Text('$val %'),
                        ))
                    .toList(),
                onChanged: (value) => setState(() => selectedMinValue = value),
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<int>(
                decoration: _inputDecoration('Select Max Value'),
                value: selectedMaxValue,
                items: values
                    .map((val) => DropdownMenuItem(
                          value: val,
                          child: Text('$val %'),
                        ))
                    .toList(),
                onChanged: (value) => setState(() => selectedMaxValue = value),
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                  elevation: 5,
                ),
                icon: const Icon(Icons.check_circle,
                    color: Colors.white, size: 20),
                label: const Text('Submit', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(fontWeight: FontWeight.w500),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
      filled: true,
      fillColor: Colors.grey.shade100,
    );
  }
}
