import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talknep/constant/app_color.dart';
import 'package:talknep/util/theme_extension.dart';
import 'package:talknep/widget/app_button.dart';
import 'package:talknep/widget/app_text.dart';

Future<void> showModernLogoutDialog(
  BuildContext context,
  VoidCallback onConfirm, {
  String? headerText,
  String? descriptionText,
}) {
  return showAdaptiveDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) {
      return Dialog(
        backgroundColor: context.theme.dialogTheme.backgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: Duration(milliseconds: 300),
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            context.colorsScheme.primary.withValues(
                              alpha: 0.15,
                            ),
                            context.colorsScheme.primary.withValues(
                              alpha: 0.05,
                            ),
                          ],
                        ),
                      ),
                      child: Icon(
                        size: 36,
                        Icons.power_settings_new_rounded,
                        color: context.colorsScheme.primary,
                      ),
                    ),
                  );
                },
              ),
              SizedBox(height: 24),
              AppText(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                textAlign: TextAlign.center,
                color: context.colorsScheme.onSurface,
                text: headerText ?? 'Logout Confirmation',
              ),
              SizedBox(height: 12),
              AppText(
                fontSize: 15,
                fontWeight: FontWeight.w400,
                textAlign: TextAlign.center,
                color: context.colorsScheme.onSurface.withValues(alpha: 0.6),
                text:
                    descriptionText ??
                    'You will be signed out of your account and returned to the login screen.',
              ),
              SizedBox(height: 32),
              Column(
                children: [
                  AppButton(
                    onPressed: () {
                      Get.back();
                      onConfirm();
                    },
                    child: AppText(
                      text: 'Logout',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.whiteColor,
                    ),
                  ),
                  SizedBox(height: 12),
                  AppButton(
                    onPressed: () => Get.back(),
                    child: AppText(
                      text: 'Cancel',
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.whiteColor,
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
