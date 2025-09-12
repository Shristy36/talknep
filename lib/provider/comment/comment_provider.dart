import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talknep/main.dart';
import 'package:talknep/service/api_service.dart';
import 'package:talknep/widget/app_snackbar.dart';

class CommentProvider with ChangeNotifier {
  dynamic postIds;
  dynamic getCommentData;
  bool isLoading = false;
  TextEditingController commentController = TextEditingController();
  TextEditingController replyCommentController = TextEditingController();

  getComment(postId) async {
    postIds = postId;
    isLoading = true;
    notifyListeners();
    try {
      final response = await ApiService.get('get_comment/$postId');

      if (response != null &&
          (response.statusCode == 200 || response.statusCode == 201)) {
        getCommentData = response.data;
      } else {
        final message =
            response?.data is Map && response?.data['message'] != null
                ? response?.data['message']
                : 'Unexpected error occurred.';
        showCustomSnackbar(Get.context!, message, type: SnackbarType.error);
      }
    } catch (e) {
      logger.e("Get Comment API Error: $e");
      showCustomSnackbar(
        Get.context!,
        "Something went wrong: $e",
        type: SnackbarType.error,
      );
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  createComment(context, type, parentId, {bool? isCommentReply}) async {
    isLoading = true;
    notifyListeners();
    try {
      final response = await ApiService.post('post_comment', {
        "description":
            isCommentReply == true
                ? replyCommentController.text.toString()
                : commentController.text.toString(),
        "is_type": type.toString(),
        "id_of_type": postIds.toString(),
        "parent_id": parentId.toString(),
        "comment": "comment",
      });

      if (response != null &&
          (response.statusCode == 201 || response.statusCode == 200)) {
        commentController.clear();
        replyCommentController.clear();
        getComment(postIds);
        notifyListeners();
      } else {
        showCustomSnackbar(
          context,
          response!.data['message'],
          type: SnackbarType.error,
        );
      }
    } catch (e) {
      logger.e("Create Comment Error: $e");
      showCustomSnackbar(
        context,
        "Something went wrong: $e",
        type: SnackbarType.error,
      );
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
