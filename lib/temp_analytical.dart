// import 'dart:async';
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:syncfusion_flutter_gauges/gauges.dart';
// import 'package:loading_indicator/loading_indicator.dart';

// import 'package:smart_park_assist/m_cli.dart';

// class TempAnalyticalPage extends StatefulWidget {
//   const TempAnalyticalPage({super.key});

//   @override
//   State<TempAnalyticalPage> createState() => _TempAnalyticalPageState();
// }

// class _TempAnalyticalPageState extends State<TempAnalyticalPage> {
//   double _currentTemperature = 0.0;
//   final MqttClientManager _mqttClientManager = MqttClientManager();
//   final String _subscribeTopic = "agriconnect/temp";
//   final String _clientId = "tempAnalyzerClient";
//   bool _isConnected = false;

//   @override
//   void initState() {
//     super.initState();
//     _connectToMqtt();
//   }

//   @override
//   void dispose() {
//     _mqttClientManager.disconnect();
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
//       if (data.containsKey('temp')) {
//         double temp = (data['temp']).toDouble();
//         setState(() {
//           _currentTemperature = temp;
//         });
//       }
//     } catch (e) {
//       print('Error decoding temperature payload: $e');
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
//           'Temperature Analytics',
//           style: TextStyle(
//             color: Colors.white,
//           ),
//         ),
//         backgroundColor: const Color.fromARGB(255, 3, 197, 68),
//       ),
//       body: SingleChildScrollView(
//         child: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               const SizedBox(height: 30),
//               SfRadialGauge(
//                 axes: <RadialAxis>[
//                   RadialAxis(
//                     minimum: 0,
//                     maximum: 100,
//                     ranges: <GaugeRange>[
//                       GaugeRange(
//                           startValue: 0, endValue: 30, color: Colors.green),
//                       GaugeRange(
//                           startValue: 30, endValue: 70, color: Colors.orange),
//                       GaugeRange(
//                           startValue: 70, endValue: 100, color: Colors.red),
//                     ],
//                     pointers: <GaugePointer>[
//                       NeedlePointer(
//                         value: _currentTemperature,
//                         enableAnimation: true,
//                         animationType: AnimationType.ease,
//                         needleColor: Colors.black,
//                         knobStyle: const KnobStyle(color: Colors.black),
//                       ),
//                     ],
//                     annotations: <GaugeAnnotation>[
//                       GaugeAnnotation(
//                         widget: Text(
//                           '${_currentTemperature.toStringAsFixed(1)}°C',
//                           style: const TextStyle(
//                             fontSize: 25,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         angle: 90,
//                         positionFactor: 0.8,
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 30),
//               Text(
//                 '${_currentTemperature.toStringAsFixed(1)}°C',
//                 style: const TextStyle(
//                   fontSize: 40,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.black87,
//                 ),
//               ),
//               const SizedBox(height: 20),
//               Column(
//                 children: [
//                   SizedBox(
//                     width: 50,
//                     height: 50,
//                     child: LoadingIndicator(
//                       indicatorType: Indicator.ballPulse,
//                       colors: [_isConnected ? Colors.green : Colors.red],
//                       strokeWidth: 2,
//                     ),
//                   ),
//                   const SizedBox(height: 10),
//                   Text(
//                     _isConnected ? 'Connected' : 'Disconnected',
//                     style: TextStyle(
//                       fontSize: 20,
//                       color: _isConnected ? Colors.green : Colors.red,
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 30),
//             ],
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

class TempAnalyticalPage extends StatefulWidget {
  const TempAnalyticalPage({super.key});

  @override
  State<TempAnalyticalPage> createState() => _TempAnalyticalPageState();
}

class _TempAnalyticalPageState extends State<TempAnalyticalPage> {
  double _currentTemperature = 0.0;
  final MqttClientManager _mqttClientManager = MqttClientManager();
  final String _subscribeTopic = "agriconnect/temp";
  final String _clientId = "tempAnalyzerClient";
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
      if (data.containsKey('temp')) {
        double temp = (data['temp']).toDouble();
        setState(() {
          _currentTemperature = temp;
        });
      }
    } catch (e) {
      print('Error decoding temperature payload: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        title: const Text(
          'Temperature Analytics',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 3, 197, 68),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 30),
              SfRadialGauge(
                axes: <RadialAxis>[
                  RadialAxis(
                    minimum: 0,
                    maximum: 100,
                    ranges: <GaugeRange>[
                      GaugeRange(
                          startValue: 0, endValue: 30, color: Colors.green),
                      GaugeRange(
                          startValue: 30, endValue: 70, color: Colors.orange),
                      GaugeRange(
                          startValue: 70, endValue: 100, color: Colors.red),
                    ],
                    pointers: <GaugePointer>[
                      NeedlePointer(
                        value: _currentTemperature,
                        enableAnimation: true,
                        animationType: AnimationType.ease,
                        needleColor: Colors.black,
                        knobStyle: const KnobStyle(color: Colors.black),
                      ),
                    ],
                    annotations: <GaugeAnnotation>[
                      GaugeAnnotation(
                        widget: Text(
                          '${_currentTemperature.toStringAsFixed(1)}°C',
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
                '${_currentTemperature.toStringAsFixed(1)}°C',
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
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
