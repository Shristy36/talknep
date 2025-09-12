import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:talknep/components/app_appbar.dart';
import 'package:talknep/components/app_spacing.dart';
import 'package:talknep/components/net_image.dart';
import 'package:talknep/constant/global.dart';
import 'package:talknep/provider/menu/group/group_provider.dart';
import 'package:talknep/util/theme_extension.dart';
import 'package:talknep/UI/menu/group/create_group_screen.dart';
import 'package:talknep/widget/app_button.dart';
import 'package:talknep/widget/app_loader.dart';
import 'package:talknep/widget/app_sizer.dart';
import 'package:talknep/widget/app_text.dart';
import 'group_details_screen.dart';

class GroupScreen extends StatelessWidget {
  const GroupScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<GroupProvider>(context);
    return Scaffold(
      backgroundColor: context.scaffoldBackgroundColor,
      appBar: AppAppbar(
        title: 'Groups',
        actions: [
          IconButton(
            onPressed: () {
              Get.to(
                () => CreateGroupScreen(),
                transition: Transition.fadeIn,
                duration: const Duration(milliseconds: 500),
              );
            },
            icon: Icon(Icons.add),
          ),
        ],
      ),
      body:
          provider.isLoading
              ? CommonLoader(fullScreen: true)
              : RefreshIndicator.adaptive(
                onRefresh: () async {
                  await provider.getGroupsListData();
                },
                backgroundColor: context.scaffoldBackgroundColor,
                child: AppHorizontalPadding(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: Sizer.h(1)),
                      SizedBox(
                        height: Sizer.h(5.5),
                        child: CupertinoSearchTextField(
                          controller: provider.searchController,
                          focusNode: provider.focusNode,
                          placeholder: "Search group",
                          placeholderStyle: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: context.colorsScheme.onSurface,
                            fontFamily: GoogleFonts.poppins().fontFamily,
                          ),
                          prefixIcon: Icon(
                            CupertinoIcons.search,
                            color: context.colorsScheme.onSurface,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          prefixInsets: EdgeInsets.only(left: 15.0),
                          suffixInsets: EdgeInsets.only(right: 10.0),
                          onChanged: provider.filterGroupName,
                          onSubmitted: (_) => provider.focusNode.unfocus(),
                        ),
                      ),
                      SizedBox(height: Sizer.h(2)),
                      AppText(text: "All Groups", fontWeight: FontWeight.w500),
                      SizedBox(height: Sizer.h(1)),
                      Expanded(
                        child: ListView.builder(
                          itemCount: provider.filteredGroupName.length,
                          itemBuilder: (context, index) {
                            final groupData = provider.filteredGroupName[index];
                            return GestureDetector(
                              onTap: () {
                                groupDetailsId = groupData['id'];
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => GroupDetailsScreen(
                                          groupName: groupData['title'],
                                          groupImageUrl: groupData['logo'],
                                          groupDescription:
                                              groupData['about'] ?? "",
                                          membersCount:
                                              groupData['group_members_count'],
                                          isJoined:
                                              groupData['is_Joined'] == 1
                                                  ? true
                                                  : false,
                                          isOwner:
                                              (groupData['user_id']
                                                          .toString() ==
                                                      Global
                                                          .userProfileData['id']
                                                          .toString()
                                                  ? true
                                                  : false),
                                        ),
                                  ),
                                );
                              },
                              child: customCard(groupData, context, provider),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }

  Widget customCard(
    dynamic data,
    BuildContext context,
    GroupProvider provider,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Sizer.w(2),
        vertical: Sizer.h(1),
      ),
      margin: EdgeInsets.only(bottom: Sizer.h(2)),
      decoration: BoxDecoration(
        color: context.scaffoldBackgroundColor,
        border: Border.all(color: context.colorsScheme.onSecondary),
        borderRadius: BorderRadius.circular(12),
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
          Row(
            children: [
              SizedBox(
                height: Sizer.h(9),
                width: Sizer.w(20),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: NetImage(imageUrl: data['logo'], fit: BoxFit.cover),
                ),
              ),
              SizedBox(width: Sizer.w(3)),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(text: data["title"], fontWeight: FontWeight.w500),
                  SizedBox(height: Sizer.h(0.2)),
                  AppText(
                    fontSize: Sizer.sp(2.8),
                    text: "public *${data["group_members_count"]} Member",
                  ),
                  SizedBox(height: Sizer.h(0.2)),
                  AppText(
                    fontSize: Sizer.sp(2.8),
                    text: "${data["matching_friends_count"]} friend are member",
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: Sizer.h(1.5)),
          AppButton(
            backgroundColor:
                data["is_Joined"] == 1
                    ? context.colorsScheme.onSecondary
                    : context.colorsScheme.primary,
            onPressed: () {
              if (data["is_Joined"] == 1) {
              } else {
                provider.getGroupsJoinData(data['id']);
              }
            },
            height: Sizer.h(5.5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                (data["user_id"].toString() ==
                        Global.userProfileData['id'].toString())
                    ? SizedBox()
                    : Icon(
                      Icons.group,
                      color:
                          data["is_Joined"] == 1
                              ? context.colorsScheme.secondaryContainer
                              : context.colorsScheme.secondaryContainer,
                    ),
                SizedBox(width: Sizer.w(1.5)),
                AppText(
                  text:
                      (data["user_id"].toString() ==
                              Global.userProfileData['id'].toString())
                          ? "Admin"
                          : data["is_Joined"] == 1
                          ? "Joined"
                          : "Join Group",
                  color:
                      data["is_Joined"] == 1
                          ? context.colorsScheme.secondaryContainer
                          : context.colorsScheme.secondaryContainer,
                  fontSize: Sizer.sp(3.5),
                  fontWeight: FontWeight.w500,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
