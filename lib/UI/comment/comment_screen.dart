import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:talknep/constant/app_color.dart';
import 'package:talknep/provider/comment/comment_provider.dart';
import 'package:talknep/util/theme_extension.dart';
import 'package:talknep/widget/app_loader.dart';
import 'package:talknep/widget/app_sizer.dart';
import 'package:talknep/widget/app_text.dart';
import 'package:talknep/widget/app_textfield.dart';

class CommentBottomSheetContent extends StatefulWidget {
  final dynamic postId;
  final dynamic postType;
  final ScrollController scrollController;

  const CommentBottomSheetContent({
    super.key,
    required this.postId,
    required this.postType,
    required this.scrollController,
  });

  @override
  State<CommentBottomSheetContent> createState() =>
      _CommentBottomSheetContentState();
}

class _CommentBottomSheetContentState extends State<CommentBottomSheetContent> {
  int? activeReplyIndex;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CommentProvider>(
        context,
        listen: false,
      ).getComment(widget.postId);
    });
  }

  void toggleReplyBox(int index) {
    setState(() {
      activeReplyIndex = activeReplyIndex == index ? null : index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(Sizer.w(4)),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => Get.back(),
                child: Icon(Icons.close, size: 20),
              ),
              SizedBox(width: Sizer.w(2)),
              AppText(text: "Comments", fontWeight: FontWeight.w600),
            ],
          ),
        ),
        Expanded(
          child: Consumer<CommentProvider>(
            builder: (context, provider, _) {
              if (provider.isLoading) {
                return Center(
                  child: CommonLoader(color: context.colorsScheme.surface),
                );
              }

              final comments = provider.getCommentData;

              if (comments == null || comments.isEmpty) {
                return const Center(child: AppText(text: "No comments found."));
              }

              return ListView.builder(
                controller: widget.scrollController,
                itemCount: comments.length,
                padding: EdgeInsets.symmetric(vertical: Sizer.h(2)),
                itemBuilder: (context, index) {
                  final comment = comments[index];
                  return Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: Sizer.w(3),
                      vertical: Sizer.h(1.5),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: context.colorsScheme.onSecondary,
                              backgroundImage: NetworkImage(comment['photo']),
                            ),
                            SizedBox(width: Sizer.w(3)),
                            Flexible(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: Sizer.w(4),
                                      vertical: Sizer.h(1),
                                    ),
                                    decoration: BoxDecoration(
                                      color: context.colorsScheme.onSecondary,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        AppText(
                                          text: comment['name'] ?? "User",
                                          fontWeight: FontWeight.w500,
                                        ),
                                        AppText(
                                          text:
                                              comment['created'] ??
                                              "Date not available",
                                          fontSize: Sizer.sp(2.5),
                                        ),
                                        SizedBox(height: Sizer.h(1)),
                                        AppText(
                                          text: comment['description'] ?? "",
                                          fontSize: Sizer.sp(3.2),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: Sizer.h(1)),
                                  GestureDetector(
                                    onTap: () => toggleReplyBox(index),
                                    child: AppText(
                                      text:
                                          "${comment['replies'].length == 0 ? "" : comment['replies'].length} reply",
                                      fontSize: Sizer.w(3),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        if (activeReplyIndex == index)
                          Padding(
                            padding: EdgeInsets.only(
                              top: Sizer.h(1),
                              left: Sizer.w(10),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: comment['replies'].length,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemBuilder: (context, index) {
                                    final reply = comment['replies'][index];

                                    return Align(
                                      alignment: Alignment.topRight,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          CircleAvatar(
                                            radius: 20,
                                            backgroundColor:
                                                AppColors.borderColor,
                                            backgroundImage: NetworkImage(
                                              reply['photo'],
                                            ),
                                          ),
                                          SizedBox(width: Sizer.w(3)),
                                          Flexible(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: [
                                                Container(
                                                  padding: EdgeInsets.symmetric(
                                                    horizontal: Sizer.w(4),
                                                    vertical: Sizer.h(1),
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color:
                                                        context
                                                            .colorsScheme
                                                            .onSecondary,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          12,
                                                        ),
                                                  ),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      AppText(
                                                        text:
                                                            reply['name'] ??
                                                            "User",
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                      AppText(
                                                        text:
                                                            reply['created'] ??
                                                            "Date not available",
                                                        fontSize: Sizer.sp(2.5),
                                                      ),
                                                      SizedBox(
                                                        height: Sizer.h(1),
                                                      ),
                                                      AppText(
                                                        text:
                                                            reply['description'] ??
                                                            "",
                                                        fontSize: Sizer.sp(3.2),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                SizedBox(height: Sizer.h(1)),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                                CommonTextField2(
                                  controller: provider.replyCommentController,
                                  text: 'Write a reply...',
                                  suffixIcon: GestureDetector(
                                    onTap: () {
                                      provider.createComment(
                                        context,
                                        widget.postType.toString(),
                                        comment['comment_id'],
                                        isCommentReply: true,
                                      );
                                      setState(() {
                                        activeReplyIndex = null;
                                      });
                                    },
                                    child: Icon(
                                      CupertinoIcons.paperplane_fill,
                                      color: context.colorsScheme.primary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
        Consumer<CommentProvider>(
          builder: (context, provider, child) {
            return Padding(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).viewInsets.left + Sizer.w(1),
                left: MediaQuery.of(context).viewInsets.left + Sizer.w(1),
                right: MediaQuery.of(context).viewInsets.right + Sizer.w(1),
                bottom: MediaQuery.of(context).viewInsets.bottom + Sizer.h(2),
              ),
              child: CommonTextField2(
                autofocus: true,
                controller: provider.commentController,
                text: 'Write a comment...',
                suffixIcon: GestureDetector(
                  onTap: () {
                    provider.createComment(
                      context,
                      widget.postType.toString(),
                      0,
                      isCommentReply: false,
                    );
                  },
                  child: Icon(
                    CupertinoIcons.paperplane_fill,
                    color: context.colorsScheme.primary,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
