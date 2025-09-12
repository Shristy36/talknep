import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:talknep/components/app_spacing.dart';
import 'package:talknep/constant/app_color.dart';
import 'package:talknep/gen/assets.gen.dart';
import 'package:talknep/l10n/app_localizations.dart';
import 'package:talknep/provider/auth/register_provider.dart';
import 'package:talknep/util/theme_extension.dart';
import 'package:talknep/UI/auth/login_screen.dart';
import 'package:talknep/widget/app_button.dart';
import 'package:talknep/widget/app_loader.dart';
import 'package:talknep/widget/app_sizer.dart';
import 'package:talknep/widget/app_text.dart';
import 'package:talknep/widget/app_textfield.dart';

class RegisterScreen extends StatelessWidget {
  RegisterScreen({super.key});

  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: context.scaffoldBackgroundColor,
      body: Consumer<RegisterProvider>(
        builder: (context, provider, child) {
          return SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: Form(
              key: formKey,
              child: AppHorizontalPadding(
                child: Column(
                  children: [
                    SizedBox(height: Sizer.h(10)),
                    Transform.scale(
                      scale: 0.8,
                      child: Assets.image.png.appIcon.image(),
                    ),
                    SizedBox(height: Sizer.h(8)),
                    CommonTextField(
                      controller: provider.usernameController,
                      labelText: local.fullName,
                      hintText: 'username',
                      prefixIcon: Icons.person,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                    ),
                    SizedBox(height: Sizer.h(2)),
                    CommonTextField(
                      controller: provider.emailController,
                      labelText: local.email,
                      hintText: 'example@email.com',
                      prefixIcon: Icons.email,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                    ),
                    SizedBox(height: Sizer.h(2)),
                    CommonTextField(
                      controller: provider.passwordController,
                      labelText: local.password,
                      hintText: '********',
                      prefixIcon: Icons.lock,
                      isPassword: true,
                      textInputAction: TextInputAction.next,
                    ),
                    SizedBox(height: Sizer.h(2)),
                    CommonTextField(
                      controller: provider.confirmPasswordController,
                      labelText: local.confirmPassword,
                      hintText: '********',
                      prefixIcon: Icons.lock,
                      isPassword: true,
                      textInputAction: TextInputAction.done,
                    ),
                    SizedBox(height: Sizer.h(2)),
                    AppButton(
                      onPressed: () {
                        provider.registerAPI(context);
                      },
                      backgroundColor: context.colorsScheme.primary,
                      child:
                          provider.isLoading
                              ? CommonLoader(
                                size: 3,
                                color: AppColors.whiteColor,
                              )
                              : AppText(
                                text: local.signUp,
                                color: AppColors.whiteColor,
                                fontWeight: FontWeight.w500,
                              ),
                    ),
                    SizedBox(height: Sizer.h(1)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AppText(
                          text: local.alreadyHaveAccount,
                          fontSize: Sizer.sp(3.2),
                        ),
                        SizedBox(width: Sizer.w(1)),
                        GestureDetector(
                          onTap: () {
                            Get.to(
                              () => LoginScreen(),
                              transition: Transition.fadeIn,
                              duration: const Duration(milliseconds: 500),
                            );
                          },
                          child: AppText(
                            text: local.login,
                            color: context.colorsScheme.primary,
                            fontSize: Sizer.sp(3.5),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
