import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:talknep/constant/app_color.dart';
import 'package:talknep/util/theme_extension.dart';
import 'package:talknep/widget/app_sizer.dart';

class AppSlidableAction extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final VoidCallback onTap;
  final Color? backgroundColor;

  const AppSlidableAction({
    super.key,
    required this.onTap,
    required this.icon,
    this.backgroundColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return CustomSlidableAction(
      padding: EdgeInsets.only(left: Sizer.w(1)),
      backgroundColor: context.scaffoldBackgroundColor,
      onPressed: (_) => onTap(),
      child: Container(
        margin: EdgeInsets.symmetric(vertical: Sizer.h(1)),
        padding: EdgeInsets.symmetric(
          horizontal: Sizer.w(3),
          vertical: Sizer.h(1.5),
        ),
        decoration: BoxDecoration(
          color: backgroundColor ?? Theme.of(context).colorScheme.error,
          borderRadius: BorderRadius.circular(10),
        ),
        alignment: Alignment.center,
        child: Icon(icon, color: iconColor ?? AppColors.whiteColor),
      ),
    );
  }
}
