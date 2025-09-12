import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talknep/constant/global.dart';
import 'package:talknep/UI/auth/login_screen.dart';
import 'package:talknep/UI/bottomBar/bottom_screen.dart';

class SplashProvider extends ChangeNotifier {
  late AnimationController animationController;
  late Animation<double> opacityAnimation;
  late Animation<double> scaleAnimation;

  void initAnimation(TickerProvider ticker) {
    animationController = AnimationController(
      vsync: ticker,
      duration: const Duration(milliseconds: 1500),
    );

    opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: animationController, curve: Curves.easeIn),
    );

    scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: animationController, curve: Curves.easeOutBack),
    );

    animationController.forward();

    Future.delayed(const Duration(seconds: 3), () {
      if (Global.token != null) {
        Get.off(
          () => BottomBarScreen(),
          transition: Transition.fadeIn,
          duration: const Duration(milliseconds: 500),
        );
      } else {
        Get.off(
          () => LoginScreen(),
          transition: Transition.fadeIn,
          duration: const Duration(milliseconds: 500),
        );
      }
    });
  }

  void disposeAnimation() {
    animationController.dispose();
  }
}
