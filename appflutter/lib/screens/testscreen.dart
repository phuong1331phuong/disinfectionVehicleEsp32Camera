import 'package:app_flutter/components/joystick.dart';
import 'package:app_flutter/components/stream.dart';
import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class TestScreen extends StatefulWidget {
  MqttServerClient client;
  MqttServerClient client2;
  TestScreen({Key? key, required this.client, required this.client2})
      : super(key: key);

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  bool flashlight = false;
  bool sterilize = false;
  String topic2 = 'esp8266/control';

  void publishMessageContol(String message) {
    MqttClientPayloadBuilder? builder = MqttClientPayloadBuilder();
    builder.addString(message.toString());
    // Important: AWS IoT Core can only handle QOS of 0 or 1. QOS 2 (exactlyOnce) will fail!
    widget.client2
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
            return ControlForWindows();
          } else {
            return ControlForMobile();
          }
        }))
      ]),
    );
  }

  Widget ControlForMobile() {
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
              left: 0,
              right: 0,
              bottom: 180,
              child: Column(
                children: [
                  const Text(
                    "Phun khử khuân",
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
              top: 40,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: const Text(
                    "XE PHUN KHỬ KHUẨN ĐIỀU KHIỂN TỪ XA",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 32.0,
                    ),
                  ),
                ),
              ))
        ],
      ),
    );
  }

  Widget ControlForWindows() {
    return Stack(
      children: [
        Positioned(
          left: 20,
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
            right: 20,
            bottom: 50,
            child: Column(
              children: [
                const Text(
                  "Phun khử khuân",
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
            top: 30,
            left: 0,
            right: 0,
            child: const Center(
              child: Text(
                "XE PHUN KHỬ KHUẨN ĐIỀU KHIỂN TỪ XA",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20.0,
                ),
              ),
            ))
      ],
    );
  }
}
