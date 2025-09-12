import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:talknep/components/app_spacing.dart';
import 'package:talknep/constant/app_color.dart';
import 'package:talknep/provider/notification/notification_provider.dart';
import 'package:talknep/util/theme_extension.dart';
import 'package:talknep/widget/app_button.dart';
import 'package:talknep/widget/app_loader.dart';
import 'package:talknep/widget/app_sizer.dart';
import 'package:talknep/widget/app_text.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<NotificationProvider>(
        context,
        listen: false,
      ).notificationAPI();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.scaffoldBackgroundColor,
      body: Consumer<NotificationProvider>(
        builder: (context, provider, child) {
          return AppHorizontalPadding(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child:
                      provider.isLoading
                          ? Center(
                            child: CommonLoader(
                              fullScreen: true,
                              color: context.colorsScheme.primary,
                            ),
                          )
                          : RefreshIndicator.adaptive(
                            onRefresh: () async {
                              await provider.notificationAPI(force: true);
                            },
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  AppText(
                                    text: "New",
                                    fontWeight: FontWeight.w500,
                                  ),
                                  ...List.generate(
                                    provider
                                        .notificationData['new_notifications']
                                        .length,
                                    (index) {
                                      return customCard(
                                        provider,
                                        image:
                                            provider
                                                .notificationData['new_notifications'][index]['photo'],
                                        userName:
                                            provider
                                                .notificationData['new_notifications'][index]['name'],
                                        timeSeen:
                                            provider
                                                .notificationData['new_notifications'][index]['created_at'],
                                        userType:
                                            provider
                                                .notificationData['new_notifications'][index]['type'],
                                        userId:
                                            provider
                                                .notificationData['new_notifications'][index]['sender_user_id']
                                                .toString(),
                                      );
                                    },
                                  ),
                                  SizedBox(height: Sizer.h(2)),
                                  AppText(
                                    text: "Earlier",
                                    fontWeight: FontWeight.w500,
                                  ),
                                  ...List.generate(
                                    provider
                                        .notificationData['older_notifications']
                                        .length,
                                    (index) {
                                      return customCard(
                                        provider,
                                        image:
                                            provider
                                                .notificationData['older_notifications'][index]['photo'],
                                        userName:
                                            provider
                                                .notificationData['older_notifications'][index]['name'],
                                        timeSeen:
                                            provider
                                                .notificationData['older_notifications'][index]['created_at'],
                                        userType:
                                            provider
                                                .notificationData['older_notifications'][index]['type'],
                                        userId:
                                            provider
                                                .notificationData['older_notifications'][index]['sender_user_id']
                                                .toString(),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget customCard(
    NotificationProvider provider, {
    String? image,
    String? userId,
    String? userName,
    String? timeSeen,
    String? userType,
  }) {
    String userTypeText =
        (userType == "friend_request_accept")
            ? "Accepted your friend request."
            : (userType == "profile")
            ? "Sent you a friend request."
            : "Sent you a notification.";

    return Container(
      padding: EdgeInsets.symmetric(
        vertical: Sizer.h(2),
        horizontal: Sizer.w(3),
      ),
      margin: EdgeInsets.symmetric(vertical: Sizer.h(1)),
      decoration: BoxDecoration(
        color: context.scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: context.colorsScheme.onSecondary),
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
        children: [
          Row(
            children: [
              CircleAvatar(radius: 20, backgroundImage: NetworkImage(image!)),
              SizedBox(width: Sizer.w(4)),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(text: userName!, fontWeight: FontWeight.w500),
                  AppText(text: userTypeText, fontSize: Sizer.sp(2.5)),
                ],
              ),
              Spacer(),
              AppText(
                text: timeSeen!,
                fontSize: Sizer.sp(2.5),
                color: context.colorsScheme.primary,
              ),
            ],
          ),
          (userTypeText == "Sent you a friend request.")
              ? Padding(
                padding: EdgeInsets.only(top: Sizer.h(1)),
                child: Row(
                  children: [
                    SizedBox(width: Sizer.w(10)),
                    Container(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            spreadRadius: 1,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                            color: context.colorsScheme.shadow,
                          ),
                        ],
                      ),
                      child: AppButton(
                        height: Sizer.h(4.5),
                        width: Sizer.w(30),
                        onPressed: () {
                          provider.acceptFriendRequest(userId);
                        },
                        child: AppText(
                          text: "Confirm",
                          fontSize: Sizer.sp(3.5),
                          color: AppColors.whiteColor,
                        ),
                      ),
                    ),
                    SizedBox(width: Sizer.w(2)),
                    AppButton(
                      height: Sizer.h(4.5),
                      width: Sizer.w(30),
                      backgroundColor: AppColors.whiteColor,
                      borderColor: context.colorsScheme.primary,
                      onPressed: () {
                        provider.rejectFriendRequest(userId);
                      },
                      child: AppText(
                        text: "Delete",
                        color: context.colorsScheme.primary,
                      ),
                    ),
                  ],
                ),
              )
              : SizedBox(),
        ],
      ),
    );
  }
}
