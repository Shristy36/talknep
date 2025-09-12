import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:talknep/components/app_appbar.dart';
import 'package:talknep/components/app_spacing.dart';
import 'package:talknep/components/net_image.dart';
import 'package:talknep/provider/menu/blog/blog_provider.dart';
import 'package:talknep/util/theme_extension.dart';
import 'package:talknep/UI/menu/blog/blog_details_screen.dart';
import 'package:talknep/UI/menu/blog/create_blog_screen.dart';
import 'package:talknep/widget/app_loader.dart';
import 'package:talknep/widget/app_sizer.dart';
import 'package:talknep/widget/app_text.dart';

class BlogScreen extends StatelessWidget {
  const BlogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<BlogProvider>(context);
    return Scaffold(
      backgroundColor: context.scaffoldBackgroundColor,
      appBar: AppAppbar(
        title: 'Blogs',
        actions: [
          IconButton(
            onPressed:
                () => Get.to(
                  () => CreateBlogScreen(),
                  transition: Transition.fadeIn,
                  duration: const Duration(milliseconds: 500),
                ),
            icon: Icon(Icons.add),
          ),
        ],
      ),
      body:
          provider.isLoading
              ? CommonLoader(color: context.colorsScheme.primary)
              : RefreshIndicator.adaptive(
                onRefresh: () async {
                  await provider.getBlogListData();
                },
                child: AppHorizontalPadding(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: Sizer.h(1)),

                      SizedBox(
                        height: Sizer.h(5.5),
                        width: double.infinity,
                        child: CupertinoSearchTextField(
                          placeholder: "Search blog",
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
                          onChanged: provider.filterBlogName,
                          onSubmitted: (_) => FocusScope.of(context).unfocus(),
                        ),
                      ),
                      SizedBox(height: Sizer.h(2)),
                      Flexible(
                        child: ListView.builder(
                          itemCount: provider.filteredBlogName.length,
                          keyboardDismissBehavior:
                              ScrollViewKeyboardDismissBehavior.onDrag,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () {
                                Get.to(
                                  transition: Transition.fadeIn,
                                  duration: const Duration(milliseconds: 500),
                                  () => BlogDetailsScreen(
                                    blogDetailsData:
                                        provider.filteredBlogName[index],
                                  ),
                                );
                              },
                              child: customCard(
                                provider.filteredBlogName[index],
                                context,
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }

  Widget customCard(dynamic blogData, BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: Sizer.h(1),
        horizontal: Sizer.w(2),
      ),
      margin: EdgeInsets.only(bottom: Sizer.h(1)),
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
        spacing: Sizer.h(0.5),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: Sizer.h(25),
            width: double.infinity,
            child: NetImage(
              borderRadius: BorderRadius.circular(12),
              fit: BoxFit.cover,
              imageUrl: blogData['coverphoto'],
            ),
          ),
          AppText(text: blogData['title'], fontWeight: FontWeight.w500),
          AppText(text: blogData['created_at'], fontSize: Sizer.sp(3)),
          AppText(
            text: "VIEW THESE RESOURCES",
            fontSize: Sizer.sp(3),
            color: context.colorsScheme.primary,
          ),
        ],
      ),
    );
  }
}
