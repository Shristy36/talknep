import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talknep/UI/chat/chat_friend_list.dart';
import 'package:talknep/UI/market%20place/create_market_place_screen.dart';
import 'package:talknep/UI/search%20all%20friend/search_all_friend_screen.dart';
import 'package:talknep/UI/video/create_video.dart';
import 'package:talknep/gen/assets.gen.dart';
import 'package:talknep/util/theme_extension.dart';
import 'package:talknep/widget/app_sizer.dart';

class CommonAppBar extends StatelessWidget implements PreferredSizeWidget {
  final int index;
  const CommonAppBar({super.key, required this.index});
  @override
  Size get preferredSize => Size.fromHeight(Sizer.h(7));
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: Sizer.w(4)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(height: Sizer.h(5), child: Assets.image.png.appIcon.image()),
            Row(
              spacing: Sizer.w(1),
              children: [
                if (index == 2 || index == 3) ...[
                  GestureDetector(
                    onTap: () {
                      if (index == 2) {
                        Get.to(
                          () => CreateVideo(),
                          transition: Transition.fadeIn,
                          duration: const Duration(milliseconds: 500),
                        );
                      } else {
                        Get.to(
                          transition: Transition.fadeIn,
                          () => CreateMarketPlaceScreen(),
                          duration: const Duration(milliseconds: 500),
                        );
                      }
                    },
                    child: Icon(Icons.add),
                  ),
                  SizedBox(width: Sizer.w(2)),
                ],
                GestureDetector(
                  onTap: () {
                    Get.to(
                      transition: Transition.fadeIn,
                      () => const SearchAllFriendScreen(),
                      duration: const Duration(milliseconds: 500),
                    );
                  },
                  child: const Icon(Icons.search_outlined),
                ),
                SizedBox(width: Sizer.w(2)),
                SizedBox(
                  height: Sizer.h(6),
                  width: Sizer.w(6),
                  child: GestureDetector(
                    onTap: () {
                      Get.to(
                        transition: Transition.fadeIn,
                        () => const ChatFriendListScreen(),
                        duration: const Duration(milliseconds: 500),
                      );
                    },
                    child: Assets.icon.messageIcon.image(
                      color: context.colorsScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
