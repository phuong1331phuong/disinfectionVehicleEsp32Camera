import 'package:flutter/material.dart';
import 'package:control_pad/control_pad.dart';

class Joystick extends StatelessWidget {
  double size;
  Function callBack;
  Joystick({Key? key, required this.size, required this.callBack})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    double message = 0;
    return JoystickView(
      size: size,
      onDirectionChanged: (horizonta, vertical) {
        double value = changesInValue(horizonta);
        if (value != message) {
          message = value;
          callBack(message);
          print(message);
        } else {}
      },
    );
  }
}

changesInValue(double value) {
  if (value > 0) {
    if (value < 45 || value > 315) {
      return 1.0;
    } else if (135 > value && value >= 45) {
      return 2.0;
    } else if (225 > value && value >= 135) {
      return 3.0;
    } else if (315 > value && value >= 225) {
      return 4.0;
    }
  }
  return 0.0;
}
