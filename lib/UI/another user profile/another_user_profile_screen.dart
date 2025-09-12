import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:talknep/UI/chat/chat_view_screen.dart';
import 'package:talknep/UI/dashboard/components/full_screen_image_viewer.dart';
import 'package:talknep/UI/dashboard/post/components/description_text.dart';
import 'package:talknep/UI/dashboard/post/components/post_header.dart';
import 'package:talknep/UI/menu/profile/components/users_friends.dart';
import 'package:talknep/components/app_appbar.dart';
import 'package:talknep/components/app_spacing.dart';
import 'package:talknep/components/net_image.dart';
import 'package:talknep/components/video_loader.dart';
import 'package:talknep/constant/global.dart';
import 'package:talknep/gen/assets.gen.dart';
import 'package:talknep/provider/another%20user%20profile/another_user_profile_provider.dart';
import 'package:talknep/provider/chat/chat_view_provider.dart';
import 'package:talknep/util/file_checker.dart';
import 'package:talknep/util/theme_extension.dart';
import 'package:talknep/widget/app_loader.dart';
import 'package:talknep/widget/app_shared.dart';
import 'package:talknep/widget/app_sizer.dart';
import 'package:talknep/widget/app_text.dart';

class AnotherUserProfileScreen extends StatelessWidget {
  const AnotherUserProfileScreen({super.key});
  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AnotherUserProfileProvider>().userProfileDetails();
    });

    return Scaffold(
      appBar: AppAppbar(
        title: 'Profile',
        actions: [
          Global.uid.toString() == anotherUserProfileId.toString()
              ? SizedBox()
              : SizedBox(
                height: Sizer.h(6),
                width: Sizer.w(6),
                child: GestureDetector(
                  onTap: () async {
                    final anotherUserData =
                        context
                            .read<AnotherUserProfileProvider>()
                            .anotherUserProfileData;

                    final userId1 = Global.uid;

                    final userId2 = anotherUserData['id'];

                    final slug2 = "${userId2}-${userId1}";

                    Get.to(
                      transition: Transition.fadeIn,
                      duration: const Duration(milliseconds: 500),
                      () => ChangeNotifierProvider(
                        create: (_) => ChatViewProvider(),
                        child: ChatViewScreen(
                          slug: slug2,
                          receiverId: anotherUserData['id'],
                          receiverName: anotherUserData['name'],
                          receiverAvatarUrl: anotherUserData['photo'],
                        ),
                      ),
                    );
                  },
                  child: Assets.icon.messageIcon.image(
                    color: context.colorsScheme.onSurface,
                  ),
                ),
              ),
          SizedBox(width: Sizer.w(3)),
        ],
      ),
      backgroundColor: context.scaffoldBackgroundColor,
      body: Consumer<AnotherUserProfileProvider>(
        builder: (context, anotherUserProvider, child) {
          return anotherUserProvider.isLoading
              ? Center(child: CommonLoader(color: context.colorsScheme.primary))
              : CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: AppHorizontalPadding(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: Sizer.h(30),
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: context.colorsScheme.surface,
                              border: Border.all(
                                color: context.colorsScheme.onSecondary,
                              ),
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(
                                  blurRadius: 4,
                                  spreadRadius: 1,
                                  offset: Offset(0, 2),
                                  color: context.colorsScheme.shadow,
                                ),
                              ],
                            ),
                            child: Stack(
                              children: [
                                Container(
                                  height: Sizer.h(20),
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: context.colorsScheme.surface,
                                    borderRadius: BorderRadius.circular(15),
                                    border: Border.all(
                                      color: context.colorsScheme.onSecondary,
                                    ),
                                  ),
                                  child: NetImage(
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(15),
                                      topRight: Radius.circular(15),
                                    ),
                                    fit: BoxFit.cover,
                                    imageUrl:
                                        anotherUserProvider
                                            .anotherUserProfileData['cover_photo'] ??
                                        '',
                                  ),
                                ),
                                Positioned(
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Padding(
                                      padding: EdgeInsets.only(
                                        left: 15,
                                        bottom: Sizer.h(2.5),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          Container(
                                            height: 85,
                                            width: 85,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color:
                                                    context
                                                        .colorsScheme
                                                        .onPrimary,
                                              ),
                                            ),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(10.w),
                                              child: NetImage(
                                                imageUrl:
                                                    anotherUserProvider
                                                        .anotherUserProfileData['photo'] ??
                                                    "",
                                              ),
                                            ),
                                          ),
                                          SizedBox(height: Sizer.h(1)),
                                          AppText(
                                            fontWeight: FontWeight.w500,
                                            text:
                                                anotherUserProvider
                                                    .anotherUserProfileData['name']
                                                    .toString(),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: Sizer.h(3)),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: Sizer.w(3),
                              vertical: Sizer.h(2),
                            ),
                            decoration: BoxDecoration(
                              color: context.scaffoldBackgroundColor,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: context.colorsScheme.onSecondary,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  spreadRadius: 1,
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                  color: context.colorsScheme.shadow,
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                AppText(
                                  text: "Info",
                                  color: context.colorsScheme.secondary,
                                ),
                                SizedBox(height: Sizer.h(1)),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.watch_later,
                                      color: context.colorsScheme.secondary
                                          .withAlpha(100),
                                    ),
                                    SizedBox(width: Sizer.w(2)),
                                    AppText(
                                      fontSize: Sizer.sp(3.5),
                                      text:
                                          "Joined ${anotherUserProvider.anotherUserProfileData['created_at']}",
                                      color: context.colorsScheme.secondary
                                          .withValues(alpha: 0.7),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: Sizer.h(3)),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: AppText(
                              text: "Friends",
                              fontSize: Sizer.sp(3.7),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: Sizer.h(1)),
                        ],
                      ),
                    ),
                  ),
                  SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: Sizer.h(2),
                      childAspectRatio: Sizer.w(1.3) / Sizer.h(0.75),
                    ),
                    delegate: SliverChildBuilderDelegate(
                      childCount: min(
                        (anotherUserProvider.anotherUserProfileData['friends']
                                    as List? ??
                                [])
                            .length,
                        6,
                      ),
                      (context, index) {
                        final friends =
                            anotherUserProvider
                                    .anotherUserProfileData['friends']
                                as List? ??
                            [];
                        if (friends.isEmpty) {
                          return const SizedBox.shrink();
                        }

                        final friend =
                            friends[index] as Map<String, dynamic>? ?? {};

                        return GestureDetector(
                          onTap: () {
                            context
                                .read<AnotherUserProfileProvider>()
                                .userProfileDetails();

                            anotherUserProfileId = friend['friend_id'];
                            Get.to(
                              transition: Transition.fadeIn,
                              () => AnotherUserProfileScreen(),
                              duration: const Duration(milliseconds: 500),
                            );
                          },
                          child: AppHorizontalPadding(
                            child: FriendsCard(
                              userName: friend['name'] ?? "",
                              image: friend['photo'] ?? "",
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  SliverToBoxAdapter(child: SizedBox(height: Sizer.h(1))),
                  // Posts Section
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final posts =
                            anotherUserProvider.anotherUserProfileData['posts']
                                as List? ??
                            [];
                        final post =
                            posts[index] as Map<String, dynamic>? ?? {};
                        final images = post['post_images'] as List? ?? [];

                        return Column(
                          children:
                              images.map<Widget>((imgUrl) {
                                return PostImageCard(
                                  context: context,
                                  data: post,
                                );
                              }).toList(),
                        );
                      },
                      childCount:
                          (anotherUserProvider.anotherUserProfileData['posts']
                                      as List? ??
                                  [])
                              .length,
                    ),
                  ),

                  SliverToBoxAdapter(child: SizedBox(height: Sizer.h(1))),
                ],
              );
        },
      ),
    );
  }

  PostImageCard({required dynamic data, required BuildContext context}) {
    return AppHorizontalPadding(
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: Sizer.w(3),
          vertical: Sizer.h(1),
        ),
        margin: EdgeInsets.symmetric(vertical: Sizer.h(1)),
        decoration: BoxDecoration(
          color: context.colorsScheme.surface,
          borderRadius: BorderRadius.circular(15),
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
          children: [
            PostHeader(
              avatarSize: 50,
              isVerified: true,
              timestamp: data['created_at'],
              avatarUrl: data['photo'],
              displayName: data['name'],
            ),
            Align(
              alignment: Alignment.topLeft,
              child: DescriptionText(
                linkColor: context.colorsScheme.primary,
                textColor: context.colorsScheme.onSurface,
                htmlDescription: data['description'],
              ),
            ),
            SizedBox(height: Sizer.h(1)),

            (data['post_images'] != null &&
                    data['post_images'] is List &&
                    (data['post_images'] as List).isNotEmpty &&
                    (data['post_images'][0] != null))
                ? isVideoFile(data['post_images'][0])
                    ? SizedBox(
                      width: double.infinity,
                      child: CommonVideoPlayer(
                        source: data['post_images'][0],
                        key: ValueKey(data['post_images'][0]),
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
                        borderRadius: BorderRadius.circular(12),
                      ),
                    )
                : Assets.image.png.backgroundImage.image(
                  fit: BoxFit.fill,
                  width: double.infinity,
                ),

            data['userReaction'] != null
                ? Padding(
                  padding: const EdgeInsets.only(top: 10, left: 8),
                  child: Row(
                    children: [
                      Assets.image.svg.likePost.svg(),
                      SizedBox(width: Sizer.w(1)),
                      AppText(
                        text: "${data['reaction_counts']?['total'] ?? 0}",
                      ),
                    ],
                  ),
                )
                : SizedBox(),
            SizedBox(height: Sizer.h(1)),
            Divider(color: context.colorsScheme.onSecondary),
            SizedBox(height: Sizer.h(1)),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: Sizer.w(2)),
              child: Row(
                children: [
                  Row(
                    children: [
                      Icon(
                        data["userReaction"] == true
                            ? Icons.favorite
                            : Icons.favorite_border,
                        size: 20,
                        color: context.colorsScheme.primary,
                      ),
                      SizedBox(width: Sizer.w(2)),
                      AppText(
                        text: "Like",
                        color: context.colorsScheme.primary,
                        fontSize: Sizer.sp(3.5),
                      ),
                    ],
                  ),
                  Spacer(),
                  Row(
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
                  Spacer(),
                  GestureDetector(
                    onTap: () {
                      _shareImage(data['post_images']);
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
            ),
          ],
        ),
      ),
    );
  }

  _shareImage(dynamic imageUrl) {
    shareImageFromUrl(imageUrl: imageUrl);
  }
}
