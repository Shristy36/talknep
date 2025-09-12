import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:talknep/components/app_appbar.dart';
import 'package:talknep/components/app_spacing.dart';
import 'package:talknep/components/video_loader.dart';
import 'package:talknep/constant/app_color.dart';
import 'package:talknep/gen/assets.gen.dart';
import 'package:talknep/provider/dashboard/story_provider.dart';
import 'package:talknep/util/theme_extension.dart';
import 'package:talknep/widget/app_button.dart';
import 'package:talknep/widget/app_sizer.dart';
import 'package:talknep/widget/app_text.dart';
import 'add_text.dart';

class AddStory extends StatelessWidget {
  const AddStory({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => StoryProvider(),
      child: Scaffold(
        appBar: AppAppbar(title: "Add to Story"),
        backgroundColor: context.scaffoldBackgroundColor,
        body: Consumer<StoryProvider>(
          builder: (context, storyProvider, child) {
            return AppHorizontalPadding(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 10),
                    buildMediaOptions(context, storyProvider),
                    SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(horizontal: Sizer.w(3)),
                      decoration: BoxDecoration(
                        color: context.colorsScheme.surface,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: context.colorsScheme.onSecondary,
                        ),
                      ),
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: storyProvider.selectedPrivacy,
                        items:
                            storyProvider.itemsSelectedPrivacy
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
                            storyProvider.setSelectedPrivacy(value);
                          }
                        },
                      ),
                    ),
                    SizedBox(height: 10),
                    buildMediaPreview(storyProvider, context),
                    SizedBox(height: 10),
                  ],
                ),
              ),
            );
          },
        ),
        bottomNavigationBar: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: Sizer.w(3),
            vertical: Sizer.h(1),
          ),
          child: buildShareButton(),
        ),
      ),
    );
  }

  Widget buildMediaOptions(BuildContext context, StoryProvider provider) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          GestureDetector(
            onTap: () {
              provider.pickCamera();
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.blackColor.withAlpha(100)),
              ),
              child: Assets.icon.storyCamera.svg(height: 101, width: 85),
            ),
          ),
          SizedBox(width: Sizer.w(2.5)),
          GestureDetector(
            onTap: () {
              Get.to(
                () => AddStoryText(),
                transition: Transition.fadeIn,
                duration: const Duration(milliseconds: 500),
              );
            },
            child: Container(
              child: Assets.icon.storyText.svg(height: 101, width: 85),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.blackColor.withAlpha(100)),
              ),
            ),
          ),
          SizedBox(width: Sizer.w(2.5)),
          GestureDetector(
            onTap: provider.pickImageFromGallery,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.blackColor.withAlpha(100)),
              ),
              child: Assets.icon.storyPhoto1.image(width: 85, height: 101),
            ),
          ),
          SizedBox(width: Sizer.w(2.5)),
          GestureDetector(
            onTap: provider.pickVideoFromGallery,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.blackColor.withAlpha(100)),
              ),
              child: Assets.icon.storyVideo1.image(width: 85, height: 101),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildMediaPreview(StoryProvider provider, BuildContext context) {
    if (provider.selectedStoryImage == null && provider.video == null) {
      return Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          color: context.colorsScheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: context.colorsScheme.onSecondary),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [AppText(text: "No media selected")],
        ),
      );
    }
    return SizedBox(
      width: double.infinity,
      child:
          provider.selectedStoryImage != null
              ? ClipRRect(
                child: Image.file(
                  fit: BoxFit.cover,
                  provider.selectedStoryImage!,
                ),
                borderRadius: BorderRadius.all(Radius.circular(10)),
              )
              : ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                child: CommonVideoPlayer(
                  source: provider.video!.path,
                  key: ValueKey(provider.video!.path),
                  onVideoError: () {
                    return Container(
                      height: Sizer.h(25),
                      width: double.infinity,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: context.colorsScheme.surface,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: context.colorsScheme.onSecondary,
                        ),
                      ),
                      child: AppText(text: 'Unsupported video format ⚠️'),
                    );
                  },
                ),
              ),
    );
  }

  Widget buildShareButton() {
    return Consumer<StoryProvider>(
      builder: (context, provider, child) {
        return AppButton(
          onPressed: () async {
            provider.createStory(context);
          },
          child: AppText(text: "share", color: AppColors.whiteColor),
        );
      },
    );
  }
}
