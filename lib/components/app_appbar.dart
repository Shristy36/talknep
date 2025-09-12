import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talknep/util/theme_extension.dart';
import 'package:talknep/widget/app_text.dart';

class AppAppbar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final double elevation;
  final bool centerTitle;
  final bool showBackButton;
  final List<Widget>? actions;
  final PreferredSizeWidget? bottom;

  const AppAppbar({
    super.key,
    this.title,
    this.bottom,
    this.actions,
    this.elevation = 0,
    this.centerTitle = false,
    this.showBackButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      bottom: bottom,
      titleSpacing: 0,
      actions: actions,
      elevation: elevation,
      centerTitle: centerTitle,
      automaticallyImplyLeading: false,
      title: AppText(text: title ?? "", fontWeight: FontWeight.w500),
      leading:
          showBackButton
              ? IconButton(
                onPressed: () => Get.back(),
                icon: Icon(
                  size: 18,
                  Icons.arrow_back_ios,
                  color: context.colorsScheme.onSurface,
                ),
              )
              : null,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
