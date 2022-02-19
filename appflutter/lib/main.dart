import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:ndialog/ndialog.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MQTT ESP32CAM VIEWER',
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData.dark(),
      home: MQTTClient(),
    );
  }
}

class MQTTClient extends StatefulWidget {
  const MQTTClient({Key? key}) : super(key: key);

  @override
  _MQTTClientState createState() => _MQTTClientState();
}

class _MQTTClientState extends State<MQTTClient> {
  String statusText = "Status Text";
  bool isConnected = false;
  TextEditingController idTextController = TextEditingController();

  final client = MqttServerClient.withPort(
      "a3ylcu9d7zkfu-ats.iot.ap-southeast-1.amazonaws.com", "flutter", 8883);
  @override
  void dispose() {
    idTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    final bool hasShortWidth = width < 600;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [header(), body(hasShortWidth), footer()],
        ),
      ),
    );
  }

  Widget header() {
    return Expanded(
      child: Container(
        child: Center(
          child: Text(
            'ESP32CAM Viewer\n- AWS IoT -',
            style: TextStyle(
                fontSize: 28, color: Colors.white, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ),
      ),
      flex: 3,
    );
  }

  Widget body(bool hasShortWidth) {
    return Expanded(
      child: Container(
        child: hasShortWidth
            ? Column(
                children: [bodyMenu(), Expanded(child: bodySteam())],
              )
            : Row(
                children: [
                  Expanded(
                    child: bodyMenu(),
                    flex: 2,
                  ),
                  Expanded(
                    child: bodySteam(),
                    flex: 8,
                  )
                ],
              ),
      ),
      flex: 20,
    );
  }

  Widget bodyMenu() {
    return Container(
      color: Colors.black26,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextFormField(
                enabled: !isConnected,
                controller: idTextController,
                decoration: InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: 'MQTT Client Id',
                    labelStyle: TextStyle(fontSize: 10),
                    suffixIcon: IconButton(
                      icon: Icon(Icons.subdirectory_arrow_left),
                      onPressed: _connect,
                    ))),
          ),
          isConnected
              ? TextButton(onPressed: _disconnect, child: Text('Disconnect'))
              : Container()
        ],
      ),
    );
  }

  Widget bodySteam() {
    return Container(
      color: Colors.black,
      child: StreamBuilder(
        stream: client.updates,
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            );
          else {
            final mqttReceivedMessages =
                snapshot.data as List<MqttReceivedMessage<MqttMessage?>>?;

            final recMess =
                mqttReceivedMessages![0].payload as MqttPublishMessage;

            // print("\n\n\n\n\n\n\n\n\n\nhahaha\n\n\n\n\n\n\n\n\n");
            final jpegImage = img.decodeJpg(recMess.payload.message);

            // print(
            //     'img width = ${jpegImage.width}, height = ${jpegImage.height}');
            return Container(
                child: Image.memory(
              img.encodeJpg(jpegImage!) as Uint8List,
              gaplessPlayback: true,
            ));
          }
        },
      ),
    );
  }

  Widget footer() {
    return Expanded(
      child: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        child: Text(
          statusText,
          style: TextStyle(
              fontWeight: FontWeight.normal, color: Colors.amberAccent),
        ),
      ),
      flex: 1,
    );
  }

  _connect() async {
    if (idTextController.text.trim().isNotEmpty) {
      ProgressDialog progressDialog = ProgressDialog(context,
          blur: 0,
          dialogTransitionType: DialogTransitionType.Shrink,
          dismissable: false);
      progressDialog.setLoadingWidget(CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation(Colors.red),
      ));
      progressDialog
          .setMessage(Text("Please Wait, Connecting to AWS IoT MQTT Broker"));
      progressDialog.setTitle(Text("Connecting"));
      progressDialog.show();

      isConnected = await mqttConnect(idTextController.text.trim());
      progressDialog.dismiss();
    }
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

    // context.setClientAuthorities('assets/certs/RootCA.pem');
    // context.usePrivateKey('assets/certs/Private.pem.key');
    // context.useCertificateChain('assets/certs/DeviceCertificate.pem.crt');
    //
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
    // client.updates!.listen((List<MqttReceivedMessage<MqttMessage>> c) {
    //   final recMess = c[0].payload as MqttPublishMessage;
    //   print("\n\n\n\n\n\nmessage\n\n\n\n\n\n");
    //   final pt =
    //       MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
    //   print(
    //       'EXAMPLE::Change notification:: topic is <${c[0].topic}>, payload is <-- $pt -->');
    //   print('');
    // });
    return true;
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
    setStatus("Client connection was successful");
  }

  void onDisconnected() {
    setStatus("Client Disconnected");
    isConnected = false;
  }

  void pong() {
    print('Ping response client callback invoked');
  }
}
