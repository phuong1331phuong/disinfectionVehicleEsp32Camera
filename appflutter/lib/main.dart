import 'dart:io';
import 'dart:typed_data';

import 'package:app_flutter/screens/welcomescreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:ndialog/ndialog.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MQTT ESP32CAM VIEWER',
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData.dark(),
      home: WelcomeScreen(),
    );
  }
}
