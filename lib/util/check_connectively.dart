import 'dart:ui';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talknep/constant/app_color.dart';
import 'package:talknep/gen/assets.gen.dart';
import 'package:talknep/widget/app_button.dart';
import 'package:talknep/widget/app_sizer.dart';
import 'package:talknep/widget/app_text.dart';

Future checkInternetConnection({required VoidCallback onConnected}) async {
  final connectivityResult = await Connectivity().checkConnectivity();
  if (connectivityResult.contains(ConnectivityResult.none)) {
    AppDialog.showInternetDialog(
      onRetry: () {
        Get.back();
        checkInternetConnection(onConnected: onConnected);
      },
    );
  } else {
    onConnected();
  }
  return connectivityResult;
}

class AppDialog {
  AppDialog._();

  static Future<bool> showCloseDialog({String? title, String? message}) async {
    return await showCupertinoDialog(
      barrierDismissible: false,
      context: Get.context!,
      builder: (context) {
        var themeColor = Theme.of(context);
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 2.0, sigmaY: 2.0),
          child: Dialog(
            elevation: 0,
            backgroundColor: themeColor.primaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(2.h),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 4.w),
                  child: Column(
                    children: [
                      AppText(
                        text: "Exit app",
                        maxLines: 2,
                        color: themeColor.colorScheme.primary,
                        fontSize: 2.h,
                        fontWeight: FontWeight.w700,
                      ),
                      SizedBox(height: 2.h),
                      AppText(
                        text: 'Are you sure you want to exit the app?',
                        textAlign: TextAlign.center,
                        color: themeColor.colorScheme.secondary,
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
                Container(
                  height: 0.1.h,
                  width: double.infinity,
                  color: themeColor.colorScheme.primary,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Get.back();
                        },
                        child: Container(
                          height: 6.h,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(3.w),
                            ),
                          ),
                          child: Center(
                            child: AppText(
                              text: 'No',
                              fontWeight: FontWeight.w400,
                              color: themeColor.colorScheme.shadow,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          Get.back();
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: themeColor.colorScheme.primary,
                            borderRadius: BorderRadius.only(
                              bottomRight: Radius.circular(3.w),
                            ),
                          ),
                          height: 6.h,
                          child: Center(
                            child: AppText(
                              text: 'Yes',
                              fontWeight: FontWeight.w400,
                              color: themeColor.colorScheme.surface,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static void showInternetDialog({required VoidCallback onRetry}) {
    showCupertinoDialog(
      context: Get.context!,
      barrierDismissible: false,
      builder: (context) {
        return PopScope(
          canPop: false,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 2.0, sigmaY: 2.0),
            child: FocusScope(
              node: FocusScopeNode(canRequestFocus: false),
              child: AlertDialog.adaptive(
                buttonPadding: EdgeInsets.zero,
                actionsAlignment: MainAxisAlignment.center,
                title: ClipRRect(
                  child: Assets.lottie.noNet.lottie(),
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ),
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                titlePadding: EdgeInsets.only(top: 1.h, left: 8.w, right: 8.w),
                shape: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(6.w),
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppText(fontSize: 2.h, text: 'Whoops!'),
                    SizedBox(height: 1.h),
                    AppText(
                      maxLines: 3,
                      fontSize: 1.5.h,
                      fontWeight: FontWeight.w600,
                      textAlign: TextAlign.center,
                      text: 'No internet connection found.',
                    ),
                    SizedBox(height: 0.5.h),
                    AppText(
                      maxLines: 3,
                      fontSize: 1.7.h,
                      textAlign: TextAlign.center,
                      fontWeight: FontWeight.w900,
                      text: 'Check your connection and try again.',
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ],
                ),
                actions: [
                  AppButton(
                    width: 60.w,
                    onPressed: onRetry,
                    child: AppText(
                      fontSize: 1.8.h,
                      text: 'Try Again',
                      fontWeight: FontWeight.w600,
                      color: AppColors.whiteColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
