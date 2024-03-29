import 'dart:io';
import 'dart:typed_data';
import 'dart:async';

import 'package:app_flutter/screens/homescreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:ndialog/ndialog.dart';

class WelcomeScreen extends StatefulWidget {
  @override
  State<WelcomeScreen> createState() => _WecomeScreenState();
}

class _WecomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  String statusText = "Status Text";
  bool bookmarked = false;
  bool isConnected = false;
  late final AnimationController _controller;

  TextEditingController idTextController = TextEditingController();

  final client = MqttServerClient.withPort(
      "a3ylcu9d7zkfu-ats.iot.ap-southeast-1.amazonaws.com", "flutter", 8883);

  late MqttServerClient client1;

  @override
  void initState() {
    super.initState();
    _connect();

    _controller =
        AnimationController(duration: const Duration(seconds: 2), vsync: this);
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
        if (constraints.maxWidth > 600) {
          return _windowsApp();
        } else {
          return _mobileScreen();
        }
      }),
    );
  }

  Widget _windowsApp() {
    return Center(
        widthFactor: 400,
        child: GestureDetector(
          onTap: _connect,
          child: SizedBox(
            width: 300.0,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(children: [
                Lottie.asset(
                  "assets/animation/95171-colors.json",
                  height: MediaQuery.of(context).size.height / 2,
                  // controller: _controller,
                ),
                const Positioned(
                  bottom: 20.0,
                  child: Text(
                    "WelCome",
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      height: 5,
                      fontSize: 32,
                    ),
                  ),
                ),
              ]),
            ),
          ),
        ));
  }

  Widget _mobileScreen() {
    return Center(
        widthFactor: 400,
        child: GestureDetector(
          onTap: _connect,
          child: SizedBox(
            width: 300.0,
            height: MediaQuery.of(context).size.height,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(children: [
                Lottie.asset(
                  "assets/animation/95171-colors.json",
                  height: MediaQuery.of(context).size.height / 2,
                  // controller: _controller,
                ),
                const Text(
                  "WelCome",
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    height: 5,
                    fontSize: 30,
                  ),
                ),
                // IconButton(
                //     onPressed: () {
                //       print(MediaQuery.of(context).size.height);
                //     },
                //     icon: const Icon(Icons.send))
              ]),
            ),
          ),
        ));
  }

  _connect() async {
    ProgressDialog progressDialog = ProgressDialog(context,
        blur: 0,
        dialogTransitionType: DialogTransitionType.Shrink,
        dismissable: false);

    client1 = await connect();
    isConnected = await mqttConnect("flutter");
    Timer(Duration(seconds: 3), () {});
    // progressDialog.dismiss();
  }

  _disconnect() {
    client.disconnect();
  }

  Future<bool> mqttConnect(String uniqueId) async {
    setStatus("Connecting MQTT Broker");

    // After adding your certificates to the pubspec.yaml, you can use Security Context.

    ByteData rootCA = await rootBundle.load('assets/certs/RootCA.pem');
    ByteData deviceCert =
        await rootBundle.load('assets/certs/DeviceCertificate.pem.crt');
    ByteData privateKey = await rootBundle.load('assets/certs/Private.pem.key');

    final context = SecurityContext.defaultContext;
    context.setClientAuthoritiesBytes(rootCA.buffer.asUint8List());
    context.useCertificateChainBytes(deviceCert.buffer.asUint8List());
    context.usePrivateKeyBytes(privateKey.buffer.asUint8List());

    client.securityContext = context;

    client.logging(on: false);
    client.keepAlivePeriod = 20;
    client.port = 8883;
    client.secure = true;
    client.onConnected = onConnected;
    client.onDisconnected = onDisconnected;
    client.pongCallback = pong;

    final MqttConnectMessage connMess =
        MqttConnectMessage().withClientIdentifier('flutter').startClean();
    client.connectionMessage = connMess;

    try {
      print('MQTT client connecting to AWS IoT....');
      await client.connect();
    } on Exception catch (e) {
      print('MQTT client exception - $e');
      client.disconnect();
      exit(-1);
    }
    if (client.connectionStatus!.state == MqttConnectionState.connected) {
      print("Connected to AWS Successfully!");
    } else {
      return false;
    }

    const topic2 = 'esp32/control';
    final builder = MqttClientPayloadBuilder();
    builder.addString('Hello World');
    // Important: AWS IoT Core can only handle QOS of 0 or 1. QOS 2 (exactlyOnce) will fail!
    client.publishMessage(topic2, MqttQos.atLeastOnce, builder.payload()!);
    const topic = 'esp32/stream';
    client.subscribe(topic, MqttQos.atMostOnce);
    print("hahcbhbdchbdshchsc");
    return true;
  }

  Future<MqttServerClient> connect() async {
    MqttServerClient client2 =
        MqttServerClient.withPort('broker.emqx.io', 'flutter_client', 1883);
    client2.logging(on: true);
    client2.onConnected = onConnected1;
    client2.onDisconnected = onDisconnected1;
    client2.onUnsubscribed = onUnsubscribed1 as UnsubscribeCallback?;
    client2.onSubscribed = onSubscribed1;
    client2.onSubscribeFail = onSubscribeFail1;
    client2.pongCallback = pong;

    final connMessage = MqttConnectMessage()
        .authenticateAs('phuongbgbg', '777777')
        .keepAliveFor(60)
        .withWillTopic('esp8266/control')
        .withWillMessage('Will message')
        .startClean()
        .withWillQos(MqttQos.atLeastOnce);
    client2.connectionMessage = connMessage;
    try {
      await client2.connect();
    } catch (e) {
      print('Exception: $e');
      client2.disconnect();
    }

    return client2;
  }

  void onConnected1() {
    print('Connected');
  }

// unconnected
  void onDisconnected1() {
    print('Disconnected');
  }

// subscribe to topic succeeded
  void onSubscribed1(String topic) {
    print('Subscribed topic: $topic');
  }

// subscribe to topic failed
  void onSubscribeFail1(String topic) {
    print('Failed to subscribe $topic');
  }

// unsubscribe succeeded
  void onUnsubscribed1(String topic) {
    print('Unsubscribed topic: $topic');
  }

// PING response received
  void pong1() {
    print('Ping response client callback invoked');
  }

  void setStatus(String content) {
    setState(() {
      statusText = content;
    });
  }

  Uint8List convertStringToUint8List(String str) {
    final List<int> codeUnits = str.codeUnits;
    final Uint8List unit8List = Uint8List.fromList(codeUnits);

    return unit8List;
  }

  void onConnected() {
    Navigator.of(context).push(_createRoute());
  }

  Route _createRoute() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => TestScreen(
        client: client,
        client2: client1,
      ),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0);
        const end = Offset.zero;
        final tween = Tween(begin: begin, end: end);
        final offsetAnimation = animation.drive(tween);
        return child;
      },
    );
  }

  void onDisconnected() {
    setStatus("Client Disconnected");
    isConnected = false;
  }

  void pong() {
    print('Ping response client callback invoked');
  }
}
