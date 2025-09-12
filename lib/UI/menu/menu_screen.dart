import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:talknep/components/app_spacing.dart';
import 'package:talknep/constant/global.dart';
import 'package:talknep/l10n/app_localizations.dart';
import 'package:talknep/provider/bottomBar/bottomBar_provider.dart';
import 'package:talknep/provider/menu/menu_provider.dart';
import 'package:talknep/util/theme_extension.dart';
import 'package:talknep/UI/menu/about_screen.dart';
import 'package:talknep/UI/menu/blog/blog_screen.dart';
import 'package:talknep/UI/menu/components/setting_list_tile.dart';
import 'package:talknep/UI/menu/event/event_screen.dart';
import 'package:talknep/UI/menu/page/pages_screen.dart';
import 'package:talknep/UI/menu/privacy_screen.dart';
import 'package:talknep/UI/menu/profile/profile_screen.dart';
import 'package:talknep/widget/app_dialog_box.dart';
import 'package:talknep/widget/app_sizer.dart';
import 'package:talknep/widget/app_text.dart';
import 'group/group_screen.dart';
import 'theme/theme_screen.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: context.scaffoldBackgroundColor,
      body: Consumer<MenuProvider>(
        builder: (context, provider, child) {
          return SingleChildScrollView(
            child: AppHorizontalPadding(
              child: Column(
                children: [
                  SizedBox(height: Sizer.h(1)),
                  GestureDetector(
                    onTap: () {
                      Get.to(
                        () => ProfileScreen(),
                        transition: Transition.fadeIn,
                        duration: const Duration(milliseconds: 500),
                      );
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        vertical: Sizer.h(1),
                        horizontal: Sizer.w(2),
                      ),
                      decoration: BoxDecoration(
                        color: context.colorsScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          width: 0.2,
                          color: context.colorsScheme.onSurface,
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
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundImage: NetworkImage(
                              Global.userImage.toString(),
                            ),
                          ),
                          SizedBox(width: Sizer.w(2)),
                          AppText(
                            fontWeight: FontWeight.w500,
                            text: Global.userProfileData['name'] ?? '',
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: Sizer.h(2)),
                  GridView.builder(
                    shrinkWrap: true,
                    itemCount: provider.menuList.length,
                    padding: EdgeInsets.only(bottom: Sizer.h(2)),
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: Sizer.h(2),
                      crossAxisSpacing: Sizer.w(3),
                      childAspectRatio: Sizer.w(1.1) / Sizer.h(0.25),
                    ),
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          if (index == 0) {
                            Provider.of<BottomBarProvider>(
                              context,
                              listen: false,
                            ).changeIndex(context, 0);
                          } else if (index == 1) {
                            Get.to(
                              () => ProfileScreen(),
                              transition: Transition.fadeIn,
                              duration: const Duration(milliseconds: 500),
                            );
                          } else if (index == 2) {
                            Get.to(
                              () => GroupScreen(),
                              transition: Transition.fadeIn,
                              duration: const Duration(milliseconds: 500),
                            );
                          } else if (index == 3) {
                            Get.to(
                              () => PagesScreen(),
                              transition: Transition.fadeIn,
                              duration: const Duration(milliseconds: 500),
                            );
                          } else if (index == 4) {
                            Provider.of<BottomBarProvider>(
                              context,
                              listen: false,
                            ).changeIndex(context, 3);
                          } else if (index == 5) {
                            Provider.of<BottomBarProvider>(
                              context,
                              listen: false,
                            ).changeIndex(context, 1);
                          } else if (index == 6) {
                            Get.to(
                              () => EventsScreen(),
                              transition: Transition.fadeIn,
                              duration: const Duration(milliseconds: 500),
                            );
                          } else if (index == 7) {
                            Get.to(
                              () => BlogScreen(),
                              transition: Transition.fadeIn,
                              duration: const Duration(milliseconds: 500),
                            );
                          }
                        },

                        child: customCard(
                          context: context,
                          height:
                              (provider.menuList[index]['height'] as num?)
                                  ?.toDouble(),

                          image: provider.menuList[index]['Image'],
                          text: provider.menuList[index]['Title'],
                        ),
                      );
                    },
                  ),
                  SizedBox(height: Sizer.h(2)),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      horizontal: Sizer.w(3),
                      vertical: Sizer.h(2),
                    ),
                    decoration: BoxDecoration(
                      color: context.colorsScheme.surface,
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 4,
                          spreadRadius: 1,
                          offset: Offset(0, 2),
                          color: context.colorsScheme.shadow,
                        ),
                      ],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        width: 0.2,
                        color: context.colorsScheme.onSurface,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SettingListTile(
                          local: local,
                          title: local.about,
                          onTap: () {
                            Get.to(
                              () => AboutScreen(),
                              transition: Transition.fadeIn,
                              duration: const Duration(milliseconds: 500),
                            );
                          },
                        ),
                        SettingListTile(
                          local: local,
                          title: local.theme,
                          onTap: () {
                            Get.to(
                              () => ThemeScreen(),
                              transition: Transition.fadeIn,
                              duration: const Duration(milliseconds: 500),
                            );
                          },
                        ),
                        SettingListTile(
                          local: local,
                          title: local.privacyPolicy,
                          onTap: () {
                            Get.to(
                              () => PrivacyPolicyScreen(),
                              transition: Transition.fadeIn,
                              duration: const Duration(milliseconds: 500),
                            );
                          },
                        ),
                        SettingListTile(
                          local: local,
                          isDivider: false,
                          title: local.logout,
                          onTap: () {
                            showModernLogoutDialog(
                              context,
                              () => provider.logout(context),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: Sizer.h(2)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget customCard({
    required BuildContext context,
    dynamic height,
    String? image,
    String? text,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: Sizer.w(3)),
      decoration: BoxDecoration(
        color: context.colorsScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.colorsScheme.onSecondary, width: 0.4),
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
        spacing: 5,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: height ?? 30,
            width: height ?? 30,
            child: Image.asset(image ?? ''),
          ),
          AppText(text: text ?? "", fontWeight: FontWeight.w500),
        ],
      ),
    );
  }
}
