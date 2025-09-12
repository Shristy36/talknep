import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:talknep/components/app_appbar.dart';
import 'package:talknep/components/app_spacing.dart';
import 'package:talknep/constant/app_color.dart';
import 'package:talknep/gen/assets.gen.dart';
import 'package:talknep/provider/menu/group/group_provider.dart';
import 'package:talknep/util/theme_extension.dart';
import 'package:talknep/widget/app_button.dart';
import 'package:talknep/widget/app_loader.dart';
import 'package:talknep/widget/app_showPicker.dart';
import 'package:talknep/widget/app_sizer.dart';
import 'package:talknep/widget/app_text.dart';
import 'package:talknep/widget/app_textfield.dart';

class CreateGroupScreen extends StatelessWidget {
  const CreateGroupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<GroupProvider>(context);
    return Scaffold(
      backgroundColor: context.scaffoldBackgroundColor,
      appBar: AppAppbar(title: "Create Group"),
        body: AppHorizontalPadding(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () {
                  showImagePickerBottomSheet(
                    context: context,
                    onImageSelected: (File image) async {
                      provider.setSelectedGroupImage(image);
                    },
                  );
                },
                child: SizedBox(
                  height: Sizer.h(30),
                  width: double.infinity,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child:
                        provider.selectedGroupImage != null
                            ? Image.file(
                              fit: BoxFit.cover,
                              provider.selectedGroupImage!,
                            )
                            : Assets.image.png.backgroundImage.image(
                              fit: BoxFit.cover,
                            ),
                  ),
                ),
              ),
              SizedBox(height: Sizer.h(2)),
              AppText(text: "Name"),
              SizedBox(height: Sizer.h(0.5)),
              CommonTextField2(
                controller: provider.nameController,
                text: "Write group name",
              ),
              SizedBox(height: Sizer.h(2)),
              AppText(text: "Subtitle"),
              SizedBox(height: Sizer.h(0.5)),
              CommonTextField2(
                controller: provider.subtitleController,
                text: "Write group subtitle",
              ),
              SizedBox(height: Sizer.h(2)),
              AppText(text: "Privacy"),
              SizedBox(height: Sizer.h(0.5)),
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: Sizer.w(3)),
                decoration: BoxDecoration(
                  color: context.scaffoldBackgroundColor,
                  border: Border.all(color: context.colorsScheme.onSecondary),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: DropdownButton<String>(
                  value: provider.selectedPrivacy,
                  isExpanded: true,
                  items:
                      provider.itemsSelectedPrivacy
                          .map(
                            (item) => DropdownMenuItem<String>(
                              value: item,
                              child: AppText(text: item),
                            ),
                          )
                          .toList(),
                  underline: SizedBox(),
                  onChanged: (value) {
                    if (value != null) {
                      provider.setSelectedPrivacy(value);
                    }
                  },
                ),
              ),
              SizedBox(height: Sizer.h(2)),
              AppText(text: "Status"),
              SizedBox(height: Sizer.h(0.5)),
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: Sizer.w(3)),
                decoration: BoxDecoration(
                  color: context.scaffoldBackgroundColor,
                  border: Border.all(color: context.colorsScheme.onSecondary),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: DropdownButton<String>(
                  value: provider.selectedStatus,
                  isExpanded: true,
                  items:
                      provider.itemsSelectedStatus
                          .map(
                            (item) => DropdownMenuItem<String>(
                              value: item,
                              child: AppText(text: item),
                            ),
                          )
                          .toList(),
                  underline: SizedBox(),
                  onChanged: (value) {
                    if (value != null) {
                      provider.setSelectedStatus(value);
                    }
                  },
                ),
              ),
              SizedBox(height: Sizer.h(2)),
              AppText(text: "About"),
              SizedBox(height: Sizer.h(0.5)),
              CommonTextField2(
                maxLines: 5,
                text: "About group",
                controller: provider.aboutController,
                textInputAction: TextInputAction.newline,
              ),
              SizedBox(height: Sizer.h(2)),
              AppButton(
                onPressed: () {
                  provider.createGroup(context);
                },
                child:
                    provider.isLoading
                        ? CommonLoader(size: 3, color: AppColors.whiteColor)
                        : AppText(
                          text: "Create Group",
                          color: AppColors.whiteColor,
                        ),
              ),
              SizedBox(height: Sizer.h(2)),
            ],
          ),
        ),
      ),
    );
  }
}
