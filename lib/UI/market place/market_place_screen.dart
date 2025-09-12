import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:talknep/components/app_spacing.dart';
import 'package:talknep/components/net_image.dart';
import 'package:talknep/constant/app_color.dart';
import 'package:talknep/provider/marketPlace/market_place_provider.dart';
import 'package:talknep/util/theme_extension.dart';
import 'package:talknep/widget/app_button.dart';
import 'package:talknep/widget/app_loader.dart';
import 'package:talknep/widget/app_sizer.dart';
import 'package:talknep/widget/app_text.dart';
import 'package:talknep/widget/app_textfield.dart';
import 'market_place_details_screen.dart';

class MarketPlaceScreen extends StatelessWidget {
  const MarketPlaceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MarketPlaceProvider>(context);

    return Scaffold(
      backgroundColor: context.scaffoldBackgroundColor,
      body: AppHorizontalPadding(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: Sizer.h(1)),
            SizedBox(
              width: Get.width,
              height: Sizer.h(5.5),
              child: CupertinoSearchTextField(
                placeholder: "Search your products",
                controller: provider.searchController,
                placeholderStyle: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: context.colorsScheme.onSurface,
                  fontFamily: GoogleFonts.poppins().fontFamily,
                ),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: context.colorsScheme.onSurface,
                  fontFamily: GoogleFonts.poppins().fontFamily,
                ),
                borderRadius: BorderRadius.circular(12),
                prefixInsets: EdgeInsets.only(left: 15.0),
                suffixInsets: EdgeInsets.only(right: 10.0),
                prefixIcon: Icon(
                  CupertinoIcons.search,
                  color: context.colorsScheme.onSurface,
                ),
                onChanged: (_) => provider.notifyListeners(),
                onSubmitted: (_) => FocusScope.of(context).unfocus(),
              ),
            ),
            SizedBox(height: Sizer.h(1)),
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: Sizer.w(3)),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: context.scaffoldBackgroundColor,
                border: Border.all(color: context.colorsScheme.onSecondary),
              ),
              child: DropdownButton<String>(
                value: provider.selectedCondition,
                isExpanded: true,
                items:
                    provider.itemsSelectedCondition
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
                    provider.setSelectedCondition(value);
                  }
                },
              ),
            ),
            SizedBox(height: Sizer.h(1)),
            Row(
              children: [
                Expanded(
                  child: CommonTextField2(
                    text: "Min",
                    keyboardType: TextInputType.number,
                    controller: provider.minController,
                    onChanged: (_) => provider.notifyListeners(),
                  ),
                ),
                SizedBox(width: Sizer.w(2)),
                Expanded(
                  child: CommonTextField2(
                    text: "Max",
                    controller: provider.maxController,
                    keyboardType: TextInputType.number,
                    onChanged: (_) => provider.notifyListeners(),
                  ),
                ),
              ],
            ),
            SizedBox(height: Sizer.h(1)),
            Expanded(
              child:
                  provider.isLoading
                      ? Center(child: CommonLoader())
                      : RefreshIndicator.adaptive(
                        onRefresh: () => provider.getMarketPlace(),
                        child: GridView.builder(
                          padding: const EdgeInsets.all(8),
                          itemCount: provider.filteredMarketPlaceList.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                mainAxisSpacing: 10,
                                crossAxisSpacing: 10,
                                childAspectRatio: 2.78 / 4,
                              ),
                          itemBuilder: (context, index) {
                            return customCard(
                              provider.filteredMarketPlaceList[index],
                              context,
                            );
                          },
                        ),
                      ),
            ),
          ],
        ),
      ),
    );
  }

  Widget customCard(dynamic marketData, BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.to(MarketPlaceDetailsScreen(marketPlaceDetailsData: marketData));
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: Sizer.w(2),
          vertical: Sizer.h(0.5),
        ),
        decoration: BoxDecoration(
          color: context.scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: context.colorsScheme.onSecondary),
          boxShadow: [
            BoxShadow(
              blurRadius: 4,
              spreadRadius: 1,
              offset: Offset(0, 2),
              color: context.colorsScheme.shadow,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: Sizer.h(0.5)),
            SizedBox(
              height: Sizer.h(15),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: NetImage(
                  fit: BoxFit.cover,
                  imageUrl: marketData['coverphoto'] ?? '',
                ),
              ),
            ),
            SizedBox(height: Sizer.h(0.5)),
            AppText(
              maxLines: 1,
              fontSize: Sizer.sp(3.5),
              text: marketData['title'],
              fontWeight: FontWeight.w500,
            ),
            AppText(
              maxLines: 2,
              fontSize: Sizer.sp(3.5),
              text: marketData['status_id'],
              color: context.colorsScheme.primary,
            ),
            SizedBox(height: Sizer.h(0.5)),
            AppButton(
              height: Sizer.h(5),
              onPressed: () {},
              child: AppText(
                color: AppColors.whiteColor,
                text: "\$ ${marketData['price']}",
              ),
            ),
          ],
        ),
      ),
    );
  }
}
