import 'package:flutter/material.dart';
import 'package:flutter_advanced_avatar/flutter_advanced_avatar.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:talknep/UI/dashboard/post/components/description_text.dart';
import 'package:talknep/UI/menu/page/update_page_screen.dart';
import 'package:talknep/components/app_appbar.dart';
import 'package:talknep/components/app_spacing.dart';
import 'package:talknep/components/net_image.dart';
import 'package:talknep/constant/app_color.dart';
import 'package:talknep/gen/assets.gen.dart';
import 'package:talknep/provider/menu/page/page_provider.dart';
import 'package:talknep/util/theme_extension.dart';
import 'package:talknep/widget/app_button.dart';
import 'package:talknep/widget/app_sizer.dart';
import 'package:talknep/widget/app_text.dart';

class DetailsPageScreen extends StatefulWidget {
  final dynamic detailsData;
  const DetailsPageScreen({super.key, this.detailsData});

  @override
  State<DetailsPageScreen> createState() => _DetailsPageScreenState();
}

class _DetailsPageScreenState extends State<DetailsPageScreen> {
  @override
  void initState() {
    super.initState();
    final pageProvider = Provider.of<PageProvider>(context, listen: false);
    pageProvider.isLiked = widget.detailsData["is_Liked"] == "Liked";
  }

  @override
  Widget build(BuildContext context) {
    final pageProvider = Provider.of<PageProvider>(context);

    return Scaffold(
      appBar: AppAppbar(title: 'Details Page'),
      backgroundColor: context.scaffoldBackgroundColor,
      body: SingleChildScrollView(
        child: AppHorizontalPadding(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: Sizer.h(30),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: context.scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 4,
                      spreadRadius: 1,
                      offset: Offset(0, 2),
                      color: context.colorsScheme.shadow,
                    ),
                  ],
                  border: Border.all(color: context.colorsScheme.onSecondary),
                ),
                child: Stack(
                  children: [
                    Container(
                      height: Sizer.h(20),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: context.scaffoldBackgroundColor,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: context.colorsScheme.onSecondary,
                        ),
                      ),
                      child: NetImage(
                        fit: BoxFit.cover,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(15),
                          topRight: Radius.circular(15),
                        ),
                        imageUrl: widget.detailsData['coverPhoto'],
                      ),
                    ),
                    Positioned(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: EdgeInsets.only(
                            left: 15,
                            bottom: Sizer.h(2.5),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              GestureDetector(
                                child: AdvancedAvatar(
                                  size: 9.h,
                                  image:
                                      (widget.detailsData['logo'] != null &&
                                              widget.detailsData['logo']
                                                  .toString()
                                                  .isNotEmpty &&
                                              widget.detailsData['logo']
                                                      .toString() !=
                                                  "null")
                                          ? NetworkImage(
                                            widget.detailsData['logo']
                                                .toString(),
                                          )
                                          : Assets
                                                  .image
                                                  .png
                                                  .backgroundImage
                                                  .path
                                              as ImageProvider,
                                ),
                              ),
                              SizedBox(height: Sizer.h(1)),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(left: Sizer.w(3)),
                                    child: AppText(
                                      text:
                                          widget.detailsData['title']
                                              .toString(),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(right: Sizer.w(3)),
                                    child: AppButton(
                                      height: Sizer.h(4),
                                      width: Sizer.w(25),
                                      backgroundColor: Colors.transparent,
                                      borderColor:
                                          context.colorsScheme.onSecondary,
                                      onPressed: () {
                                        if (widget.detailsData["is_Liked"] ==
                                            "Liked") {
                                          pageProvider.pageDisLikedAPI(
                                            context,
                                            widget.detailsData['id'],
                                          );
                                        } else {
                                          pageProvider.pageLikedAPI(
                                            context,
                                            widget.detailsData['id'],
                                          );
                                        }
                                        setState(() {
                                          pageProvider.isLiked =
                                              !pageProvider.isLiked;
                                        });
                                      },

                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.favorite,
                                            color:
                                                pageProvider.isLiked
                                                    ? AppColors.errorColor
                                                    : context
                                                        .colorsScheme
                                                        .secondary,
                                            size: 20,
                                          ),
                                          SizedBox(width: Sizer.w(1.5)),
                                          AppText(
                                            text:
                                                pageProvider.isLiked
                                                    ? "Liked"
                                                    : "Like",
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
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
              DescriptionText(
                htmlDescription: widget.detailsData['description'] ?? "",
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar:
          widget.detailsData['my_page'] == "my_page"
              ? Padding(
                padding: EdgeInsets.symmetric(
                  vertical: Sizer.h(2),
                  horizontal: Sizer.w(2),
                ),
                child: AppButton(
                  onPressed: () {
                    Get.to(
                      UpdatePageScreen(updateData: widget.detailsData),
                      transition: Transition.fadeIn,
                      duration: const Duration(milliseconds: 500),
                    );
                  },
                  child: AppText(text: "Edit", color: AppColors.whiteColor),
                ),
              )
              : SizedBox(),
    );
  }
}
