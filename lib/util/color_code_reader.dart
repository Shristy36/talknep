import 'package:flutter/material.dart';

class HexColor extends Color {
  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));

  static int _getColorFromHex(String hexColor) {
    String colorStr = hexColor.toUpperCase().replaceAll("#", "");
    if (colorStr.length == 6) {
      colorStr = "FF" + colorStr;
    }
    return int.parse(colorStr, radix: 16);
  }
}
