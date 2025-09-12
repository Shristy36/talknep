import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:talknep/UI/another%20user%20profile/another_user_profile_screen.dart';
import 'package:talknep/components/app_appbar.dart';
import 'package:talknep/components/app_spacing.dart';
import 'package:talknep/components/net_image.dart';
import 'package:talknep/provider/another%20user%20profile/another_user_profile_provider.dart';
import 'package:talknep/provider/menu/profile_provider.dart';
import 'package:talknep/util/theme_extension.dart';
import 'package:talknep/widget/app_sizer.dart';
import 'package:talknep/widget/app_text.dart';

class SeeAllFriendScreen extends StatefulWidget {
  final ProfileProvider provider;
  SeeAllFriendScreen({required this.provider});

  @override
  State<SeeAllFriendScreen> createState() => _SeeAllFriendScreenState();
}

class _SeeAllFriendScreenState extends State<SeeAllFriendScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppAppbar(title: 'Friends'),
      backgroundColor: context.scaffoldBackgroundColor,
      body: AppHorizontalPadding(
        child: Column(
          children: [
            SizedBox(height: Sizer.h(1)),
            SizedBox(
              height: Sizer.h(5.5),
              child: CupertinoSearchTextField(
                focusNode: widget.provider.focusNode,
                placeholder: "Search your friends",
                controller: widget.provider.searchController,
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
                borderRadius: BorderRadius.circular(15),
                prefixInsets: EdgeInsets.only(left: 15.0),
                suffixInsets: EdgeInsets.only(right: 10.0),
                prefixIcon: Icon(
                  CupertinoIcons.search,
                  color: context.colorsScheme.onSurface,
                ),
                onChanged: (value) {
                  setState(() {
                    widget.provider.filterFriendList(value);
                  });
                },
                onSubmitted: (_) => widget.provider.focusNode.unfocus(),
              ),
            ),
            SizedBox(height: Sizer.h(1)),
            Expanded(
              child:
                  widget.provider.filteredFriendList.isEmpty
                      ? Center(
                        child: AppText(
                          fontSize: Sizer.sp(3),
                          text: "No friends found",
                        ),
                      )
                      : ListView.builder(
                        itemCount: widget.provider.filteredFriendList.length,
                        itemBuilder: (context, index) {
                          final friend =
                              widget.provider.filteredFriendList[index];
                          return InkWell(
                            onTap: () {
                              anotherUserProfileId = friend['friend_id'];
                              Get.to(
                                transition: Transition.fadeIn,
                                () => const AnotherUserProfileScreen(),
                                duration: const Duration(milliseconds: 500),
                              );
                            },
                            child: Container(
                              margin: EdgeInsets.only(bottom: Sizer.h(1.2)),
                              padding: EdgeInsets.symmetric(
                                horizontal: Sizer.w(3),
                                vertical: Sizer.h(1.5),
                              ),
                              decoration: BoxDecoration(
                                color: context.scaffoldBackgroundColor,
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(
                                  color: context.colorsScheme.onSecondary,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    blurRadius: 4,
                                    spreadRadius: 1,
                                    offset: Offset(0, 2),
                                    color: context.colorsScheme.shadow,
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    height: 45,
                                    width: 45,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: context.scaffoldBackgroundColor,
                                      border: Border.all(
                                        width: 1,
                                        color:
                                            context
                                                .colorsScheme
                                                .onSecondaryContainer,
                                      ),
                                    ),
                                    child: ClipRRect(
                                      child: NetImage(
                                        imageUrl: friend['photo']!,
                                      ),
                                      borderRadius: BorderRadius.circular(5.w),
                                    ),
                                  ),
                                  SizedBox(width: Sizer.w(3)),
                                  AppText(text: friend['name']),
                                  Spacer(),
                                  GestureDetector(
                                    onTapDown: (TapDownDetails details) {
                                      final RenderBox overlay =
                                          Overlay.of(
                                                context,
                                              ).context.findRenderObject()
                                              as RenderBox;
                                      final Offset localPosition = overlay
                                          .globalToLocal(
                                            details.globalPosition,
                                          );

                                      showMenu(
                                        context: context,
                                        color: context.colorsScheme.onPrimary,
                                        position: RelativeRect.fromLTRB(
                                          localPosition.dx,
                                          localPosition.dy,
                                          localPosition.dx,
                                          localPosition.dy,
                                        ),
                                        items: [
                                          PopupMenuItem(
                                            value: 'remove',
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 15,
                                            ),
                                            child: SizedBox(
                                              child: Center(
                                                child: AppText(
                                                  text: "Remove friend",
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                        elevation: 8.0,
                                      ).then((value) {
                                        if (value == 'remove') {
                                          widget.provider.unfollowAPI(
                                            friend['friend_id'].toString(),
                                          );
                                          setState(() {
                                            widget.provider.filteredFriendList
                                                .removeAt(index);
                                          });
                                        }
                                      });
                                    },
                                    child: const Icon(Icons.more_horiz),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
