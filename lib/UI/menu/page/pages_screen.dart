import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:talknep/UI/menu/page/create_page_screen.dart';
import 'package:talknep/UI/menu/page/details_page_screen.dart';
import 'package:talknep/components/app_spacing.dart';
import 'package:talknep/components/net_image.dart';
import 'package:talknep/constant/app_color.dart';
import 'package:talknep/provider/menu/page/page_provider.dart';
import 'package:talknep/util/theme_extension.dart';
import 'package:talknep/widget/app_button.dart';
import 'package:talknep/widget/app_loader.dart';
import 'package:talknep/widget/app_sizer.dart';
import 'package:talknep/widget/app_text.dart';

class PagesScreen extends StatelessWidget {
  const PagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final pageProvider = Provider.of<PageProvider>(context);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          titleSpacing: 0,
          title: AppText(text: 'Pages'),
          leading: IconButton(
            iconSize: 18,
            onPressed: () => Get.back(),
            icon: Icon(Icons.arrow_back_ios),
          ),
          actions: [
            IconButton(
              onPressed: () {
                Get.to(
                  () => CreatePageScreen(),
                  transition: Transition.fadeIn,
                  duration: const Duration(milliseconds: 500),
                );
              },
              icon: Icon(Icons.add),
            ),
          ],
          bottom: TabBar(
            dividerHeight: 0.1,
            indicatorSize: TabBarIndicatorSize.tab,
            labelStyle: context.textTheme.bodyLarge,
            labelColor: context.colorsScheme.surface,
            indicatorAnimation: TabIndicatorAnimation.elastic,
            unselectedLabelStyle: context.textTheme.bodyMedium,
            unselectedLabelColor: context.colorsScheme.onSecondary,
            labelPadding: EdgeInsets.symmetric(horizontal: Sizer.w(2)),
            indicatorPadding: EdgeInsetsGeometry.symmetric(
              vertical: Sizer.h(0.6),
              horizontal: Sizer.w(1),
            ),
            indicator: BoxDecoration(
              color: context.colorsScheme.primary,
              borderRadius: BorderRadius.circular(10),
            ),
            tabs: const [
              Tab(text: "My Page"),
              Tab(text: "Suggested Page"),
              Tab(text: "Liked Page"),
            ],
          ),
        ),

        body: AppHorizontalPadding(
          child: TabBarView(
            children: [
              pageProvider.isLoading
                  ? SizedBox(child: CommonLoader())
                  : buildTabContent(
                    "My Page",
                    pageProvider.myPages,
                    context,
                    pageProvider,
                  ),
              pageProvider.isLoading
                  ? SizedBox(child: CommonLoader())
                  : buildTabContent(
                    "Suggested Page",
                    pageProvider.suggestedPages,
                    context,
                    pageProvider,
                  ),
              pageProvider.isLoading
                  ? SizedBox(child: CommonLoader())
                  : buildTabContent(
                    "Liked Page",
                    pageProvider.likedPages,
                    context,
                    pageProvider,
                  ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTabContent(
    String title,
    dynamic pageData,
    BuildContext context,
    PageProvider pageProvider,
  ) {
    return RefreshIndicator.adaptive(
      onRefresh: () async {
        await pageProvider.getPageListData(true);
      },
      child: ListView.builder(
        itemCount: pageData.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              Get.to(
                transition: Transition.fadeIn,
                duration: const Duration(milliseconds: 500),
                () => DetailsPageScreen(detailsData: pageData[index]),
              );
            },
            child: customCard(
              title: title,
              context: context,
              data: pageData[index],
              pageProvider: pageProvider,
            ),
          );
        },
      ),
    );
  }

  Widget customCard({
    required String title,
    required dynamic data,
    required BuildContext context,
    required PageProvider pageProvider,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: Sizer.h(1),
        horizontal: Sizer.w(2),
      ),
      margin: EdgeInsets.symmetric(vertical: Sizer.h(1)),
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
        children: [
          Row(
            children: [
              SizedBox(
                height: Sizer.h(9),
                width: Sizer.w(20),
                child: NetImage(
                  fit: BoxFit.cover,
                  imageUrl: data['logo'].toString(),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              SizedBox(width: Sizer.w(3)),
              Column(
                spacing: Sizer.h(0.2),
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    fontWeight: FontWeight.w500,
                    text: data["title"].toString(),
                  ),
                  AppText(
                    fontSize: Sizer.sp(2.8),
                    text: "${data["like_count"].toString()} Likes",
                  ),
                  AppButton(
                    height: Sizer.h(4),
                    width: Sizer.w(25),
                    backgroundColor: Colors.transparent,
                    borderColor: context.colorsScheme.onSecondary,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Icon(
                          size: 20,
                          Icons.favorite,
                          color:
                              data["is_Liked"] == "Liked"
                                  ? AppColors.errorColor
                                  : context.colorsScheme.onSecondary,
                        ),
                        SizedBox(width: Sizer.w(1)),
                        AppText(
                          fontWeight: FontWeight.w500,
                          text: data["is_Liked"] == "Liked" ? "Liked" : "Like",
                        ),
                      ],
                    ),
                    onPressed: () {
                      if (data["is_Liked"] == "Liked") {
                        pageProvider.pageDisLikedAPI(context, data['id']);
                      } else {
                        pageProvider.pageLikedAPI(context, data['id']);
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
