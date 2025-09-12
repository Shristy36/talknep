import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:talknep/components/app_appbar.dart';
import 'package:talknep/components/net_image.dart';
import 'package:talknep/constant/app_color.dart';
import 'package:talknep/provider/menu/group/group_provider.dart';
import 'package:talknep/util/theme_extension.dart';
import 'package:talknep/UI/menu/group/update_group_screen.dart';
import 'package:talknep/widget/app_button.dart';
import 'package:talknep/widget/app_sizer.dart';
import 'package:talknep/widget/app_text.dart';

dynamic groupDetailsId;

class GroupDetailsScreen extends StatelessWidget {
  final String groupName;
  final String groupImageUrl;
  final String groupDescription;
  final int membersCount;
  final bool isJoined;
  final bool isOwner;

  const GroupDetailsScreen({
    super.key,
    required this.groupName,
    required this.groupImageUrl,
    required this.groupDescription,
    required this.membersCount,
    this.isJoined = false,
    this.isOwner = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppAppbar(title: "Groups Details"),
      backgroundColor: context.scaffoldBackgroundColor,
      body: Consumer<GroupProvider>(
        builder: (context, provider, child) {
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    NetImage(
                      fit: BoxFit.cover,
                      height: Sizer.h(30),
                      width: double.infinity,
                      imageUrl: groupImageUrl,
                    ),
                    Container(
                      height: Sizer.h(30),
                      width: double.infinity,
                      color: AppColors.blackColor.withValues(alpha: 0.4),
                    ),
                    Positioned(
                      left: 16,
                      bottom: 16,
                      child: AppText(
                        text: groupName,
                        fontSize: Sizer.h(3.5),
                        fontWeight: FontWeight.w600,
                        color: AppColors.whiteColor,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 2.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: Sizer.w(3)),
                  child: Material(
                    elevation: 1.5,
                    borderRadius: BorderRadius.circular(12),
                    color: context.scaffoldBackgroundColor,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 16,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: context.colorsScheme.onSecondary,
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Icon(
                                size: 20,
                                Icons.group,
                                color: context.colorsScheme.secondaryContainer
                                    .withAlpha(100),
                              ),
                              const SizedBox(width: 6),
                              AppText(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                text: "$membersCount members",
                                color: context.colorsScheme.secondaryContainer
                                    .withAlpha(100),
                              ),
                            ],
                          ),
                          SizedBox(height: Sizer.h(1)),
                          Row(
                            children: [
                              Expanded(
                                child: AppButton(
                                  onPressed: () {
                                    if (isOwner) {
                                      Get.to(
                                        () => UpdateGroupScreen(),
                                        transition: Transition.fadeIn,
                                        duration: const Duration(
                                          milliseconds: 500,
                                        ),
                                      );
                                    } else {
                                      if (isJoined) {
                                        provider.getGroupsRemoveData(
                                          groupDetailsId,
                                        );
                                      }
                                    }
                                  },
                                  height: Sizer.h(4.2),
                                  child: AppText(
                                    text:
                                        (isOwner)
                                            ? "Edit"
                                            : isJoined
                                            ? "Leave"
                                            : "Join",
                                    fontSize: Sizer.sp(3.4),
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.whiteColor,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: AppButton(
                                  onPressed: () {},
                                  height: Sizer.h(4.2),
                                  backgroundColor: AppColors.greyColor,
                                  borderColor: context.colorsScheme.onSecondary,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.share,
                                        size: 16,
                                        color: Colors.black,
                                      ),
                                      const SizedBox(width: 4),
                                      AppText(
                                        text: "Share",
                                        fontSize: Sizer.sp(3.2),
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.blackColor,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: Sizer.w(3)),
                  child: AppText(
                    text: "About Group",
                    fontSize: Sizer.sp(3.6),
                    fontWeight: FontWeight.w600,
                    color: AppColors.blackColor,
                  ),
                ),
                SizedBox(height: Sizer.h(1)),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: Sizer.w(3)),
                  child: AppText(
                    text: groupDescription,
                    fontSize: Sizer.sp(3.3),
                    fontWeight: FontWeight.w400,
                  ),
                ),
                SizedBox(height: Sizer.h(2)),
              ],
            ),
          );
        },
      ),
    );
  }
}
