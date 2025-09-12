import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:talknep/components/app_appbar.dart';
import 'package:talknep/components/app_spacing.dart';
import 'package:talknep/constant/app_color.dart';
import 'package:talknep/gen/assets.gen.dart';
import 'package:talknep/l10n/app_localizations.dart';
import 'package:talknep/provider/auth/forgot_provider.dart';
import 'package:talknep/util/theme_extension.dart';
import 'package:talknep/widget/app_button.dart';
import 'package:talknep/widget/app_loader.dart';
import 'package:talknep/widget/app_sizer.dart';
import 'package:talknep/widget/app_text.dart';
import 'package:talknep/widget/app_textfield.dart';

class ForgotScreen extends StatelessWidget {
  ForgotScreen({super.key});

  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppAppbar(title: local.forgotPassword2),
      backgroundColor: context.scaffoldBackgroundColor,
      body: Consumer<ForgotProvider>(
        builder: (context, provider, child) {
          return AppHorizontalPadding(
            child: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  children: [
                    SizedBox(height: Sizer.h(3.4)),
                    Transform.scale(
                      scale: 0.8,
                      child: Assets.image.png.appIcon.image(),
                    ),
                    SizedBox(height: Sizer.h(6)),
                    AppText(
                      text: local.forgotYourPassword,
                      fontWeight: FontWeight.w500,
                      fontSize: Sizer.sp(4.5),
                    ),
                    SizedBox(height: Sizer.h(1)),
                    AppText(
                      text: local.forgotPasswordDesc,
                      textAlign: TextAlign.center,
                      fontSize: Sizer.sp(3.2),
                    ),
                    SizedBox(height: Sizer.h(3)),
                    CommonTextField(
                      controller: provider.emailController,
                      labelText: local.email,
                      hintText: 'example@email.com',
                      prefixIcon: Icons.email,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                    ),
                    SizedBox(height: Sizer.h(3)),

                    AppButton(
                      onPressed: () {
                        provider.forgotAPI(context);
                      },
                      backgroundColor: context.colorsScheme.primary,
                      child:
                          provider.isLoading
                              ? CommonLoader(
                                size: 3,
                                color: AppColors.whiteColor,
                              )
                              : AppText(
                                text: local.sendResetLink,
                                color: AppColors.whiteColor,
                                fontWeight: FontWeight.w500,
                              ),
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
