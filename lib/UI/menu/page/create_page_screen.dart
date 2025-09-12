import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:talknep/components/app_appbar.dart';
import 'package:talknep/components/app_spacing.dart';
import 'package:talknep/constant/app_color.dart';
import 'package:talknep/gen/assets.gen.dart';
import 'package:talknep/provider/menu/page/page_provider.dart';
import 'package:talknep/util/theme_extension.dart';
import 'package:talknep/widget/app_button.dart';
import 'package:talknep/widget/app_loader.dart';
import 'package:talknep/widget/app_showPicker.dart';
import 'package:talknep/widget/app_sizer.dart';
import 'package:talknep/widget/app_text.dart';
import 'package:talknep/widget/app_textfield.dart';

class CreatePageScreen extends StatelessWidget {
  const CreatePageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppAppbar(title: 'Create Pages'),
      backgroundColor: context.scaffoldBackgroundColor,
      body: ChangeNotifierProvider(
        create: (context) => PageProvider(),
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: AppHorizontalPadding(
            child: Consumer<PageProvider>(
              builder: (context, provider, child) {
                return Form(
                  key: provider.formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: Sizer.h(1)),

                      Container(
                        height: Sizer.h(30),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: context.colorsScheme.surface,
                          border: Border.all(
                            color: context.colorsScheme.onSecondary,
                          ),
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 4,
                              spreadRadius: 1,
                              offset: Offset(0, 2),
                              color: context.colorsScheme.shadow,
                            ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            GestureDetector(
                              onTap: () {
                                showImagePickerBottomSheet(
                                  context: context,
                                  onImageSelected: (image) {
                                    provider.selectedUserCoverImage = image;
                                    provider.setSelectedPageCoverImage(image);
                                  },
                                );
                              },
                              child: Container(
                                height: Sizer.h(20),
                                width: double.infinity,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(15),
                                    topRight: Radius.circular(15),
                                  ),
                                  child:
                                      provider.selectedUserCoverImage != null
                                          ? Image.file(
                                            fit: BoxFit.cover,
                                            provider.selectedUserCoverImage!,
                                          )
                                          : Assets.image.png.backgroundImage
                                              .image(fit: BoxFit.cover),
                                ),
                              ),
                            ),
                            Positioned(
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Padding(
                                  padding: EdgeInsets.only(
                                    left: 16,
                                    bottom: Sizer.h(2.5),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          showImagePickerBottomSheet(
                                            context: context,
                                            onImageSelected: (image) {
                                              provider.selectedPageImage =
                                                  image;
                                              provider.setSelectedPageImage(
                                                image,
                                              );
                                            },
                                          );
                                        },
                                        child: Container(
                                          height: 90,
                                          width: 90,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color:
                                                  context.colorsScheme.surface,
                                            ),
                                            image: DecorationImage(
                                              fit: BoxFit.cover,
                                              image:
                                                  provider.selectedPageImage !=
                                                          null
                                                      ? FileImage(
                                                        provider
                                                            .selectedPageImage!,
                                                      )
                                                      : AssetImage(
                                                        Assets
                                                            .image
                                                            .png
                                                            .backgroundImage
                                                            .path,
                                                      ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: Sizer.h(2)),
                      AppText(text: "Page Name"),
                      SizedBox(height: Sizer.h(0.5)),
                      CommonTextField2(
                        text: "Write your page name",
                        controller: provider.nameController,
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return "Page name is required";
                          } else if (value.trim().length < 3) {
                            return "Page name must be at least 3 characters";
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: Sizer.h(2)),
                      AppText(text: "Category"),
                      SizedBox(height: Sizer.h(0.5)),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(horizontal: Sizer.w(3)),
                        decoration: BoxDecoration(
                          color: context.scaffoldBackgroundColor,
                          border: Border.all(
                            color: context.colorsScheme.onSecondary,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: DropdownButton<Map<String, dynamic>>(
                          isExpanded: true,
                          underline: SizedBox(),
                          value: provider.selectedCategoryItem,
                          onChanged: (value) {
                            if (value != null) {
                              print("value $value");
                              provider.setSelectedPageType(value);
                            }
                          },
                          items:
                              provider.itemsSelectedCategoryType
                                  .map<DropdownMenuItem<Map<String, dynamic>>>(
                                    (item) =>
                                        DropdownMenuItem<Map<String, dynamic>>(
                                          value: item,
                                          child: AppText(
                                            text: item['category'],
                                          ),
                                        ),
                                  )
                                  .toList(),
                        ),
                      ),
                      SizedBox(height: Sizer.h(2)),
                      AppText(text: "Description"),
                      SizedBox(height: Sizer.h(0.5)),
                      CommonTextField2(
                        maxLines: 4,
                        text: "Description",
                        controller: provider.aboutController,
                        textInputAction: TextInputAction.newline,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return "Description is required";
                          } else if (value.trim().length < 10) {
                            return "Description must be at least 10 characters";
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: Sizer.h(2)),
                      AppButton(
                        onPressed: () {
                          provider.createPage(context);
                        },
                        child:
                            provider.isCreatePage
                                ? CommonLoader(size: 3)
                                : AppText(
                                  text: "Create Page",
                                  color: AppColors.whiteColor,
                                ),
                      ),
                      SizedBox(height: Sizer.h(2)),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
