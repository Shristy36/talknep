import 'package:flutter/material.dart';

class Sizer {
  static late MediaQueryData _mediaQueryData;
  static late double screenWidth;
  static late double screenHeight;
  static late double blockWidth;
  static late double blockHeight;
  static late double textScaleFactor;

  static void init(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);
    screenWidth = _mediaQueryData.size.width;
    screenHeight = _mediaQueryData.size.height;
    blockWidth = screenWidth / 100;
    blockHeight = screenHeight / 100;
    textScaleFactor = _mediaQueryData.textScaler.scale(1.0);
  }

  static double w(double widthPercent) => blockWidth * widthPercent;
  static double h(double heightPercent) => blockHeight * heightPercent;

  static double sp(double fontSizePercent) =>
      (blockWidth * fontSizePercent) / textScaleFactor;
}

extension SizerExtension on num {
  double get w => Sizer.w(toDouble());
  double get h => Sizer.h(toDouble());
  double get sp => Sizer.sp(toDouble());
}
