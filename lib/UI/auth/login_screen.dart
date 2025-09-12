import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:talknep/components/app_spacing.dart';
import 'package:talknep/constant/app_color.dart';
import 'package:talknep/gen/assets.gen.dart';
import 'package:talknep/l10n/app_localizations.dart';
import 'package:talknep/provider/auth/login_provider.dart';
import 'package:talknep/util/check_connectively.dart';
import 'package:talknep/util/theme_extension.dart';
import 'package:talknep/UI/auth/forgot_screen.dart';
import 'package:talknep/UI/auth/register_screen.dart';
import 'package:talknep/widget/app_button.dart';
import 'package:talknep/widget/app_loader.dart';
import 'package:talknep/widget/app_sizer.dart';
import 'package:talknep/widget/app_text.dart';
import 'package:talknep/widget/app_textfield.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  final formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: context.scaffoldBackgroundColor,
      body: AppHorizontalPadding(
        child: Consumer<LoginProvider>(
          builder: (context, provider, child) {
            return SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: Form(
                key: formKey,
                child: Column(
                  children: [
                    SizedBox(height: Sizer.h(10)),
                    Transform.scale(
                      scale: 0.8,
                      child: Assets.image.png.appIcon.image(),
                    ),
                    SizedBox(height: Sizer.h(8)),
                    CommonTextField(
                      labelText: local.email,
                      prefixIcon: Icons.email,
                      hintText: 'example@email.com',
                      controller: provider.emailController,
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    SizedBox(height: Sizer.h(2)),
                    CommonTextField(
                      isPassword: true,
                      hintText: '********',
                      prefixIcon: Icons.lock,
                      labelText: local.password,
                      textInputAction: TextInputAction.done,
                      controller: provider.passwordController,
                    ),
                    Row(
                      children: [
                        Transform.translate(
                          offset: const Offset(-10, 0),
                          child: Checkbox.adaptive(
                            value: provider.rememberMe,
                            activeColor: context.colorsScheme.primary,
                            onChanged: (val) => provider.toggleRememberMe(),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                            side: BorderSide(
                              width: 1.5,
                              color:
                                  provider.rememberMe
                                      ? context.colorsScheme.primary
                                      : context
                                          .colorsScheme
                                          .onSecondaryContainer,
                            ),
                          ),
                        ),
                        Transform.translate(
                          child: AppText(
                            fontSize: Sizer.sp(3),
                            text: local.rememberMe,
                          ),
                          offset: const Offset(-14, 0),
                        ),
                        Spacer(),
                        GestureDetector(
                          onTap: () {
                            Get.to(
                              () => ForgotScreen(),
                              transition: Transition.fadeIn,
                              duration: const Duration(milliseconds: 500),
                            );
                          },
                          child: AppText(
                            fontSize: Sizer.sp(3.5),
                            text: local.forgotPassword,
                            fontWeight: FontWeight.w500,
                            color: context.colorsScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: Sizer.h(2)),
                    AppButton(
                      onPressed:
                          () => checkInternetConnection(
                            onConnected: () => provider.loginAPI(context),
                          ),
                      backgroundColor: AppColors.primaryColor,
                      child:
                          provider.isLoading
                              ? CommonLoader(
                                size: 3,
                                color: AppColors.whiteColor,
                              )
                              : AppText(
                                text: local.login,
                                color: AppColors.whiteColor,
                                fontWeight: FontWeight.w500,
                              ),
                    ),
                    SizedBox(height: Sizer.h(1.5)),
                    GestureDetector(
                      onTap:
                          () => checkInternetConnection(
                            onConnected:
                                () => provider.signInWithGoogle(context),
                          ),

                      child: Container(
                        height: Sizer.h(6),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: context.scaffoldBackgroundColor,
                          border: Border.all(
                            width: 1,
                            color: context.colorsScheme.primary,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child:
                            provider.isGoogleLoading
                                ? CommonLoader(
                                  size: 3,
                                  color: context.colorsScheme.primary,
                                )
                                : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Assets.icon.googleIcon.svg(),
                                    SizedBox(width: Sizer.w(2)),
                                    AppText(
                                      fontWeight: FontWeight.w500,
                                      text: local.continueWithGoogle,
                                      color: context.colorsScheme.primary,
                                    ),
                                  ],
                                ),
                      ),
                    ),
                    SizedBox(height: Sizer.h(1)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AppText(
                          fontSize: Sizer.sp(3.2),
                          text: local.donHaveAccount,
                        ),
                        SizedBox(width: Sizer.w(1)),
                        GestureDetector(
                          onTap: () {
                            Get.to(
                              () => RegisterScreen(),
                              transition: Transition.fadeIn,
                              duration: const Duration(milliseconds: 500),
                            );
                          },
                          child: AppText(
                            text: local.signUp,
                            fontSize: Sizer.sp(3.5),
                            fontWeight: FontWeight.w500,
                            color: context.colorsScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
