import 'dart:typed_data';

import 'package:app_flutter/screens/testscreen.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:mqtt_client/mqtt_client.dart';

class BodyStream extends StatefulWidget {
  const BodyStream({
    Key? key,
    required this.widget,
  }) : super(key: key);

  final TestScreen widget;

  @override
  State<BodyStream> createState() => _BodyStreamState();
}

class _BodyStreamState extends State<BodyStream> {

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.width < 600
          ? MediaQuery.of(context).size.height / 1.2
          : MediaQuery.of(context).size.height,
      child: Center(
        child: Container(
          color: Colors.black,
          child: StreamBuilder(
            stream: widget.widget.client.updates,
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

                final jpegImage = img.decodeJpg(recMess.payload.message);

                return Container(
                    child: Image.memory(
                  img.encodeJpg(jpegImage!) as Uint8List,
                  gaplessPlayback: true,
                ));
              }
            },
          ),
        ),
      ),
    );
  }
}
