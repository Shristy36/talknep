import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pod_player/pod_player.dart';
import 'package:talknep/components/net_image.dart';
import 'package:talknep/components/video_loader.dart';
import 'package:talknep/constant/app_color.dart';
import 'package:talknep/constant/global.dart';
import 'package:talknep/gen/assets.gen.dart';
import 'package:talknep/util/color_code_reader.dart';
import 'package:talknep/util/file_checker.dart';
import 'package:talknep/util/theme_extension.dart';
import 'package:talknep/widget/app_sizer.dart';
import 'package:talknep/widget/app_text.dart';

class CreateStory extends StatelessWidget {
  const CreateStory({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(right: Sizer.w(2)),
      child: Container(
        height: Sizer.h(25),
        width: Sizer.w(33),
        margin: EdgeInsets.symmetric(horizontal: Sizer.w(1)),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              blurRadius: 4,
              spreadRadius: 1,
              offset: Offset(0, 2),
              color: context.colorsScheme.shadow,
            ),
          ],
          border: Border.all(color: context.colorsScheme.onSecondary),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Column(
              children: [
                Expanded(
                  flex: 8,
                  child: NetImage(
                    width: double.infinity,
                    imageUrl: Global.userImage ?? '',
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10),
                    ),
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: Container(
                    decoration: BoxDecoration(
                      color: context.colorsScheme.surface,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(12),
                        bottomRight: Radius.circular(12),
                      ),
                    ),
                    child: Center(
                      child: AppText(
                        text: "Add Story",
                        fontSize: Sizer.sp(3.5),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.only(top: Sizer.h(8)),
              child: Icon(
                size: 40,
                CupertinoIcons.add_circled_solid,
                color: context.colorsScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class StoryTabWidget extends StatelessWidget {
  final Map<String, dynamic> storyData;

  const StoryTabWidget({super.key, required this.storyData});

  @override
  Widget build(BuildContext context) {
    final hasPostImages =
        storyData['post_images'] != null && storyData['post_images'].isNotEmpty;

    final firstMedia = hasPostImages ? storyData['post_images'][0] : null;

    return Padding(
      padding: EdgeInsets.only(right: Sizer.w(2)),
      child: Container(
        height: Sizer.h(25),
        width: Sizer.w(33),
        margin: EdgeInsets.symmetric(horizontal: Sizer.w(1)),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              blurRadius: 4,
              spreadRadius: 1,
              offset: Offset(0, 2),
              color: context.colorsScheme.shadow,
            ),
          ],
          border: Border.all(color: context.colorsScheme.onSecondary),
        ),
        child: Stack(
          alignment: Alignment.bottomLeft,
          children: [
            Column(
              children: [
                Expanded(
                  flex: 8,
                  child:
                      storyData['content_type'] == "text"
                          ? Container(
                            width: double.infinity,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color:
                                  (storyData['bg-color'] != null &&
                                          storyData['bg-color']
                                              .toString()
                                              .isNotEmpty)
                                      ? HexColor(storyData['bg-color'])
                                      : Colors.grey.shade200,
                              borderRadius: const BorderRadius.all(
                                Radius.circular(10),
                              ),
                            ),
                            child: AppText(
                              fontSize: 18,
                              textAlign: TextAlign.center,
                              fontWeight: FontWeight.bold,
                              text: storyData['description'] ?? "",
                            ),
                          )
                          : (firstMedia != null
                              ? isVideoFile(firstMedia)
                                  ? ClipRRect(
                                    borderRadius: const BorderRadius.all(
                                      Radius.circular(12),
                                    ),
                                    child: CommonVideoPlayer(
                                      autoPlay: false,
                                      isLooping: true,
                                      source: firstMedia,
                                      onVideoError: () {
                                        return Container(
                                          margin: EdgeInsets.symmetric(
                                            horizontal: Sizer.w(2),
                                          ),
                                          color: context.colorsScheme.surface,
                                          child: AppText(
                                            text: 'Unsupported video format ⚠️',
                                          ),
                                        );
                                      },
                                      matchVideoAspectRatioToFrame: true,
                                      podProgressBarConfig:
                                          PodProgressBarConfig(height: 0),
                                      overlayBuilder: (p0) => Container(),
                                    ),
                                  )
                                  : NetImage(
                                    imageUrl: firstMedia,
                                    borderRadius: const BorderRadius.all(
                                      Radius.circular(10),
                                    ),
                                  )
                              : ClipRRect(
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(12),
                                ),
                                child: Assets.image.png.backgroundImage.image(
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                ),
                              )),
                ),
              ],
            ),
            // User name overlay
            Padding(
              padding: EdgeInsets.only(left: Sizer.h(1), bottom: Sizer.h(0.5)),
              child: AppText(
                maxLines: 2,
                fontSize: Sizer.sp(3),
                fontWeight: FontWeight.w500,
                text: storyData['name'] ?? '',
                color: AppColors.whiteColor,
                shadows: [
                  Shadow(
                    blurRadius: 2,
                    offset: Offset(1, 1),
                    color: context.colorsScheme.shadow,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
