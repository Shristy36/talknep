import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talknep/UI/dashboard/components/comment_bottom_sheet.dart';
import 'package:talknep/UI/dashboard/components/full_screen_image_viewer.dart';
import 'package:talknep/UI/dashboard/post/components/description_text.dart';
import 'package:talknep/UI/dashboard/post/components/like_button.dart';
import 'package:talknep/UI/dashboard/post/components/post_header.dart';
import 'package:talknep/UI/dashboard/post/components/show_reaction_counts_comments.dart';
import 'package:talknep/components/app_spacing.dart';
import 'package:talknep/components/net_image.dart';
import 'package:talknep/components/video_loader.dart';
import 'package:talknep/gen/assets.gen.dart';
import 'package:talknep/provider/dashboard/dashboard_provider.dart';
import 'package:talknep/util/file_checker.dart';
import 'package:talknep/util/theme_extension.dart';
import 'package:talknep/widget/app_shared.dart';
import 'package:talknep/widget/app_sizer.dart';
import 'package:talknep/widget/app_text.dart';

Widget postCard(
  int index,
  dynamic data,
  BuildContext context,
  DashboardProvider provider, {
  String? trailing,
  void Function()? showMenu,
  void Function()? onUserNavigate,
}) {
  return AppHorizontalPadding(
    child: Container(
      padding: EdgeInsets.symmetric(
        horizontal: Sizer.w(3),
        vertical: Sizer.h(1),
      ),
      margin: EdgeInsets.symmetric(vertical: Sizer.h(1)),
      decoration: BoxDecoration(
        color: context.colorsScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.colorsScheme.onSecondary),
        boxShadow: [
          BoxShadow(
            blurRadius: 4,
            spreadRadius: 1,
            offset: Offset(0, 2),
            color: context.colorsScheme.shadow,
          ),
        ],
      ),
      child: Column(
        spacing: Sizer.h(1),
        children: [
          PostHeader(
            avatarSize: 50,
            isVerified: true,
            trailing: trailing,
            onTapMenu: showMenu,
            location: data['location'],
            onTapProfile: onUserNavigate,
            avatarUrl: data['photo'] ?? "",
            displayName: data['name'] ?? "",
            timestamp: data['created_at'] ?? "",
            audience:
                data['privacy'] == "Public" ? Audience.public : Audience.onlyMe,
          ),
          Align(
            alignment: Alignment.topLeft,
            child: DescriptionText(
              linkColor: context.colorsScheme.primary,
              textColor: context.colorsScheme.onSurface,
              htmlDescription: data['description'] ?? '',
            ),
          ),
          (data['post_images'] != null &&
                  data['post_images'] is List &&
                  (data['post_images'] as List).isNotEmpty &&
                  (data['post_images'][0] != null))
              ? isVideoFile(data['post_images'][0])
                  ? SizedBox(
                    width: double.infinity,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: CommonVideoPlayer(
                        source: data['post_images'][0],
                        key: ValueKey(data['post_images'][0]),
                      ),
                    ),
                  )
                  : GestureDetector(
                    onTap: () {
                      Get.to(
                        transition: Transition.fadeIn,
                        () => FullScreenImageViewer(
                          imageUrl: data['post_images'][0],
                        ),
                      );
                    },
                    child: NetImage(
                      fit: BoxFit.fill,
                      width: double.infinity,
                      imageUrl: data['post_images'][0],
                      borderRadius: BorderRadius.circular(8),
                    ),
                  )
              : Assets.image.png.backgroundImage.image(
                fit: BoxFit.fill,
                width: double.infinity,
              ),
          ShowLikeAndComment(
            likeCount:
                (provider.likeCounts.length > index)
                    ? provider.likeCounts[index]
                    : 0,
            CommentsCount: data['commentsCount'] ?? 0,
          ),
          Divider(color: context.colorsScheme.onSecondary),
          Row(
            children: [
              LikeButton(data: data, provider: provider, index: index),
              Spacer(),
              InkWell(
                onTap: () {
                  showCommentBottomSheet(
                    context: context,
                    postId: data['post_id'],
                    postType: "post",
                  );
                },
                child: Row(
                  children: [
                    Assets.icon.comment.svg(
                      colorFilter: ColorFilter.mode(
                        context.colorsScheme.primary,
                        BlendMode.srcIn,
                      ),
                    ),
                    SizedBox(width: Sizer.w(2)),
                    AppText(
                      text: "Comment",
                      fontSize: Sizer.sp(3.5),
                      color: context.colorsScheme.primary,
                    ),
                  ],
                ),
              ),
              Spacer(),
              GestureDetector(
                onTap: () {
                  if (data['post_images'] != null &&
                      data['post_images'].isNotEmpty &&
                      data['post_images'][0] != null) {
                    _shareImage(
                      data['post_images'][0] ?? '',
                      data['description'],
                    );
                  }
                },
                child: Row(
                  children: [
                    Icon(
                      size: 20,
                      Icons.share,
                      color: context.colorsScheme.primary,
                    ),
                    SizedBox(width: Sizer.w(2)),
                    AppText(
                      text: "Share",
                      fontSize: Sizer.sp(3.5),
                      color: context.colorsScheme.primary,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

_shareImage(dynamic imageUrl, String title) {
  shareImageFromUrl(imageUrl: imageUrl, title: title);
}
