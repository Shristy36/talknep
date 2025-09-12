import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:talknep/UI/another%20user%20profile/another_user_profile_screen.dart';
import 'package:talknep/components/net_image.dart';
import 'package:talknep/provider/another%20user%20profile/another_user_profile_provider.dart';
import 'package:talknep/provider/menu/profile_provider.dart';
import 'package:talknep/util/theme_extension.dart';
import 'package:talknep/widget/app_loader.dart';
import 'package:talknep/widget/app_sizer.dart';
import 'package:talknep/widget/app_text.dart';

class UsersFriends extends StatelessWidget {
  const UsersFriends({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.friendsListData.isEmpty) {
          return CommonLoader();
        }

        if (provider.friendsListData.isEmpty) {
          return const Center(child: AppText(text: "No friends found"));
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: min(provider.friendsListData.length, 6),
          padding: EdgeInsets.only(top: Sizer.h(1), bottom: Sizer.h(2)),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: Sizer.h(2),
            crossAxisSpacing: Sizer.w(3),
            childAspectRatio: Sizer.w(1.2) / Sizer.h(0.75),
          ),
          itemBuilder: (context, index) {
            final friend = provider.friendsListData[index];
            return GestureDetector(
              onTap: () {
                anotherUserProfileId = friend['friend_id'];
                Get.to(
                  transition: Transition.fadeIn,
                  () => const AnotherUserProfileScreen(),
                  duration: const Duration(milliseconds: 500),
                );
              },
              child: FriendsCard(
                image: friend['photo'],
                userName: friend['name'],
              ),
            );
          },
        );
      },
    );
  }
}

class FriendsCard extends StatelessWidget {
  final String? image;
  final String? userName;

  const FriendsCard({super.key, this.image, this.userName});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.colorsScheme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: context.colorsScheme.onSecondary),
        boxShadow: [
          BoxShadow(
            blurRadius: 4,
            spreadRadius: 1,
            offset: const Offset(0, 2),
            color: context.colorsScheme.shadow,
          ),
        ],
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
            child: NetImage(
              fit: BoxFit.cover,
              height: Sizer.h(14),
              imageUrl: image ?? "",
              width: double.infinity,
            ),
          ),
          SizedBox(height: Sizer.h(1)),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: Sizer.w(2)),
            child: Center(
              child: AppText(
                maxLines: 1,
                fontSize: Sizer.sp(3),
                text: userName ?? "Unknown",
              ),
            ),
          ),
        ],
      ),
    );
  }
}
