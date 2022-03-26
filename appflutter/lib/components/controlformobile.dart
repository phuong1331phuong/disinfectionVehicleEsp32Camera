import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

import 'joystick.dart';

class ControlForMobile extends StatefulWidget {
  MqttServerClient client;
  ControlForMobile({Key? key, required this.client}) : super(key: key);

  @override
  State<ControlForMobile> createState() => _ControlForMobileState();
}

class _ControlForMobileState extends State<ControlForMobile> {
  bool flashlight = false;
  bool sterilize = false;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        children: [
          Positioned(
            left: 0,
            right: 0,
            bottom: 30,
            child: Joystick(
              size: 150,
              callBack: (double value) {
                if (value == 1) {
                  publishMessageContol("1");
                } else if (value == 2) {
                  publishMessageContol("2");
                } else if (value == 3) {
                  publishMessageContol("3");
                } else if (value == 4) {
                  publishMessageContol("4");
                } else if (value == 0) {
                  publishMessageContol("0");
                }
              },
            ),
          ),
          Positioned(
              left: 20,
              bottom: 200,
              child: Column(
                children: [
                  const Text(
                    "sterilize",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.yellow),
                  ),
                  Switch.adaptive(
                    activeColor: Colors.green,
                    onChanged: (bool value) {
                      if (value == true) {
                        publishMessageContol("A");
                      } else {
                        publishMessageContol("a");
                      }
                      print(value);
                      setState(() {
                        sterilize = value;
                      });
                    },
                    value: sterilize,
                  ),
                ],
              )),
          Positioned(
              right: 0,
              left: 0,
              bottom: 220,
              child: IconButton(
                icon: const Icon(
                  Icons.brightness_1,
                  size: 50,
                  color: Color.fromARGB(255, 255, 208, 0),
                ),
                onPressed: () {
                  publishMessageContol("O");
                },
              )),
          Positioned(
              right: 20,
              bottom: 200,
              child: Column(
                children: [
                  const Text(
                    "flashlight",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.yellow),
                  ),
                  Switch.adaptive(
                    activeColor: Colors.green,
                    onChanged: (bool value) {
                      if (value == true) {
                        publishMessageContol("X");
                      } else {
                        publishMessageContol("x");
                      }
                      print(value);
                      setState(() {
                        flashlight = value;
                      });
                    },
                    value: flashlight,
                  ),
                ],
              )),
        ],
      ),
    );
  }

  void publishMessageContol(String message) {
    const topic2 = 'esp32/control';
    final builder = MqttClientPayloadBuilder();
    builder.addString(message.toString());
    // Important: AWS IoT Core can only handle QOS of 0 or 1. QOS 2 (exactlyOnce) will fail!
    widget.client
        .publishMessage(topic2, MqttQos.atLeastOnce, builder.payload()!);
    print(message.toString());
  }
}
