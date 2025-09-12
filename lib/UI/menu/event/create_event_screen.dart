import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:talknep/components/app_appbar.dart';
import 'package:talknep/components/app_spacing.dart';
import 'package:talknep/constant/app_color.dart';
import 'package:talknep/gen/assets.gen.dart';
import 'package:talknep/provider/menu/event/event_provider.dart';
import 'package:talknep/util/theme_extension.dart';
import 'package:talknep/widget/app_button.dart';
import 'package:talknep/widget/app_loader.dart';
import 'package:talknep/widget/app_showPicker.dart';
import 'package:talknep/widget/app_sizer.dart';
import 'package:talknep/widget/app_text.dart';
import 'package:talknep/widget/app_textfield.dart';

class CreateEventScreen extends StatelessWidget {
  const CreateEventScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: EventProvider(),
      child: Scaffold(
        appBar: AppAppbar(title: "Create Events"),
        backgroundColor: context.scaffoldBackgroundColor,
        body: AppHorizontalPadding(
          child: SingleChildScrollView(
            child: Consumer<EventProvider>(
              builder: (context, value, child) {
                return Form(
                  key: value.formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: Sizer.h(1)),
                      GestureDetector(
                        onTap: () {
                          showImagePickerBottomSheet(
                            context: context,
                            onImageSelected: (File image) async {
                              value.setSelectedGroupImage(image);
                            },
                          );
                        },
                        child: SizedBox(
                          height: Sizer.h(30),
                          width: double.infinity,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child:
                                value.selectedGroupImage != null
                                    ? Image.file(
                                      fit: BoxFit.cover,
                                      value.selectedGroupImage!,
                                    )
                                    : Assets.image.png.backgroundImage.image(
                                      fit: BoxFit.cover,
                                    ),
                          ),
                        ),
                      ),
                      SizedBox(height: Sizer.h(2)),
                      AppText(text: "Event name"),
                      SizedBox(height: Sizer.h(0.5)),
                      CommonTextField2(
                        text: "Enter your event name",
                        textInputAction: TextInputAction.next,
                        controller: value.eventNameController,
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return "Event name is required";
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: Sizer.h(2)),
                      Row(
                        children: [
                          Expanded(child: AppText(text: "Event Date")),
                          SizedBox(width: Sizer.w(2)),
                          Expanded(child: AppText(text: "Event Time")),
                        ],
                      ),
                      SizedBox(height: Sizer.h(0.5)),
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () async {
                                final pickedDate = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime(2101),
                                );
                                if (pickedDate != null) {
                                  value.eventDateController.text =
                                      "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
                                }
                              },
                              child: AbsorbPointer(
                                child: CommonTextField2(
                                  text: "Date",
                                  controller: value.eventDateController,
                                  validator: (val) {
                                    if (val == null || val.trim().isEmpty) {
                                      return "Event date is required";
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: Sizer.w(2)),
                          Expanded(
                            child: GestureDetector(
                              onTap: () async {
                                final pickedTime = await showTimePicker(
                                  context: context,
                                  initialTime: TimeOfDay.now(),
                                );
                                if (pickedTime != null && context.mounted) {
                                  value.eventTimeController.text = pickedTime
                                      .format(context);
                                }
                              },
                              child: AbsorbPointer(
                                child: CommonTextField2(
                                  text: "Time",
                                  controller: value.eventTimeController,
                                  validator: (val) {
                                    if (val == null || val.trim().isEmpty) {
                                      return "Event time is required";
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: Sizer.h(2)),
                      AppText(text: "Location"),
                      SizedBox(height: Sizer.h(0.5)),
                      CommonTextField2(
                        text: "Enter your location",
                        controller: value.locationController,
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return "Location is required";
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: Sizer.h(2)),
                      AppText(text: "Privacy"),
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
                        child: DropdownButton<String>(
                          isExpanded: true,
                          underline: SizedBox(),
                          value: value.selectedPrivacy,
                          onChanged: (values) {
                            if (values != null) {
                              value.setSelectedPrivacy(values);
                            }
                          },
                          items:
                              value.itemsSelectedPrivacy
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
                        minLines: 5,
                        text: "Enter your description",
                        controller: value.descController,
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return "Description is required";
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: Sizer.h(2)),
                      AppButton(
                        onPressed: () {
                          value.createEvent(context);
                        },
                        child:
                            value.isLoading
                                ? CommonLoader(color: AppColors.whiteColor)
                                : AppText(
                                  text: "Create Events",
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
