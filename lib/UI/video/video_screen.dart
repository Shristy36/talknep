import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:talknep/UI/dashboard/components/comment_bottom_sheet.dart';
import 'package:talknep/components/video_loader.dart';
import 'package:talknep/constant/global.dart';
import 'package:talknep/gen/assets.gen.dart';
import 'package:talknep/provider/video/video_provider.dart';
import 'package:talknep/util/theme_extension.dart';
import 'package:talknep/widget/app_loader.dart';
import 'package:talknep/widget/app_shared.dart';
import 'package:talknep/widget/app_sizer.dart';
import 'package:talknep/widget/app_text.dart';

class VideoScreen extends StatelessWidget {
  const VideoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final videoProvider = Provider.of<VideoProvider>(context);
    return Scaffold(
      backgroundColor: context.scaffoldBackgroundColor,
      body: Column(
        children: [
          SizedBox(height: Sizer.h(1)),
          Expanded(
            child:
                videoProvider.isLoading
                    ? CommonLoader()
                    : RefreshIndicator.adaptive(
                      onRefresh:
                          () async =>
                              await videoProvider.getVideoListData(true),
                      child: ListView.separated(
                        shrinkWrap: true,
                        cacheExtent: 999999999999999,
                        itemCount: videoProvider.videosListData.length,
                        padding: EdgeInsets.symmetric(horizontal: Sizer.w(2)),
                        separatorBuilder: (context, index) {
                          return SizedBox(height: Sizer.h(1));
                        },
                        itemBuilder: (context, index) {
                          return customCard(
                            context,
                            videoProvider.videosListData[index],
                            videoProvider,
                          );
                        },
                      ),
                    ),
          ),
        ],
      ),
    );
  }

  Widget customCard(
    BuildContext context,
    dynamic videosData,
    VideoProvider videoProvider,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: Sizer.h(1),
        horizontal: Sizer.w(2),
      ),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 24,
                backgroundImage: NetworkImage(videosData['photo'].toString()),
              ),
              SizedBox(width: Sizer.w(2)),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    fontSize: Sizer.sp(3.5),
                    fontWeight: FontWeight.w500,
                    text: videosData['name'].toString(),
                  ),

                  AppText(
                    fontSize: Sizer.sp(2.7),
                    text: videosData['created_at'].toString(),
                  ),
                ],
              ),
              Spacer(),
              videosData['user_id'] == Global.userProfileData['id']
                  ? SizedBox()
                  : InkWell(
                    onTap: () {
                      if (videosData['follow'] == "Unfollow") {
                        videoProvider.unFollowUser(videosData['user_id']);
                      } else {
                        videoProvider.followUser(videosData['user_id']);
                      }
                    },
                    child: AppText(
                      fontSize: Sizer.sp(3.5),
                      text: videosData['follow'],
                      fontWeight: FontWeight.w500,
                      color: context.colorsScheme.primary,
                    ),
                  ),
            ],
          ),
          SizedBox(height: Sizer.h(1)),
          AppText(
            fontSize: Sizer.sp(3.5),
            text: videosData['title'].toString(),
          ),
          SizedBox(height: Sizer.h(1)),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: CommonVideoPlayer(
              source: videosData['file'],
              key: ValueKey(videosData['file']),
            ),
          ),
          SizedBox(height: Sizer.h(1)),
          videosData['reaction_counts']['like'] != 0
              ? Padding(
                padding: const EdgeInsets.only(top: 10, left: 8),
                child: Row(
                  children: [
                    Assets.image.svg.likePost.svg(),
                    SizedBox(width: Sizer.w(1)),
                    AppText(
                      text: videosData['reaction_counts']['like'].toString(),
                    ),
                  ],
                ),
              )
              : SizedBox(),
          SizedBox(height: Sizer.h(1)),
          Divider(color: context.colorsScheme.onSecondary),
          SizedBox(height: Sizer.h(1)),
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  if (videosData['userReaction'] == 'like') {
                    videoProvider.postLike(
                      videosData['post_id'].toString(),
                      "",
                    );
                  } else {
                    videoProvider.postLike(
                      videosData['post_id'].toString(),
                      "like",
                    );
                  }
                },
                child: Row(
                  children: [
                    Icon(
                      size: 20,
                      videosData['userReaction'] == 'like'
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: context.colorsScheme.primary,
                    ),
                    SizedBox(width: Sizer.w(2)),
                    AppText(
                      text: "Like",
                      fontSize: Sizer.sp(3.5),
                      color: context.colorsScheme.primary,
                    ),
                  ],
                ),
              ),
              Spacer(),
              GestureDetector(
                onTap: () {
                  showCommentBottomSheet(
                    context: context,
                    postType: "videos",
                    postId: videosData['post_id'],
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
                  _shareVideo(videosData['file'].toString());
                },
                child: Row(
                  children: [
                    Icon(
                      Icons.share,
                      color: context.colorsScheme.primary,
                      size: 20,
                    ),
                    SizedBox(width: Sizer.w(2)),
                    AppText(
                      text: "Share",
                      color: context.colorsScheme.primary,
                      fontSize: Sizer.sp(3.5),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: Sizer.h(1)),
        ],
      ),
    );
  }

  _shareVideo(dynamic videosUrl) {
    shareReelFromUrl(videosUrl);
  }
}
