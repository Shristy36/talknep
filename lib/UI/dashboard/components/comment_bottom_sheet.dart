import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:talknep/provider/dashboard/dashboard_provider.dart';
import 'package:talknep/util/theme_extension.dart';
import 'package:talknep/UI/comment/comment_screen.dart';

void showCommentBottomSheet({
  required dynamic postId,
  required dynamic postType,
  required BuildContext context,
}) {
  showModalBottomSheet(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    backgroundColor: context.colorsScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (_) {
      return DraggableScrollableSheet(
        expand: false,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        initialChildSize: 0.85,
        builder: (context, scrollController) {
          return ChangeNotifierProvider.value(
            value: Provider.of<DashboardProvider>(context),
            child: CommentBottomSheetContent(
              postId: postId,
              postType: postType,
              scrollController: scrollController,
            ),
          );
        },
      );
    },
  );
}
