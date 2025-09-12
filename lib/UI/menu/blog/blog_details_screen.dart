import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:talknep/components/app_appbar.dart';
import 'package:talknep/components/app_spacing.dart';
import 'package:talknep/components/net_image.dart';
import 'package:talknep/constant/app_color.dart';
import 'package:talknep/constant/global.dart';
import 'package:talknep/gen/assets.gen.dart';
import 'package:talknep/util/theme_extension.dart';
import 'package:talknep/widget/app_sizer.dart';
import 'package:talknep/widget/app_text.dart';

class BlogDetailsScreen extends StatelessWidget {
  final dynamic blogDetailsData;
  const BlogDetailsScreen({super.key, this.blogDetailsData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppAppbar(title: "Blogs Details"),
      backgroundColor: context.scaffoldBackgroundColor,
      body: AppHorizontalPadding(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: Sizer.w(2),
                  vertical: Sizer.h(1),
                ),
                margin: EdgeInsets.only(bottom: Sizer.h(2)),
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
                child: SizedBox(
                  height: Sizer.h(25),
                  width: double.infinity,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child:
                        blogDetailsData['user_image'] != null
                            ? NetImage(
                              fit: BoxFit.cover,
                              imageUrl:
                                  blogDetailsData['user_image'].toString(),
                            )
                            : Assets.image.png.backgroundImage.image(
                              fit: BoxFit.cover,
                            ),
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5.w),
                  border: Border.all(color: context.colorsScheme.onSecondary),
                ),
                padding: EdgeInsets.symmetric(
                  vertical: Sizer.h(1),
                  horizontal: Sizer.w(2),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: NetworkImage(
                        Global.userImage.toString(),
                      ),
                    ),
                    SizedBox(width: Sizer.w(2)),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText(
                          text: blogDetailsData['user'].toString(),
                          fontWeight: FontWeight.w500,
                        ),
                        AppText(
                          text: blogDetailsData['created_at'].toString(),
                          fontSize: Sizer.sp(2.5),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: Sizer.h(2)),
              AppText(
                text: blogDetailsData['title'].toString(),
                fontSize: Sizer.sp(4),
                fontWeight: FontWeight.w500,
              ),
              SizedBox(height: Sizer.h(1)),
              Html(
                data: blogDetailsData['description'].toString(),
                style: {
                  "h2": Style(
                    fontSize: FontSize.xLarge,
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.normal,
                    color: AppColors.textPrimaryColor,
                    fontFamily: GoogleFonts.poppins().fontFamily,
                  ),
                  "p": Style(
                    fontSize: FontSize.medium,
                    color: AppColors.textPrimaryColor,
                    fontFamily: GoogleFonts.poppins().fontFamily,
                    lineHeight: LineHeight.number(1.5),
                  ),
                },
              ),
              SizedBox(height: Sizer.h(1)),
              if (blogDetailsData['tag'] != null &&
                  blogDetailsData['tag'] is List)
                Wrap(
                  spacing: Sizer.w(2),
                  children: List.generate(
                    blogDetailsData['tag'].length,
                    (index) => AppText(
                      fontSize: Sizer.sp(2.8),
                      fontWeight: FontWeight.w500,
                      color: context.colorsScheme.primary,
                      text: "#${blogDetailsData['tag'][index]}",
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
