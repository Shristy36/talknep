import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_avatar/flutter_advanced_avatar.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:talknep/UI/createPost/create_post_screen.dart';
import 'package:talknep/UI/menu/profile/components/see_all_friend_screen.dart';
import 'package:talknep/UI/menu/profile/components/users_friends.dart';
import 'package:talknep/UI/menu/profile/components/users_post_list.dart';
import 'package:talknep/components/app_appbar.dart';
import 'package:talknep/components/app_spacing.dart';
import 'package:talknep/components/net_image.dart';
import 'package:talknep/constant/global.dart';
import 'package:talknep/gen/assets.gen.dart';
import 'package:talknep/provider/menu/profile_provider.dart';
import 'package:talknep/util/theme_extension.dart';
import 'package:talknep/widget/app_loader.dart';
import 'package:talknep/widget/app_showPicker.dart';
import 'package:talknep/widget/app_sizer.dart';
import 'package:talknep/widget/app_text.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: ProfileProvider(),
      child: Scaffold(
        appBar: AppAppbar(title: "Profile"),
        backgroundColor: context.scaffoldBackgroundColor,
        body: Consumer<ProfileProvider>(
          builder: (context, provider, child) {
            return provider.isLoading
                ? Center(
                  child: CommonLoader(
                    fullScreen: true,
                    color: context.colorsScheme.primary,
                  ),
                )
                : SingleChildScrollView(
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
                              GestureDetector(
                                onTap: () {
                                  showImagePickerBottomSheet(
                                    context: context,
                                    onImageSelected: (File image) async {
                                      provider.selectedUserCoverImage = image;
                                      await provider
                                          .updateProfileUserCoverImage();
                                    },
                                  );
                                },
                                child: Container(
                                  height: Sizer.h(20),
                                  width: double.infinity,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(15),
                                      topRight: Radius.circular(15),
                                    ),
                                    child:
                                        provider.selectedUserCoverImage != null
                                            ? Image.file(
                                              fit: BoxFit.cover,
                                              provider.selectedUserCoverImage!,
                                            )
                                            : (Global.userCoverImage == null
                                                ? Assets
                                                    .image
                                                    .png
                                                    .backgroundImage
                                                    .image(fit: BoxFit.cover)
                                                : NetImage(
                                                  imageUrl:
                                                      Global.userCoverImage
                                                          .toString(),
                                                )),
                                  ),
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
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            showImagePickerBottomSheet(
                                              context: context,
                                              onImageSelected: (
                                                File image,
                                              ) async {
                                                provider.selectedUserImage =
                                                    image;
                                                await provider
                                                    .updateProfileUserImage();
                                              },
                                            );
                                          },
                                          child: Container(
                                            height: 90,
                                            width: 90,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color:
                                                    context
                                                        .colorsScheme
                                                        .surface,
                                              ),
                                              image: DecorationImage(
                                                fit: BoxFit.cover,
                                                image:
                                                    provider.selectedUserImage !=
                                                            null
                                                        ? FileImage(
                                                          provider
                                                              .selectedUserImage!,
                                                        )
                                                        : NetworkImage(
                                                          Global.userImage
                                                              .toString(),
                                                        ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: Sizer.h(1)),
                                        AppText(
                                          fontWeight: FontWeight.w500,
                                          text:
                                              Global.userProfileData['name']
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
                        AppText(text: "Post", fontWeight: FontWeight.w500),
                        GestureDetector(
                          onTap: () {
                            Get.to(
                              () => CreatePostScreen(),
                              transition: Transition.fadeIn,
                              duration: const Duration(milliseconds: 500),
                            );
                          },
                          child: Container(
                            height: Sizer.h(6.5),
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: context.colorsScheme.surface,
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(
                                color: context.colorsScheme.onSecondary,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  blurRadius: 4,
                                  spreadRadius: 1,
                                  offset: Offset(0, 2),
                                  color: context.colorsScheme.shadow,
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: Sizer.w(3),
                              ),
                              child: Row(
                                children: [
                                  AdvancedAvatar(
                                    size: 40,
                                    image: NetworkImage(
                                      Global.userImage.toString(),
                                    ),
                                  ),
                                  SizedBox(width: Sizer.w(3)),
                                  AppText(
                                    fontSize: Sizer.sp(3.5),
                                    text: "What's on your mind?",
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: Sizer.h(3)),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: Sizer.w(3),
                            vertical: Sizer.h(2),
                          ),
                          decoration: BoxDecoration(
                            color: context.colorsScheme.surface,
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
                              AppText(text: "Info"),
                              SizedBox(height: Sizer.h(1)),
                              Row(
                                children: [
                                  Icon(
                                    Icons.watch_later,
                                    color: context.colorsScheme.onSurface
                                        .withValues(alpha: 0.4),
                                  ),
                                  SizedBox(width: Sizer.w(2)),
                                  AppText(
                                    fontSize: Sizer.sp(3.5),
                                    text:
                                        "Joined ${provider.userInfo?['created_at']}",
                                    color: context.colorsScheme.onSurface
                                        .withValues(alpha: 0.4),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: Sizer.h(3)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            AppText(
                              text: "Friends",
                              fontSize: Sizer.sp(3.7),
                              fontWeight: FontWeight.w500,
                            ),
                            GestureDetector(
                              onTap: () {
                                Get.to(
                                  transition: Transition.fadeIn,
                                  duration: const Duration(milliseconds: 500),
                                  () => SeeAllFriendScreen(provider: provider),
                                );
                              },
                              child: AppText(
                                text: "See all friends",
                                fontSize: Sizer.sp(3),
                                fontWeight: FontWeight.w500,
                                color: context.colorsScheme.primary,
                              ),
                            ),
                          ],
                        ),
                        UsersFriends(),
                        UsersPostList(),
                      ],
                    ),
                  ),
                );
          },
        ),
      ),
    );
  }
}
