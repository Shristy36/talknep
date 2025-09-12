import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:talknep/UI/dashboard/components/comment_bottom_sheet.dart';
import 'package:talknep/UI/dashboard/components/full_screen_image_viewer.dart';
import 'package:talknep/components/action_button.dart';
import 'package:talknep/components/net_image.dart';
import 'package:talknep/components/video_loader.dart';
import 'package:talknep/constant/global.dart';
import 'package:talknep/gen/assets.gen.dart';
import 'package:talknep/provider/menu/profile_provider.dart';
import 'package:talknep/util/theme_extension.dart';
import 'package:talknep/util/file_checker.dart';
import 'package:talknep/widget/app_shared.dart';
import 'package:talknep/widget/app_sizer.dart';
import 'package:talknep/widget/app_text.dart';

class UsersPostList extends StatelessWidget {
  const UsersPostList({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<ProfileProvider>();

    return ListView.builder(
      shrinkWrap: true,
      itemCount: provider.userProfilePhoto.length,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        String? image;

        List<dynamic> images = provider.userProfilePhoto[index]['post_images'];
        if (images.isNotEmpty) {
          image = images[0];
        }

        final postTime = provider.userProfilePhoto[index]['created_at'];

        return customCardForPostImage(
          index: index,
          onLikeTap: () {
            provider.postLike(
              index: index,
              postId: provider.userProfilePhoto[index]['post_id'],
            );
          },
          provider,
          image: image,
          context: context,
          postTime: postTime,
          postId: provider.userProfilePhoto[index]['post_id'],
          likeCount:
              provider.userProfilePhoto[index]['reaction_counts']['total']
                  .toString(),
        );
      },
    );
  }
}

Widget customCardForPostImage(
  ProfileProvider provider, {
  int? postId,
  int? index,
  String? image,
  String? postTime,
  String? likeCount,
  required BuildContext context,
  required VoidCallback? onLikeTap,
}) {
  return Container(
    margin: EdgeInsets.symmetric(vertical: Sizer.h(1)),
    padding: EdgeInsets.symmetric(horizontal: Sizer.w(3), vertical: Sizer.h(1)),
    width: double.infinity,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(15),
      boxShadow: [
        BoxShadow(
          blurRadius: 4,
          spreadRadius: 1,
          offset: Offset(0, 2),
          color: context.colorsScheme.shadow,
        ),
      ],
      color: context.colorsScheme.surface,
      border: Border.all(color: context.colorsScheme.onSecondary),
    ),
    child: Column(
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundImage: NetworkImage(Global.userImage.toString()),
            ),
            SizedBox(width: Sizer.w(3)),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(text: Global.userProfileData['name'] ?? ""),
                AppText(text: postTime!, fontSize: Sizer.sp(2.5)),
              ],
            ),
            const Spacer(),
            PopupMenuButton<String>(
              color: context.colorsScheme.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
              onSelected: (value) async {
                if (value == 'delete') {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder:
                        (ctx) => AlertDialog.adaptive(
                          title: AppText(text: "Delete Post"),
                          content: AppText(
                            text: "Are you sure you want to delete this post?",
                          ),
                          actions: [
                            TextButton(
                              child: AppText(text: "Cancel"),
                              onPressed: () => Navigator.pop(ctx, false),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              child: AppText(
                                text: "Delete",
                                color: context.colorsScheme.error,
                              ),
                            ),
                          ],
                        ),
                  );
                  if (confirm == true) {
                    provider.deletePostAPI(context, postId.toString());
                  }
                }
              },
              itemBuilder:
                  (BuildContext context) => [
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: context.colorsScheme.error),
                          const SizedBox(width: 8),
                          const Text('Delete post'),
                        ],
                      ),
                    ),
                  ],
              child: const Icon(Icons.more_vert),
            ),
          ],
        ),

        SizedBox(height: Sizer.h(1)),

        /// Post Image / Video
        SizedBox(
          child: InkWell(
            onTap: () {
              Get.to(
                transition: Transition.fadeIn,
                () => FullScreenImageViewer(imageUrl: image ?? ''),
              );
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child:
                  (image != null && isVideoFile(image))
                      ? CommonVideoPlayer(source: image)
                      : NetImage(
                        fit: BoxFit.cover,
                        imageUrl: image ?? '',
                        width: double.infinity,
                      ),
            ),
          ),
        ),

        /// Likes count
        Padding(
          padding: const EdgeInsets.only(top: 10, left: 8),
          child: Row(
            children: [
              Assets.image.svg.likePost.svg(),
              SizedBox(width: Sizer.w(1)),
              AppText(text: likeCount!),
            ],
          ),
        ),

        SizedBox(height: Sizer.h(0.5)),
        Divider(color: context.colorsScheme.onSecondary),
        SizedBox(height: Sizer.h(1)),

        /// Action buttons row
        Padding(
          padding: EdgeInsets.symmetric(horizontal: Sizer.w(2)),
          child: Row(
            children: [
              ActionButton(
                title: "Like",
                activeIcon: Icons.favorite,
                inactiveIcon: Icons.favorite_border,
                onTap: () => provider.postLike(index: index!, postId: postId!),
                isActive:
                    provider.userProfilePhoto[index]['userReaction'] == 'like',
              ),
              Spacer(),
              ActionButton(
                title: "Comment",
                svgIcon: Assets.icon.comment.svg(
                  colorFilter: ColorFilter.mode(
                    context.colorsScheme.primary,
                    BlendMode.srcIn,
                  ),
                ),
                onTap: () {
                  showCommentBottomSheet(
                    context: context,
                    postId: postId,
                    postType: "post",
                  );
                },
              ),
              Spacer(),
              ActionButton(
                title: "Share",
                inactiveIcon: Icons.share,
                onTap: () {
                  _shareImage(image ?? '');
                },
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

_shareImage(dynamic imageUrl) {
  shareImageFromUrl(imageUrl: imageUrl);
}
