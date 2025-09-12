import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:talknep/constant/app_color.dart';
import 'package:talknep/provider/dashboard/dashboard_provider.dart';
import 'package:talknep/util/theme_extension.dart';
import 'package:talknep/widget/app_loader.dart';
import 'package:talknep/widget/app_sizer.dart';
import 'package:talknep/widget/app_text.dart';

class RashiScreen extends StatelessWidget {
  const RashiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DashboardProvider>(context);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Sizer.w(3),
        vertical: Sizer.h(1),
      ),
      margin: EdgeInsets.symmetric(
        vertical: Sizer.h(1),
        horizontal: Sizer.w(2),
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: context.colorsScheme.surface,
        border: Border.all(color: context.colorsScheme.onSecondary),
        boxShadow: [
          BoxShadow(
            spreadRadius: 1,
            blurRadius: 4,
            offset: Offset(0, 2),
            color: context.colorsScheme.shadow,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: Sizer.h(5),
                width: Sizer.w(11),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: context.colorsScheme.primary.withAlpha(100),
                ),
                child: Icon(Icons.calendar_month),
              ),
              SizedBox(width: Sizer.w(2)),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    text: provider.formattedDate,
                    fontSize: Sizer.sp(3.3),
                  ),
                  AppText(text: provider.dayName, fontSize: Sizer.sp(3)),
                ],
              ),
              SizedBox(width: Sizer.w(2)),
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: Sizer.w(3)),
                  decoration: BoxDecoration(
                    color: context.colorsScheme.surface,
                    border: Border.all(color: context.colorsScheme.onSecondary),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: DropdownButton<String>(
                    borderRadius: BorderRadius.circular(10),
                    value: provider.selectedZodiac,
                    hint: AppText(text: "Select zodiac"),
                    isExpanded: true,
                    underline: SizedBox(),
                    items:
                        provider.allRashis.map((rashi) {
                          return DropdownMenuItem<String>(
                            value: rashi['en'],
                            child: AppText(text: rashi['name']!),
                          );
                        }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        provider.updateSelectedZodiac(value);
                      }
                    },
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: Sizer.h(2)),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(Sizer.w(3)),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: context.colorsScheme.onSecondary),
            ),
            child:
                provider.isZodiacLoading
                    ? Center(child: CommonLoader())
                    : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (provider.selectedZodiac != null) ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              AppText(
                                text:
                                    "🔮 ${provider.rashis.firstWhere((e) => e['en'] == provider.selectedZodiac)['name']}",
                                fontSize: Sizer.sp(3.5),
                                fontWeight: FontWeight.bold,
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  vertical: Sizer.h(0.5),
                                  horizontal: Sizer.w(2),
                                ),
                                decoration: BoxDecoration(
                                  color: context.colorsScheme.primary,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: AppText(
                                  text: "Zodiac",
                                  color: AppColors.whiteColor,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: Sizer.h(1)),
                          AppText(text: provider.Zodiac, fontSize: Sizer.sp(3)),
                        ] else
                          AppText(
                            text: "Please select a zodiac sign",
                            fontSize: Sizer.sp(3),
                          ),
                      ],
                    ),
          ),
        ],
      ),
    );
  }
}
