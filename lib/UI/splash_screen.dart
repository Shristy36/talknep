import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:talknep/constant/global.dart';
import 'package:talknep/gen/assets.gen.dart';
import 'package:talknep/provider/splash_provider.dart';
import 'package:talknep/util/theme_extension.dart';
import 'package:talknep/widget/app_sizer.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late SplashProvider splashProvider;

  @override
  void initState() {
    super.initState();
    Global.userProfile();
    splashProvider = SplashProvider();
    splashProvider.initAnimation(this);
  }

  @override
  void dispose() {
    splashProvider.disposeAnimation();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: splashProvider,
      child: Scaffold(
        appBar: AppBar(toolbarHeight: 0),
        backgroundColor: context.scaffoldBackgroundColor,
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: Sizer.w(6)),
          child: Center(
            child: Consumer<SplashProvider>(
              builder: (context, provider, _) {
                return FadeTransition(
                  opacity: provider.opacityAnimation,
                  child: ScaleTransition(
                    scale: provider.scaleAnimation,
                    child: ClipRRect(
                      child: Assets.image.png.appIcon.image(),
                      borderRadius: BorderRadius.circular(200),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
