import 'package:flutter/material.dart';
import 'package:talknep/gen/assets.gen.dart';
import 'package:talknep/util/theme_extension.dart';
import 'package:talknep/widget/app_sizer.dart';
import 'package:talknep/widget/app_text.dart';

class ShowLikeAndComment extends StatelessWidget {
  final int likeCount;
  final int CommentsCount;
  const ShowLikeAndComment({
    super.key,
    required this.likeCount,
    required this.CommentsCount,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (likeCount != 0) Assets.image.svg.likePost.svg(),
        if (likeCount != 0) SizedBox(width: Sizer.w(1)),
        if (likeCount != 0) AppText(text: likeCount.toString()),
        Spacer(),
        if (CommentsCount != 0)
          AppText(
            text: "${CommentsCount} comments",
            color: context.colorsScheme.onSecondary,
          ),
      ],
    );
  }
}
