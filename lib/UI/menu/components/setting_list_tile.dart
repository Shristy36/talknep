import 'package:flutter/material.dart';
import 'package:talknep/constant/app_color.dart';
import 'package:talknep/l10n/app_localizations.dart';
import 'package:talknep/widget/app_sizer.dart';
import 'package:talknep/widget/app_text.dart';

class SettingListTile extends StatelessWidget {
  final String? title;
  final bool isDivider;
  final void Function()? onTap;
  const SettingListTile({
    super.key,
    this.onTap,
    this.title,
    required this.local,
    this.isDivider = true,
  });
  final AppLocalizations local;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: Sizer.h(0.5)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText(fontWeight: FontWeight.w500, text: title ?? ""),
            isDivider
                ? Divider(
                  color: AppColors.secondaryColor.withValues(alpha: 0.2),
                )
                : SizedBox(),
          ],
        ),
      ),
    );
  }
}
