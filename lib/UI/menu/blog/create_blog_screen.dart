import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:talknep/components/app_appbar.dart';
import 'package:talknep/components/app_spacing.dart';
import 'package:talknep/constant/app_color.dart';
import 'package:talknep/gen/assets.gen.dart';
import 'package:talknep/provider/menu/blog/blog_provider.dart';
import 'package:talknep/util/theme_extension.dart';
import 'package:talknep/widget/app_button.dart';
import 'package:talknep/widget/app_loader.dart';
import 'package:talknep/widget/app_showPicker.dart';
import 'package:talknep/widget/app_sizer.dart';
import 'package:talknep/widget/app_text.dart';
import 'package:talknep/widget/app_textfield.dart';

class CreateBlogScreen extends StatelessWidget {
  const CreateBlogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => BlogProvider(),
      child: Scaffold(
        appBar: AppAppbar(title: 'Create Blog'),
        backgroundColor: context.scaffoldBackgroundColor,
        body: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Consumer<BlogProvider>(
            builder: (context, provider, child) {
              return AppHorizontalPadding(
                child: Form(
                  key: provider.formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: Sizer.h(1)),
                      GestureDetector(
                        onTap: () {
                          showImagePickerBottomSheet(
                            context: context,
                            onImageSelected: (image) async {
                              provider.setSelectedBlogImage(image);
                            },
                          );
                        },
                        child: SizedBox(
                          height: Sizer.h(30),
                          width: double.infinity,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child:
                                provider.selectedBlogImage != null
                                    ? Image.file(
                                      fit: BoxFit.cover,
                                      provider.selectedBlogImage!,
                                    )
                                    : Assets.image.png.backgroundImage.image(
                                      fit: BoxFit.cover,
                                    ),
                          ),
                        ),
                      ),
                      SizedBox(height: Sizer.h(2)),
                      AppText(text: "Title"),
                      SizedBox(height: Sizer.h(0.5)),
                      CommonTextField2(
                        text: "Enter your title",
                        controller: provider.titleController,
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return "Title is required";
                          }
                          if (value.trim().length < 3) {
                            return "Title must be at least 3 characters";
                          }
                          return null;
                        },
                      ),

                      SizedBox(height: Sizer.h(2)),
                      AppText(text: "Tags"),
                      SizedBox(height: Sizer.h(0.5)),
                      CommonTextField2(
                        text: "Enter your tags",
                        controller: provider.tagController,
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return "Tags are required";
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
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: context.colorsScheme.onSecondary,
                          ),
                        ),
                        child: DropdownButton<Map<String, dynamic>>(
                          value: provider.selectedCategoryItem,
                          isExpanded: true,
                          items:
                              provider.itemsSelectedBlogType
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
                          underline: SizedBox(),
                          onChanged: (value) {
                            if (value != null) {
                              print("value $value");
                              provider.setSelectedBlogType(value);
                            }
                          },
                        ),
                      ),
                      SizedBox(height: Sizer.h(2)),
                      AppText(text: "Description"),
                      SizedBox(height: Sizer.h(0.5)),
                      CommonTextField2(
                        maxLines: 4,
                        text: "Description",
                        textInputAction: TextInputAction.newline,
                        controller: provider.descriptionController,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return "Description is required";
                          }
                          if (value.trim().length < 10) {
                            return "Description must be at least 10 characters";
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: Sizer.h(1)),
                      provider.isLoading != true
                          ? AppButton(
                            onPressed: () {
                              provider.createBlog(context);
                            },
                            child: AppText(
                              text: "Create Blog",
                              color: AppColors.whiteColor,
                            ),
                          )
                          : CommonLoader(),
                      SizedBox(height: Sizer.h(2)),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
