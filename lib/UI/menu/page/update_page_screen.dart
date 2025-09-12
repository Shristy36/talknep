import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:talknep/components/app_appbar.dart';
import 'package:talknep/components/app_spacing.dart';
import 'package:talknep/components/net_image.dart';
import 'package:talknep/constant/app_color.dart';
import 'package:talknep/provider/menu/page/page_provider.dart';
import 'package:talknep/util/theme_extension.dart';
import 'package:talknep/widget/app_button.dart';
import 'package:talknep/widget/app_loader.dart';
import 'package:talknep/widget/app_showPicker.dart';
import 'package:talknep/widget/app_sizer.dart';
import 'package:talknep/widget/app_text.dart';
import 'package:talknep/widget/app_textfield.dart';

class UpdatePageScreen extends StatefulWidget {
  final dynamic updateData;
  const UpdatePageScreen({super.key, this.updateData});

  @override
  State<UpdatePageScreen> createState() => _UpdatePageScreenState();
}

class _UpdatePageScreenState extends State<UpdatePageScreen> {
  @override
  void initState() {
    final pageProvider = Provider.of<PageProvider>(context, listen: false);

    pageProvider.nameController.text = widget.updateData['title'].toString();

    pageProvider.aboutController.text =
        widget.updateData['description'].toString();

    final matchingCategory = pageProvider.itemsSelectedCategoryType.firstWhere(
      (element) =>
          element['category'] == widget.updateData['category'].toString() ||
          element['category_id'].toString() ==
              widget.updateData['category_id'].toString(),
      orElse: () => {},
    );

    if (matchingCategory.isNotEmpty) {
      pageProvider.setSelectedPageType(matchingCategory);
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PageProvider>(context);
    return Scaffold(
      appBar: AppAppbar(title: 'Update Pages'),
      backgroundColor: context.scaffoldBackgroundColor,
      body: AppHorizontalPadding(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: Sizer.h(1)),
              GestureDetector(
                onTap: () {
                  showImagePickerBottomSheet(
                    context: context,
                    onImageSelected: (image) async {
                      provider.setSelectedPageImage(image);
                    },
                  );
                },
                child: SizedBox(
                  height: Sizer.h(30),
                  width: double.infinity,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child:
                        provider.selectedPageImage != null
                            ? Image.file(
                              provider.selectedPageImage!,
                              fit: BoxFit.cover,
                            )
                            : NetImage(
                              imageUrl: widget.updateData['logo'].toString(),
                              fit: BoxFit.cover,
                            ),
                  ),
                ),
              ),
              SizedBox(height: Sizer.h(2)),
              AppText(text: "Page Name"),
              SizedBox(height: Sizer.h(0.5)),
              CommonTextField2(
                text: "Write your page name",
                controller: provider.nameController,
              ),
              SizedBox(height: Sizer.h(2)),
              AppText(text: "Category"),
              SizedBox(height: Sizer.h(0.5)),
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: Sizer.w(3)),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: context.colorsScheme.onSecondary.withValues(
                      alpha: 0.2,
                    ),
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: DropdownButton<Map<String, dynamic>>(
                  isExpanded: true,
                  underline: SizedBox(),
                  onChanged: (value) {
                    if (value != null) {
                      provider.setSelectedPageType(value);
                    }
                  },
                  value: provider.selectedCategoryItem,
                  items:
                      provider.itemsSelectedCategoryType
                          .map<DropdownMenuItem<Map<String, dynamic>>>(
                            (item) => DropdownMenuItem<Map<String, dynamic>>(
                              value: item,
                              child: AppText(text: item['category']),
                            ),
                          )
                          .toList(),
                ),
              ),
              SizedBox(height: Sizer.h(2)),
              AppText(text: "Description"),
              SizedBox(height: Sizer.h(0.5)),
              CommonTextField2(
                text: "Description",
                maxLines: 5,
                controller: provider.aboutController,
              ),
              SizedBox(height: Sizer.h(2)),
              AppButton(
                onPressed: () {
                  provider.updatePage(
                    context,
                    widget.updateData['id'].toString(),
                  );
                },
                child:
                    provider.isLoading
                        ? CommonLoader(size: 3)
                        : AppText(
                          text: "Update Page",
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
