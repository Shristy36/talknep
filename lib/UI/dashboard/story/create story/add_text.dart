import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:talknep/components/app_appbar.dart';
import 'package:talknep/constant/app_color.dart';
import 'package:talknep/provider/dashboard/add_text_provider.dart';
import 'package:talknep/util/theme_extension.dart';
import 'package:talknep/widget/app_button.dart';
import 'package:talknep/widget/app_loader.dart';
import 'package:talknep/widget/app_sizer.dart';
import 'package:talknep/widget/app_text.dart';

class AddStoryText extends StatelessWidget {
  const AddStoryText({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TextStoryProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          appBar: AppAppbar(title: "Add Text"),
          backgroundColor: context.scaffoldBackgroundColor,
          body: Column(
            children: [
              Expanded(
                child: Container(
                  width: Get.width,
                  decoration: BoxDecoration(
                    color: Color(int.parse("0xFF${provider.bgColor}")),
                  ),
                  padding: const EdgeInsets.all(20.0),
                  child: TextFormField(
                    controller: provider.descriptionController,
                    decoration: InputDecoration(
                      hintText: "What's on your mind ?",
                      hintStyle: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 24,
                        color:
                            provider.textColor != "636363"
                                ? Colors.white
                                : AppColors.primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                      border: InputBorder.none,
                    ),
                    maxLines: null,
                    style: TextStyle(
                      fontSize: 24,
                      color:
                          provider.textColor != "636363"
                              ? Colors.white
                              : Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                    cursorColor:
                        provider.textColor != "636363"
                            ? Colors.white
                            : Colors.black,
                    cursorRadius: const Radius.circular(100),
                    cursorWidth: 4,
                    cursorHeight: 34,
                  ),
                ),
              ),
            ],
          ),
          bottomSheet: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildColorPicker(provider),
                SizedBox(height: 10),
                buildPrivacyAndShareRow(context, provider),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget buildColorPicker(TextStoryProvider provider) {
    final colors = [
      {"bg": "fafafa", "text": "636363"},
      {"bg": "5A2FF9", "text": "fff"},
      {"bg": "f00000", "text": "fff"},
      {"bg": "ff7856", "text": "fff"},
      {"bg": "f92fd7", "text": "fff"},
      {"bg": "2f94f9", "text": "fff"},
      {"bg": "000000", "text": "fff"},
    ];

    return Row(
      children:
          colors.map((c) {
            return GestureDetector(
              onTap: () => provider.setColors(bg: c['bg']!, text: c['text']!),
              child: Container(
                height: 32,
                width: 32,
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(int.parse("0xFF${c['bg']}")),
                  border: Border.all(color: Colors.black),
                ),
              ),
            );
          }).toList(),
    );
  }

  Widget buildPrivacyAndShareRow(
    BuildContext context,
    TextStoryProvider provider,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(child: buildPrivacyDropdown(context, provider)),
        SizedBox(width: Sizer.w(3)),
        Expanded(
          child: AppButton(
            onPressed: () async {
              await provider.addStory(context);
            },
            child:
                provider.isLoading
                    ? CommonLoader(color: AppColors.whiteColor)
                    : AppText(text: "Share", color: AppColors.whiteColor),
          ),
        ),
      ],
    );
  }

  Widget buildPrivacyDropdown(
    BuildContext context,
    TextStoryProvider provider,
  ) {
    return Container(
      height: Sizer.h(5.5),
      decoration: BoxDecoration(
        color: context.scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Center(
        child: DropdownButton<Map<String, dynamic>>(
          value: provider.privacyOptions.firstWhere(
            (item) => item["label"] == provider.privacy,
          ),
          onChanged: (newVal) {
            provider.setPrivacy(newVal!["label"]);
          },
          items:
              provider.privacyOptions.map((item) {
                return DropdownMenuItem<Map<String, dynamic>>(
                  value: item,
                  child: Row(
                    children: [
                      Icon(
                        size: 16,
                        item["icon"],
                        color: context.colorsScheme.error,
                      ),
                      const SizedBox(width: 10),
                      AppText(text: item["label"]),
                    ],
                  ),
                );
              }).toList(),
          underline: SizedBox(),
          icon: Icon(
            size: 20,
            Icons.keyboard_arrow_down,
            color: context.colorsScheme.secondary,
          ),
        ),
      ),
    );
  }
}
