import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:talknep/components/app_appbar.dart';
import 'package:talknep/components/app_spacing.dart';
import 'package:talknep/constant/app_color.dart';
import 'package:talknep/gen/assets.gen.dart';
import 'package:talknep/provider/marketPlace/market_place_provider.dart';
import 'package:talknep/util/theme_extension.dart';
import 'package:talknep/widget/app_button.dart';
import 'package:talknep/widget/app_loader.dart';
import 'package:talknep/widget/app_showPicker.dart';
import 'package:talknep/widget/app_sizer.dart';
import 'package:talknep/widget/app_text.dart';
import 'package:talknep/widget/app_textfield.dart';

class CreateMarketPlaceScreen extends StatelessWidget {
  const CreateMarketPlaceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MarketPlaceProvider>(context);

    return Scaffold(
      appBar: AppAppbar(title: 'Create Market Place'),
      backgroundColor: context.scaffoldBackgroundColor,
      body: AppHorizontalPadding(
        child: SingleChildScrollView(
          child: Form(
            key: provider.marketPlaceForm,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () {
                    showImagePickerBottomSheet(
                      context: context,
                      onImageSelected: (value) async {
                        provider.setSelectedPageImage(value);
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
                                fit: BoxFit.cover,
                                provider.selectedPageImage!,
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
                  validator: (value) {
                    value = value?.trim() ?? '';
                    if (value.isEmpty) return 'Title is required';
                    if (value.length < 3)
                      return 'Title must be at least 3 characters';
                    if (value.length > 100)
                      return 'Title must be less than 100 characters';
                    return null;
                  },
                ),
                SizedBox(height: Sizer.h(2)),
                AppText(text: "Currency"),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: Sizer.w(3)),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: context.colorsScheme.onSecondary.withValues(
                        alpha: 0.2,
                      ),
                    ),
                  ),
                  child: DropdownButton<Map<String, dynamic>>(
                    isExpanded: true,
                    underline: SizedBox(),
                    value: provider.selectedCategoryItem,
                    onChanged: (value) {
                      if (value != null) {
                        print("value $value");
                        provider.setSelectedCurrency(value);
                      }
                    },
                    items:
                        provider.itemsSelectedCurrency
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
                AppText(text: "Price"),
                SizedBox(height: Sizer.h(0.5)),
                CommonTextField2(
                  controller: provider.priceController,
                  text: "Enter your amount",
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    value = value?.trim() ?? '';
                    if (value.isEmpty) return 'Price is required';
                    double? priceValue = double.tryParse(value);
                    if (priceValue == null) return 'Please enter a valid price';
                    if (priceValue <= 0) return 'Price must be greater than 0';
                    if (priceValue > 999999999) return 'Price is too high';
                    return null;
                  },
                ),
                SizedBox(height: Sizer.h(2)),
                AppText(text: "Location"),
                SizedBox(height: Sizer.h(0.5)),
                CommonTextField2(
                  controller: provider.locationController,
                  text: "Enter your location",
                  validator: (value) {
                    value = value?.trim() ?? '';
                    if (value.isEmpty) return 'Location is required';
                    if (value.length < 2)
                      return 'Location must be at least 2 characters';
                    if (value.length > 100)
                      return 'Location must be less than 100 characters';
                    return null;
                  },
                ),
                SizedBox(height: Sizer.h(2)),
                AppText(text: "Condition"),
                SizedBox(height: Sizer.h(0.5)),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: Sizer.w(3)),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: context.colorsScheme.onSecondary.withValues(
                        alpha: 0.2,
                      ),
                    ),
                  ),
                  child: DropdownButton<String>(
                    isExpanded: true,
                    underline: SizedBox(),
                    value: provider.selectedCondition,
                    onChanged: (value) {
                      if (value != null) {
                        provider.setSelectedCondition(value);
                      }
                    },
                    items:
                        provider.itemsSelectedCondition
                            .map(
                              (item) => DropdownMenuItem<String>(
                                value: item,
                                child: AppText(text: item),
                              ),
                            )
                            .toList(),
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
                    border: Border.all(
                      color: context.colorsScheme.onSecondary.withValues(
                        alpha: 0.2,
                      ),
                    ),
                  ),
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: provider.selectedStatus,
                    underline: SizedBox(),
                    onChanged: (value) {
                      if (value != null) {
                        provider.setSelectedStatus(value);
                      }
                    },
                    items:
                        provider.itemsSelectedStatus
                            .map(
                              (item) => DropdownMenuItem<String>(
                                value: item,
                                child: AppText(text: item),
                              ),
                            )
                            .toList(),
                  ),
                ),
                SizedBox(height: Sizer.h(2)),
                AppText(text: "Description"),
                SizedBox(height: Sizer.h(0.5)),
                CommonTextField2(
                  controller: provider.descriptionController,
                  text: "Enter your description",
                  minLines: 5,
                  validator: (value) {
                    value = value?.trim() ?? '';
                    if (value.isEmpty) return 'Description is required';
                    if (value.length < 10)
                      return 'Description must be at least 10 characters';
                    if (value.length > 1000)
                      return 'Description must be less than 1000 characters';
                    return null;
                  },
                ),
                SizedBox(height: Sizer.h(2)),
                provider.isLoading
                    ? CommonLoader()
                    : AppButton(
                      child: AppText(
                        text: "Publish",
                        color: AppColors.whiteColor,
                      ),
                      onPressed: () => provider.createMarketPlace(context),
                    ),

                SizedBox(height: Sizer.h(2)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
