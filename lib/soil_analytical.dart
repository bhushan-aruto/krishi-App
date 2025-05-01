// import 'dart:async';
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:syncfusion_flutter_gauges/gauges.dart';
// import 'package:loading_indicator/loading_indicator.dart';

// import 'package:smart_park_assist/m_cli.dart';

// class SoilAnalyticalPage extends StatefulWidget {
//   const SoilAnalyticalPage({super.key});

//   @override
//   State<SoilAnalyticalPage> createState() => _SoilAnalyticalPageState();
// }

// class _SoilAnalyticalPageState extends State<SoilAnalyticalPage> {
//   double _currentMoisture = 0.0; // Initial moisture
//   final MqttClientManager _mqttClientManager = MqttClientManager();
//   final String _subscribeTopic = "agriconnect/moisture";
//   final String _clientId = "soilAnalyzerClient"; // Client ID for MQTT
//   bool _isConnected = false; // Track connection status

//   @override
//   void initState() {
//     super.initState();
//     _connectToMqtt();
//   }

//   @override
//   void dispose() {
//     _mqttClientManager.disconnect(); // Disconnect when leaving page
//     super.dispose();
//   }

//   Future<void> _connectToMqtt() async {
//     _mqttClientManager.onMessageReceived = (topic, payload) {
//       if (topic == _subscribeTopic) {
//         _handleIncomingMessage(payload);
//       }
//     };

//     _mqttClientManager.client?.onConnected = () {
//       setState(() {
//         _isConnected = true;
//       });
//     };

//     _mqttClientManager.client?.onDisconnected = () {
//       setState(() {
//         _isConnected = false;
//       });
//     };

//     await _mqttClientManager.initializeMqtt(_subscribeTopic, _clientId);

//     setState(() {
//       _isConnected = _mqttClientManager.isConnected;
//     });
//   }

//   void _handleIncomingMessage(String payload) {
//     try {
//       final Map<String, dynamic> data = jsonDecode(payload);
//       if (data.containsKey('moist')) {
//         double moisture = (data['moist']).toDouble();
//         setState(() {
//           _currentMoisture = moisture;
//         });
//       }
//     } catch (e) {
//       print('Error decoding moisture payload: $e');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         iconTheme: const IconThemeData(
//           color: Colors.white,
//         ),
//         title: const Text(
//           'Soil Moisture Analytics',
//           style: TextStyle(
//             color: Colors.white,
//           ),
//         ),
//         backgroundColor: const Color.fromARGB(255, 3, 197, 68),
//       ),
//       body: SingleChildScrollView(
//         child: Center(
//           child: Padding(
//             padding:
//                 const EdgeInsets.symmetric(vertical: 30.0, horizontal: 16.0),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 SfRadialGauge(
//                   axes: <RadialAxis>[
//                     RadialAxis(
//                       minimum: 0,
//                       maximum: 100,
//                       ranges: <GaugeRange>[
//                         GaugeRange(
//                             startValue: 0, endValue: 30, color: Colors.red),
//                         GaugeRange(
//                             startValue: 30, endValue: 70, color: Colors.orange),
//                         GaugeRange(
//                             startValue: 70, endValue: 100, color: Colors.green),
//                       ],
//                       pointers: <GaugePointer>[
//                         NeedlePointer(
//                           value: _currentMoisture,
//                           enableAnimation: true,
//                           animationType: AnimationType.ease,
//                           needleColor: Colors.black,
//                           knobStyle: const KnobStyle(color: Colors.black),
//                         ),
//                       ],
//                       annotations: <GaugeAnnotation>[
//                         GaugeAnnotation(
//                           widget: Text(
//                             '${_currentMoisture.toStringAsFixed(1)}%',
//                             style: const TextStyle(
//                               fontSize: 25,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                           angle: 90,
//                           positionFactor: 0.8,
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 30),
//                 Text(
//                   '${_currentMoisture.toStringAsFixed(1)}%',
//                   style: const TextStyle(
//                     fontSize: 40,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.black87,
//                   ),
//                 ),
//                 const SizedBox(height: 20),
//                 Column(
//                   children: [
//                     SizedBox(
//                       width: 50,
//                       height: 50,
//                       child: LoadingIndicator(
//                         indicatorType: Indicator.ballPulse,
//                         colors: [_isConnected ? Colors.green : Colors.red],
//                         strokeWidth: 2,
//                       ),
//                     ),
//                     const SizedBox(height: 10),
//                     Text(
//                       _isConnected ? 'Connected' : 'Disconnected',
//                       style: TextStyle(
//                         fontSize: 20,
//                         color: _isConnected ? Colors.green : Colors.red,
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

import 'package:smart_park_assist/m_cli.dart';

class SoilAnalyticalPage extends StatefulWidget {
  const SoilAnalyticalPage({super.key});

  @override
  State<SoilAnalyticalPage> createState() => _SoilAnalyticalPageState();
}

class _SoilAnalyticalPageState extends State<SoilAnalyticalPage> {
  double _currentMoisture = 0.0;
  final MqttClientManager _mqttClientManager = MqttClientManager();
  final String _subscribeTopic = "agriconnect/moisture";
  final String _clientId = "soilAnalyzerClient";
  bool _isConnected = false;

  @override
  void initState() {
    super.initState();
    _connectToMqtt();
  }

  @override
  void dispose() {
    _mqttClientManager.disconnect();
    super.dispose();
  }

  Future<void> _connectToMqtt() async {
    _mqttClientManager.onMessageReceived = (topic, payload) {
      if (topic == _subscribeTopic) {
        _handleIncomingMessage(payload);
      }
    };

    _mqttClientManager.client?.onConnected = () {
      setState(() {
        _isConnected = true;
      });
    };

    _mqttClientManager.client?.onDisconnected = () {
      setState(() {
        _isConnected = false;
      });
    };

    await _mqttClientManager.initializeMqtt(_subscribeTopic, _clientId);

    setState(() {
      _isConnected = _mqttClientManager.isConnected;
    });
  }

  void _handleIncomingMessage(String payload) {
    try {
      final Map<String, dynamic> data = jsonDecode(payload);
      if (data.containsKey('moist')) {
        double moisture = (data['moist']).toDouble();
        setState(() {
          _currentMoisture = moisture;
        });
      }
    } catch (e) {
      print('Error decoding moisture payload: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // pure white background
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        title: const Text(
          'Soil Moisture Analytics',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 3, 197, 68),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 30.0, horizontal: 16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SfRadialGauge(
                  axes: <RadialAxis>[
                    RadialAxis(
                      minimum: 0,
                      maximum: 100,
                      ranges: <GaugeRange>[
                        GaugeRange(
                            startValue: 0, endValue: 30, color: Colors.red),
                        GaugeRange(
                            startValue: 30, endValue: 70, color: Colors.orange),
                        GaugeRange(
                            startValue: 70, endValue: 100, color: Colors.green),
                      ],
                      pointers: <GaugePointer>[
                        NeedlePointer(
                          value: _currentMoisture,
                          enableAnimation: true,
                          animationType: AnimationType.ease,
                          needleColor: Colors.black,
                          knobStyle: const KnobStyle(color: Colors.black),
                        ),
                      ],
                      annotations: <GaugeAnnotation>[
                        GaugeAnnotation(
                          widget: Text(
                            '${_currentMoisture.toStringAsFixed(1)}%',
                            style: const TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          angle: 90,
                          positionFactor: 0.8,
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                Text(
                  '${_currentMoisture.toStringAsFixed(1)}%',
                  style: const TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 20),
                Column(
                  children: [
                    Icon(
                      _isConnected ? Icons.check_circle : Icons.cancel,
                      size: 40,
                      color: _isConnected ? Colors.green : Colors.red,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _isConnected ? 'Connected' : 'Disconnected',
                      style: TextStyle(
                        fontSize: 20,
                        color: _isConnected ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
