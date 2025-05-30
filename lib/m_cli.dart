import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class MqttClientManager {
  MqttServerClient? client;
  Function(String topic, String payload)? onMessageReceived;

  // Track connection status
  bool _isConnected = false;

  // Getter for isConnected
  bool get isConnected => _isConnected;

  // Initialize MQTT client
  Future<void> initializeMqtt(String subscribeTopic, String clientId) async {
    client = MqttServerClient.withPort(
        "agriconnect.mqtt.vsensetech.in", clientId, 1883);
    client!.keepAlivePeriod = 60;
    client!.onConnected = onConnected;
    client!.onDisconnected = onDisconnected;
    client!.onSubscribed = onSubscribed;
    client!.onUnsubscribed = onUnsubscribed;
    client!.pongCallback = pong;

    final connMessage = MqttConnectMessage()
        .withClientIdentifier(clientId)
        .withWillTopic('willtopic')
        .withWillMessage('My Will message')
        .startClean()
        .withWillQos(MqttQos.atLeastOnce);

    client!.connectionMessage = connMessage;

    try {
      await client!.connect();
    } catch (e) {
      client!.disconnect();
    }

    if (client!.connectionStatus!.state == MqttConnectionState.connected) {
      _isConnected = true; // Set connection status to true
      _subscribeToTopic(subscribeTopic);
    } else {
      _isConnected = false; // Set connection status to false
      client!.disconnect();
    }
  }

  // Callback when connected
  void onConnected() {
    print("Connected");
  }

  // Callback when disconnected
  void onDisconnected() {
    print("Disconnected");
    _isConnected = false; // Update connection status
  }

  // Callback when subscribed to a topic
  void onSubscribed(String topic) {
    print("Subscribed to $topic");
  }

  // Callback when unsubscribed from a topic
  void onUnsubscribed(String? topic) {
    print("Unsubscribed from $topic");
  }

  // Pong callback
  void pong() {
    print("Pong");
  }

  // Subscribe to a topic
  void _subscribeToTopic(String subTop) {
    client!.subscribe(subTop, MqttQos.atLeastOnce);

    client!.updates!.listen((List<MqttReceivedMessage<MqttMessage>> c) {
      final MqttPublishMessage recMess = c[0].payload as MqttPublishMessage;
      final String payload =
          MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
      print('Received message: $payload from topic: ${c[0].topic}>');

      if (onMessageReceived != null) {
        onMessageReceived!(c[0].topic, payload);
      }
    });
  }

  // Publish a message
  void publishMessage({required String topic, required String message}) {
    if (client == null ||
        client!.connectionStatus!.state != MqttConnectionState.connected) {
      print('MQTT Client is not connected');
      return;
    }

    final builder = MqttClientPayloadBuilder();
    builder.addString(message);

    try {
      client!.publishMessage(topic, MqttQos.atLeastOnce, builder.payload!);
      print('Published message: "$message" to topic: "$topic"');
    } catch (e) {
      print('Error publishing message: $e');
    }
  }

  // Disconnect from MQTT
  Future<void> disconnect() async {
    client!.disconnect();
    _isConnected = false; // Update connection status when disconnected
  }
}
