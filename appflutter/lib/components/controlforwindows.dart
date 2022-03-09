import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

import 'joystick.dart';

class ControlForWindows extends StatefulWidget {
  MqttServerClient client;
  ControlForWindows({Key? key, required this.client}) : super(key: key);

  @override
  State<ControlForWindows> createState() => _ControlForWindowsState();
}

class _ControlForWindowsState extends State<ControlForWindows> {
  bool flashlight = false;
  bool sterilize = false;
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          left: 20,
          bottom: 30,
          child: Joystick(
            size: 150,
            callBack: (double value) {
              if (value == 1) {
                publishMessageContol("up");
              } else if (value == 2) {
                publishMessageContol("right");
              } else if (value == 3) {
                publishMessageContol("down");
              } else if (value == 4) {
                publishMessageContol("left");
              } else if (value == 0) {
                publishMessageContol("stop");
              }
            },
          ),
        ),
        Positioned(
            right: 20,
            bottom: 50,
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
                      publishMessageContol("active-sterilize");
                    } else {
                      publishMessageContol("inactive-sterilize");
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
            right: 120,
            bottom: 100,
            child: IconButton(
              icon: const Icon(
                Icons.brightness_1,
                size: 50,
                color: Colors.white,
              ),
              onPressed: () {
                publishMessageContol("alert");
              },
            )),
        Positioned(
            right: 20,
            bottom: 100,
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
                      publishMessageContol("active-flashlight");
                    } else {
                      publishMessageContol("inactive-flashlight");
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
