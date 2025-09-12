import 'package:flutter/cupertino.dart';
import 'package:talknep/util/theme_extension.dart';
import 'package:talknep/widget/app_sizer.dart';
import 'package:talknep/widget/app_text.dart';

Widget infoRow(String title, String value, BuildContext context) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 8.0),
    child: Row(
      children: [
        AppText(
          text: '$title: ',
          fontSize: Sizer.sp(3.6),
          fontWeight: FontWeight.w500,
        ),
        Expanded(
          child: AppText(
            text: value,
            fontSize: Sizer.sp(3.5),
            color: context.colorsScheme.secondaryContainer.withAlpha(150),
          ),
        ),
      ],
    ),
  );
}
