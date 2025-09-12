import 'app_sizer.dart';
import 'package:flutter/material.dart';
import 'package:talknep/util/theme_extension.dart';

class AppButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget? child;
  final Color? backgroundColor;
  final Color? borderColor;
  final double? width;
  final double? height;

  const AppButton({
    super.key,
    this.child,
    this.height,
    this.width,
    this.borderColor,
    this.backgroundColor,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height ?? Sizer.h(5),
      width: width ?? double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.zero,
          backgroundColor: backgroundColor ?? context.colorsScheme.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),

            /*  side: BorderSide(
              width: 1.0,
              color: borderColor ?? context.colorsScheme.onSecondary,
            ), */
          ),
        ),
        child: child ?? const SizedBox.shrink(),
      ),
    );
  }
}
