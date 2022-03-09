import 'package:app_flutter/components/controlformobile.dart';
import 'package:app_flutter/components/controlforwindows.dart';
import 'package:app_flutter/components/stream.dart';
import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class TestScreen extends StatefulWidget {
  MqttServerClient client;
  TestScreen({Key? key, required this.client}) : super(key: key);

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  bool flashlight = false;
  bool sterilize = false;

  void publishMessageContol(String message) {
    const topic2 = 'esp32/control';
    final builder = MqttClientPayloadBuilder();
    builder.addString(message.toString());
    // Important: AWS IoT Core can only handle QOS of 0 or 1. QOS 2 (exactlyOnce) will fail!
    widget.client
        .publishMessage(topic2, MqttQos.atLeastOnce, builder.payload()!);
    print(message.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: [
        BodyStream(widget: widget),
        LayoutBuilder(builder: ((context, constraints) {
          if (constraints.maxWidth > 600) {
            return ControlForWindows(
              client: widget.client,
            );
          } else {
            return ControlForMobile(
              client: widget.client,
            );
          }
        }))
      ]),
    );
  }
}
