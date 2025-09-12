import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:talknep/components/app_appbar.dart';
import 'package:talknep/components/app_spacing.dart';
import 'package:talknep/components/video_loader.dart';
import 'package:talknep/constant/app_color.dart';
import 'package:talknep/gen/assets.gen.dart';
import 'package:talknep/provider/video/video_provider.dart';
import 'package:talknep/util/theme_extension.dart';
import 'package:talknep/widget/app_button.dart';
import 'package:talknep/widget/app_loader.dart';
import 'package:talknep/widget/app_showPicker.dart';
import 'package:talknep/widget/app_sizer.dart';
import 'package:talknep/widget/app_text.dart';
import 'package:talknep/widget/app_textfield.dart';

class CreateVideo extends StatelessWidget {
  const CreateVideo({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => VideoProvider(),
      child: Scaffold(
        appBar: AppAppbar(title: "Upload Videos/Shorts"),
        backgroundColor: context.scaffoldBackgroundColor,
        body: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: AppHorizontalPadding(
            child: Consumer<VideoProvider>(
              builder: (context, provider, child) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: Sizer.h(2)),
                    AppText(text: "Title"),
                    SizedBox(height: Sizer.h(0.5)),
                    CommonTextField2(
                      text: "Enter video/short title",
                      controller: provider.titleController,
                      textInputAction: TextInputAction.next,
                    ),
                    SizedBox(height: Sizer.h(2)),
                    AppText(text: "Privacy"),
                    SizedBox(height: Sizer.h(0.5)),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(horizontal: Sizer.w(3)),
                      decoration: BoxDecoration(
                        color: context.scaffoldBackgroundColor,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: context.colorsScheme.onSecondary,
                        ),
                      ),
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: provider.selectedPrivacy,
                        items:
                            provider.itemsSelectedPrivacy
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
                            provider.setSelectedPrivacy(value);
                          }
                        },
                      ),
                    ),
                    SizedBox(height: Sizer.h(2)),
                    AppText(text: "Category"),
                    SizedBox(height: Sizer.h(0.5)),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(horizontal: Sizer.w(3)),
                      decoration: BoxDecoration(
                        color: context.scaffoldBackgroundColor,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: context.colorsScheme.onSecondary,
                        ),
                      ),
                      child: DropdownButton<String>(
                        value: provider.selectedCategory,
                        isExpanded: true,
                        items:
                            provider.itemsSelectedCategory
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
                            provider.setSelectedCategory(value);
                          }
                        },
                      ),
                    ),
                    SizedBox(height: Sizer.h(2)),
                    Container(
                      height: Sizer.h(28),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: context.scaffoldBackgroundColor,
                        borderRadius: BorderRadius.circular(12),
                        border:
                            provider.video == null
                                ? Border.all(
                                  color: context.colorsScheme.onSecondary,
                                )
                                : null,
                      ),
                      child:
                          provider.video == null
                              ? InkWell(
                                onTap: () => provider.pickVideoFromGallery(),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      size: 6.h,
                                      CupertinoIcons.videocam_circle_fill,
                                    ),
                                    AppText(
                                      fontWeight: FontWeight.w500,
                                      text: 'Tap to select videos',
                                    ),
                                  ],
                                ),
                              )
                              : Stack(
                                children: [
                                  Positioned.fill(
                                    child: SizedBox(
                                      width: double.infinity,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: CommonVideoPlayer(
                                          source: provider.video!.path,
                                          key: ValueKey(provider.video!.path),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 1.h,
                                    child: IconButton(
                                      padding: EdgeInsets.zero,
                                      alignment: Alignment.topLeft,
                                      onPressed: () {
                                        provider.removeSelectedVideo();
                                      },
                                      icon: Icon(
                                        CupertinoIcons.clear_thick_circled,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                    ),
                    SizedBox(height: Sizer.h(2)),
                    GestureDetector(
                      onTap: () {
                        showImagePickerBottomSheet(
                          context: context,
                          onImageSelected: (File image) async {
                            provider.setSelectedGroupImage(image);
                          },
                        );
                      },
                      child: SizedBox(
                        height: Sizer.h(25),
                        width: double.infinity,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child:
                              provider.selectedGroupImage != null
                                  ? Image.file(
                                    fit: BoxFit.cover,
                                    provider.selectedGroupImage!,
                                  )
                                  : Assets.image.png.backgroundImage.image(
                                    fit: BoxFit.cover,
                                  ),
                        ),
                      ),
                    ),
                    SizedBox(height: Sizer.h(2)),
                    provider.isLoading
                        ? CommonLoader()
                        : AppButton(
                          onPressed: () => provider.createVideos(context),
                          child: AppText(
                            text: "Upload",
                            color: AppColors.whiteColor,
                          ),
                        ),
                    SizedBox(height: Sizer.h(2)),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
