import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:talknep/components/app_appbar.dart';
import 'package:talknep/components/app_spacing.dart';
import 'package:talknep/components/net_image.dart';
import 'package:talknep/constant/app_color.dart';
import 'package:talknep/provider/search%20all%20friend/search_all_friend_provider.dart';
import 'package:talknep/util/theme_extension.dart';
import 'package:talknep/widget/app_loader.dart';
import 'package:talknep/widget/app_sizer.dart';
import 'package:talknep/widget/app_text.dart';

class SearchAllFriendScreen extends StatefulWidget {
  const SearchAllFriendScreen({super.key});

  @override
  State<SearchAllFriendScreen> createState() => _SearchAllFriendScreenState();
}

class _SearchAllFriendScreenState extends State<SearchAllFriendScreen> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {});
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final searchAllFriendProvider = Provider.of<SearchAllFriendProvider>(
      context,
    );

    final displayedList = searchAllFriendProvider.getRandomTenList;

    return Scaffold(
      appBar: AppAppbar(title: 'Search'),
      backgroundColor: context.scaffoldBackgroundColor,
      body: AppHorizontalPadding(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: Sizer.h(1)),
            SizedBox(
              height: Sizer.h(5.5),
              child: CupertinoSearchTextField(
                placeholder: "Search your friends",
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
                onChanged: (value) {
                  setState(() {
                    searchAllFriendProvider.filterFriendList(value);
                  });
                },
              ),
            ),
            SizedBox(height: Sizer.h(1)),
            AppText(text: 'Suggested', fontWeight: FontWeight.w500),
            Expanded(
              child:
                  searchAllFriendProvider.isLoading
                      ? CommonLoader()
                      : displayedList.isEmpty
                      ? Center(
                        child: AppText(
                          text: "No user found",
                          fontSize: Sizer.sp(4),
                          fontWeight: FontWeight.w500,
                        ),
                      )
                      : RefreshIndicator.adaptive(
                        onRefresh: () async {
                          await searchAllFriendProvider.generateRandomTen();
                        },
                        child: ListView.builder(
                          cacheExtent: 999999999999999,
                          itemCount: displayedList.length,
                          physics: const AlwaysScrollableScrollPhysics(),
                          keyboardDismissBehavior:
                              ScrollViewKeyboardDismissBehavior.onDrag,
                          itemBuilder: (context, index) {
                            final friend = displayedList[index];
                            final String friendRequestStatus =
                                friend['friend_request_status'] ?? 'none';
                            final bool isSent = friendRequestStatus == 'sent';

                            return Container(
                              margin: EdgeInsets.symmetric(
                                vertical: Sizer.h(1),
                              ),
                              padding: EdgeInsets.symmetric(
                                vertical: Sizer.h(1),               
                                horizontal: Sizer.w(3),
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: context.colorsScheme.onSecondary,
                                ),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  NetImage(
                                    width: Sizer.w(20),
                                    height: Sizer.w(20),
                                    imageUrl: friend['photo'].toString(),
                                    borderRadius: BorderRadius.circular(10.h),
                                  ),
                                  SizedBox(width: Sizer.w(4)),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        AppText(
                                          text: friend['name'].toString(),
                                          fontWeight: FontWeight.w600,
                                          fontSize: Sizer.sp(3.8),
                                        ),
                                        SizedBox(height: 8),
                                        Row(
                                          children: [
                                            if (isSent)
                                              // Show "Cancel Request"
                                              GestureDetector(
                                                onTap: () async {
                                                  // Cancel the request logic here
                                                  await searchAllFriendProvider
                                                      .cancelFriend(
                                                        friend['id'],
                                                      );
                                                  setState(() {
                                                    friend['friend_request_status'] =
                                                        'none';
                                                  });
                                                },
                                                child: Container(
                                                  padding: EdgeInsets.symmetric(
                                                    horizontal: Sizer.w(4),
                                                    vertical: Sizer.h(1.2),
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey.shade800,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          Sizer.w(2),
                                                        ),
                                                  ),
                                                  child: AppText(
                                                    text: "Cancel request",
                                                    color: Colors.white,
                                                    fontSize: Sizer.sp(3.2),
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              )
                                            else ...[
                                              // Show "Add friend" and "Remove"
                                              GestureDetector(
                                                onTap: () async {
                                                  await searchAllFriendProvider
                                                      .addFriend(friend['id']);
                                                  setState(() {
                                                    friend['friend_request_status'] =
                                                        'sent';
                                                  });
                                                },
                                                child: Container(
                                                  padding: EdgeInsets.symmetric(
                                                    horizontal: Sizer.w(4),
                                                    vertical: Sizer.h(1),
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color:
                                                        context
                                                            .colorsScheme
                                                            .primary,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          Sizer.w(2),
                                                        ),
                                                  ),
                                                  child: AppText(
                                                    text: "Add friend",
                                                    fontSize: Sizer.sp(3.2),
                                                    color: AppColors.whiteColor,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ),
                                              SizedBox(width: 8),
                                              GestureDetector(
                                                onTap: () {
                                                  final friendId = friend['id'];
                                                  setState(() {
                                                    searchAllFriendProvider
                                                        .filteredFriendList
                                                        .removeWhere(
                                                          (element) =>
                                                              element['id'] ==
                                                              friendId,
                                                        );
                                                    searchAllFriendProvider
                                                        .randomTenList
                                                        .removeWhere(
                                                          (element) =>
                                                              element['id'] ==
                                                              friendId,
                                                        );
                                                  });
                                                },
                                                child: Container(
                                                  padding: EdgeInsets.symmetric(
                                                    horizontal: Sizer.w(4),
                                                    vertical: Sizer.h(1.2),
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: context
                                                        .colorsScheme
                                                        .secondary
                                                        .withValues(alpha: 0.9),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          Sizer.w(2),
                                                        ),
                                                  ),
                                                  child: AppText(
                                                    text: "Remove",
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: Sizer.sp(3.2),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
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
}
