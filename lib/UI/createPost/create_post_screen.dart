import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:talknep/UI/createPost/add_location_screen.dart';
import 'package:talknep/UI/createPost/tag_friend_screen.dart';
import 'package:talknep/components/app_appbar.dart';
import 'package:talknep/components/app_spacing.dart';
import 'package:talknep/components/video_loader.dart';
import 'package:talknep/constant/app_color.dart';
import 'package:talknep/provider/createPost/create_post_provider.dart';
import 'package:talknep/util/theme_extension.dart';
import 'package:talknep/widget/app_sizer.dart';
import 'package:talknep/widget/app_text.dart';
import 'package:talknep/widget/app_textfield.dart';

class CreatePostScreen extends StatelessWidget {
  const CreatePostScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final postProvider = Provider.of<CreatePostProvider>(context);

    return Scaffold(
      appBar: AppAppbar(
        title: 'Create Post',
        actions: [
          GestureDetector(
            onTap: () => postProvider.createPost(context),
            child: AppText(text: "Post", color: context.colorsScheme.primary),
          ),
          SizedBox(width: Sizer.w(3)),
        ],
      ),
      backgroundColor: context.scaffoldBackgroundColor,
      body: AppHorizontalPadding(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: Sizer.h(2)),
              AppText(text: "Published Type"),
              SizedBox(height: Sizer.h(0.5)),
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: Sizer.w(3)),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: context.colorsScheme.onSecondaryContainer,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: DropdownButton<String>(
                  value: postProvider.selectedPrivacy,
                  isExpanded: true,
                  items:
                      postProvider.itemsSelectedPrivacy
                          .map(
                            (item) => DropdownMenuItem<String>(
                              value: item,
                              child: AppText(text: item),
                            ),
                          )
                          .toList(),
                  underline: SizedBox(),
                  onChanged: (value) {
                    if (value != null) {
                      postProvider.setSelectedPrivacy(value);
                    }
                  },
                ),
              ),
              SizedBox(height: Sizer.h(2)),
              CommonTextField2(
                minLines: 5,
                text: "What's on your mind?",
                controller: postProvider.descriptionController,
              ),
              if (postProvider.selectedMediaType == "image" &&
                  postProvider.selectedImage != null)
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  height: Sizer.h(25),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    image: DecorationImage(
                      image: FileImage(postProvider.selectedImage!),
                      fit: BoxFit.cover,
                    ),
                  ),
                )
              else if (postProvider.selectedMediaType == "video" &&
                  postProvider.selectedVideo != null)
                Container(
                  height: Sizer.h(25),
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CommonVideoPlayer(
                      key: ValueKey(postProvider.selectedVideo!.path),
                      source: postProvider.selectedVideo!.path,
                    ),
                  ),
                ),

              Divider(color: context.colorsScheme.onSecondary),
              ListTile(
                leading: Icon(
                  Icons.photo_library,
                  color: context.colorsScheme.primary,
                ),
                title: AppText(text: "Photo/Video", fontSize: Sizer.sp(3.5)),
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    showDragHandle: true,
                    barrierColor: Colors.transparent,
                    backgroundColor:
                        context.theme.bottomSheetTheme.backgroundColor,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                    ),
                    builder: (_) {
                      return Padding(
                        padding: EdgeInsets.all(Sizer.h(2)),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ListTile(
                              leading: const Icon(CupertinoIcons.photo_fill),
                              title: AppText(text: "Choose Image"),
                              onTap: () async {
                                Get.back();
                                await postProvider.pickMediaFromGallery(
                                  isVideo: false,
                                );
                              },
                            ),
                            Divider(color: AppColors.whiteColor),
                            ListTile(
                              leading: Icon(
                                CupertinoIcons.videocam_circle_fill,
                              ),
                              title: AppText(text: "Choose Videos"),
                              onTap: () async {
                                Get.back();
                                await postProvider.pickMediaFromGallery(
                                  isVideo: true,
                                );
                              },
                            ),
                            Divider(color: AppColors.whiteColor),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
              Divider(color: context.colorsScheme.onSecondary),
              // Tag Friends & Location
              ListTile(
                leading: Icon(Icons.person_add_alt_1, color: Colors.blueAccent),
                title: AppText(text: "Tag Friends", fontSize: Sizer.sp(3.5)),
                onTap: () {
                  postProvider.getFriends();
                  Get.to(
                    () => TagFriendScreen(),
                    transition: Transition.fadeIn,
                    duration: const Duration(milliseconds: 500),
                  );
                },
              ),
              if (postProvider.selectedFriendList != null &&
                  postProvider.selectedFriendList.isNotEmpty)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: Sizer.w(4)),
                  child: Wrap(
                    spacing: 8.0,
                    runSpacing: 4.0,
                    children:
                        postProvider.selectedFriendList.map<Widget>((friend) {
                          return Chip(
                            label: AppText(
                              text: friend['name'],
                              fontSize: Sizer.sp(3.2),
                            ),
                            avatar: CircleAvatar(
                              backgroundImage: NetworkImage(
                                friend['photo'].toString(),
                              ),
                            ),
                          );
                        }).toList(),
                  ),
                ),
              Divider(color: context.colorsScheme.onSecondary),
              ListTile(
                leading: Icon(
                  Icons.location_on,
                  color: context.colorsScheme.error,
                ),
                title: AppText(text: "Add Location", fontSize: Sizer.sp(3.5)),
                onTap: () {
                  postProvider.searchMapName = null;
                  Get.to(
                    () => AddLocationScreen(),
                    transition: Transition.fadeIn,
                    duration: const Duration(milliseconds: 500),
                  );
                },
              ),
              postProvider.searchMapName != null
                  ? Padding(
                    padding: EdgeInsets.symmetric(horizontal: Sizer.w(4)),
                    child: Chip(
                      label: AppText(
                        text: postProvider.searchMapName ?? "",
                        fontSize: Sizer.sp(3.2),
                      ),
                    ),
                  )
                  : SizedBox(),
              Divider(color: context.colorsScheme.onSecondary),
            ],
          ),
        ),
      ),
    );
  }
}
