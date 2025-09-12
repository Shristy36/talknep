import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:talknep/components/app_appbar.dart';
import 'package:talknep/components/app_spacing.dart';
import 'package:talknep/components/net_image.dart';
import 'package:talknep/constant/app_color.dart';
import 'package:talknep/provider/menu/group/group_provider.dart';
import 'package:talknep/util/theme_extension.dart';
import 'package:talknep/widget/app_button.dart';
import 'package:talknep/widget/app_loader.dart';
import 'package:talknep/widget/app_showPicker.dart';
import 'package:talknep/widget/app_sizer.dart';
import 'package:talknep/widget/app_text.dart';
import 'package:talknep/widget/app_textfield.dart';

class UpdateGroupScreen extends StatefulWidget {
  const UpdateGroupScreen({super.key});

  @override
  State<UpdateGroupScreen> createState() => _UpdateGroupScreenState();
}

class _UpdateGroupScreenState extends State<UpdateGroupScreen> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<GroupProvider>(context, listen: false).getGroupDetails();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<GroupProvider>(context);
    return Scaffold(
      appBar: AppAppbar(title: 'Update Group'),
      backgroundColor: context.scaffoldBackgroundColor,
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
                              provider.selectedGroupImage!,
                              fit: BoxFit.cover,
                              height: 150,
                              width: 150,
                            )
                            : provider.coverImageUrl != null
                            ? NetImage(
                              height: 150,
                              width: 150,
                              fit: BoxFit.cover,
                              imageUrl: provider.coverImageUrl!,
                            )
                            : Container(
                              height: 150,
                              width: 150,
                              color: AppColors.borderColor,
                              child: Icon(
                                Icons.image,
                                color: AppColors.blackColor.withAlpha(100),
                              ),
                            ),
                  ),
                ),
              ),
              SizedBox(height: Sizer.h(2)),
              AppText(text: "Name"),
              SizedBox(height: Sizer.h(0.5)),
              CommonTextField2(
                controller: provider.nameController,
                textInputAction: TextInputAction.next,
                text: "Write group name",
              ),
              SizedBox(height: Sizer.h(2)),
              AppText(text: "Subtitle"),
              SizedBox(height: Sizer.h(0.5)),
              CommonTextField2(
                text: "Write group subtitle",
                textInputAction: TextInputAction.next,
                controller: provider.subtitleController,
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
                  value:
                      provider.itemsSelectedPrivacy.contains(
                            provider.selectedPrivacy,
                          )
                          ? provider.selectedPrivacy
                          : provider.itemsSelectedPrivacy.first,
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
                  borderRadius: BorderRadius.circular(10),
                  color: context.scaffoldBackgroundColor,
                  border: Border.all(color: context.colorsScheme.onSecondary),
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
                controller: provider.aboutController,
                text: "About group",
                maxLines: 5,
              ),
              SizedBox(height: Sizer.h(2)),
              AppButton(
                onPressed: () {
                  provider.updateGroup(context);
                },
                child:
                    provider.isLoading
                        ? CommonLoader(size: 3, color: AppColors.whiteColor)
                        : AppText(
                          text: "Update Group",
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
