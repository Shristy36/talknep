import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:talknep/components/app_appbar.dart';
import 'package:talknep/components/app_spacing.dart';
import 'package:talknep/components/net_image.dart';
import 'package:talknep/provider/createPost/create_post_provider.dart';
import 'package:talknep/util/theme_extension.dart';
import 'package:talknep/widget/app_sizer.dart';
import 'package:talknep/widget/app_text.dart';

class TagFriendScreen extends StatefulWidget {
  const TagFriendScreen({super.key});

  @override
  State<TagFriendScreen> createState() => _TagFriendScreenState();
}

class _TagFriendScreenState extends State<TagFriendScreen> {
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CreatePostProvider>(context);

    final allFriends = provider.friendDataList?['friendsList'] ?? [];

    final filteredFriends =
        allFriends.where((friend) {
          final name = friend['name']?.toString().toLowerCase() ?? '';
          return name.contains(searchQuery.toLowerCase());
        }).toList();

    return Scaffold(
      backgroundColor: context.scaffoldBackgroundColor,
      appBar: AppAppbar(title: 'Tag friends'),
      body: AppHorizontalPadding(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: Sizer.h(1)),
            SizedBox(
              height: Sizer.h(5.5),
              width: Get.width,
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
                    searchQuery = value;
                  });
                },
              ),
            ),
            SizedBox(height: Sizer.h(1.5)),
            AppText(text: "Suggestions", fontWeight: FontWeight.w500),
            SizedBox(height: Sizer.h(0.5)),
            Expanded(
              child: ListView.builder(
                itemCount: filteredFriends.length,
                itemBuilder: (context, index) {
                  final friend = filteredFriends[index];
                  final originalIndex = allFriends.indexOf(friend);
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: Sizer.h(1)),
                    child: Row(
                      children: [
                        ClipOval(
                          child: SizedBox(
                            width: 44,
                            height: 44,
                            child: NetImage(
                              fit: BoxFit.cover,
                              imageUrl: friend['photo'],
                            ),
                          ),
                        ),
                        SizedBox(width: Sizer.w(2)),
                        AppText(
                          text: friend['name'].toString(),
                          fontWeight: FontWeight.w500,
                        ),
                        Spacer(),
                        Checkbox.adaptive(
                          value: provider.selectedFriendIndexes.contains(
                            originalIndex,
                          ),
                          onChanged: (val) {
                            provider.toggleFriendSelection(
                              originalIndex,
                              friend,
                            );
                          },
                        ),
                      ],
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
