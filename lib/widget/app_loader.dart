import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'app_sizer.dart';

class CommonLoader extends StatelessWidget {
  final double size;
  final Color color;
  final bool fullScreen;

  const CommonLoader({
    super.key,
    this.size = 5,
    this.fullScreen = false,
    this.color = Colors.blue,
  });

  @override
  Widget build(BuildContext context) {
    final loader = SpinKitSpinningLines(
      color: color,
      lineWidth: 3.0,
      size: Sizer.h(size),
    );

    return fullScreen
        ? Container(
          child: loader,
          width: Sizer.screenWidth,
          height: Sizer.screenHeight,
          alignment: Alignment.center,
        )
        : loader;
  }

  ///Full-screen overlay loader
  //CommonLoader(fullScreen: true)

  ///Inline small loader
  //CommonLoader(size: 3, color: Colors.grey)
}
