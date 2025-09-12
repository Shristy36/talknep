import 'dart:io';
import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talknep/widget/app_snackbar.dart';
import 'package:talknep/constant/global.dart';
import 'package:talknep/main.dart';
import 'package:talknep/service/api_service.dart';

class ProfileProvider with ChangeNotifier {
  dynamic userInfo;

  final FocusNode focusNode = FocusNode();

  bool isLoading = false;

  dynamic friendsListData;

  List<dynamic> filteredFriendList = [];

  bool isCoverImage = false;

  dynamic userProfilePhoto;

  File? selectedUserImage;

  File? selectedUserCoverImage;

  final TextEditingController searchController = TextEditingController();
  ProfileProvider() {
    getUserProfileData();
  }

  updateProfileUserImage() async {
    if (selectedUserImage != null) {
      final file = await dio.MultipartFile.fromFile(
        selectedUserImage!.path,
        filename: selectedUserImage!.path.split('/').last,
      );

      final response = await ApiService.postMultipart(
        'update_profile_pic',
        {},
        {'profile_photo': file},
      );

      if (response != null && response.statusCode == 200) {
        Global.userImage = response.data['photo_url'];
        getUserProfileData();

        notifyListeners();

        logger.i("✅ Upload Success: ${response.data}");
      } else {
        logger.e("❌ Upload failed: ${response?.statusMessage}");
      }
    } else {
      logger.w("⚠️ No image selected for upload.");
    }
  }

  updateProfileUserCoverImage() async {
    if (selectedUserCoverImage != null) {
      final file = await dio.MultipartFile.fromFile(
        selectedUserCoverImage!.path,
        filename: selectedUserCoverImage!.path.split('/').last,
      );

      final response = await ApiService.postMultipart('update_cover_pic', {}, {
        'cover_photo': file,
      });

      if (response != null && response.statusCode == 200) {
        Global.userCoverImage = response.data['cover_photo'];

        getUserProfileData();

        notifyListeners();
        logger.i("✅ Upload Success: ${response.data}");
      } else {
        logger.e("❌ Upload failed: ${response?.statusMessage}");
      }
    } else {
      logger.w("⚠️ No image selected for upload.");
    }
  }

  getUserProfileData() async {
    isLoading = true;
    notifyListeners();
    try {
      final response = await ApiService.get('profile');

      if (response != null &&
          (response.statusCode == 200 || response.statusCode == 201)) {
        userInfo = response.data;

        userProfilePhoto = response.data['posts'];

        friendListAPI();

        notifyListeners();
      } else {
        final message =
            response?.data is Map && response?.data['message'] != null
                ? response?.data['message']
                : 'Unexpected error occurred.';
        showCustomSnackbar(Get.context!, message, type: SnackbarType.error);
      }
    } catch (e) {
      logger.e("Profile Photos and Videos API Error: $e");
      showCustomSnackbar(
        Get.context!,
        "Something went wrong: $e",
        type: SnackbarType.error,
      );
    } finally {
      notifyListeners();
    }
  }

  friendListAPI() async {
    isLoading = true;
    notifyListeners();

    try {
      final response = await ApiService.get('friends');

      if (response != null &&
          (response.statusCode == 200 || response.statusCode == 201)) {
        friendsListData = response.data['friendsList'] ?? [];

        if (searchController.text.isNotEmpty) {
          filterFriendList(searchController.text);
        } else {
          filteredFriendList = List.from(friendsListData);
        }

        notifyListeners();
      } else {
        final message =
            response?.data is Map && response?.data['message'] != null
                ? response?.data['message']
                : 'Unexpected error occurred.';

        showCustomSnackbar(Get.context!, message, type: SnackbarType.error);
      }
    } catch (e) {
      logger.e("Friends API Error: $e");
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

  filterFriendList(String query) {
    if (query.isEmpty) {
      filteredFriendList = List.from(friendsListData);
    } else {
      filteredFriendList =
          friendsListData
              .where(
                (friend) => friend['name'].toString().toLowerCase().contains(
                  query.toLowerCase(),
                ),
              )
              .toList();
    }
    notifyListeners();
  }

  unfollowAPI(String id) async {
    isLoading = true;
    notifyListeners();
    try {
      final response = await ApiService.post('unfriend/$id', {});
      if (response != null &&
          (response.statusCode == 200 || response.statusCode == 201)) {
        await friendListAPI();
      } else {
        final message =
            response?.data is Map && response?.data['message'] != null
                ? response?.data['message']
                : 'Unexpected error occurred.';
        showCustomSnackbar(Get.context!, message, type: SnackbarType.error);
      }
    } catch (e) {
      logger.e("UnFollow Error: $e");
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

  Future<void> deletePostAPI(BuildContext context, String postId) async {
    if (userProfilePhoto == null) return;

    // 🟢 Step 1: Save index + postData before removing
    final index = userProfilePhoto.indexWhere(
      (post) => post['post_id'].toString() == postId.toString(),
    );

    if (index == -1) return; // post not found

    final removedPost = userProfilePhoto[index];

    // 🟢 Step 2: Remove instantly from UI
    userProfilePhoto.removeAt(index);
    notifyListeners();

    try {
      // 🟢 Step 3: API call
      final response = await ApiService.post('delete_post/$postId', {});

      if (response != null && response.statusCode == 200) {
        logger.i("Delete Post Response: ${response.data}");

        showCustomSnackbar(
          context,
          response.data['alertMessage'],
          type: SnackbarType.success,
        );
      } else {
        logger.e("Delete Post Failed Response: ${response?.data}");

        // 🔴 Step 4: API failed → rollback
        userProfilePhoto.insert(index, removedPost);
        notifyListeners();

        final message =
            response?.data is Map && response?.data['message'] != null
                ? response?.data['message']
                : 'Failed to delete post';
        showCustomSnackbar(context, message, type: SnackbarType.error);
      }
    } catch (e) {
      logger.e("Delete Post Error: $e");

      // 🔴 Step 4: Exception → rollback
      userProfilePhoto.insert(index, removedPost);
      notifyListeners();

      if (context.mounted) {
        showCustomSnackbar(
          context,
          "Something went wrong: $e",
          type: SnackbarType.error,
        );
      }
    }
  }

  postLike({required int index, required int postId}) async {
    final post = userProfilePhoto[index];

    final isLiked = post['userReaction'] == 'like';

    // Toggle locally
    post['userReaction'] = isLiked ? null : 'like';

    // Update total count based on toggle
    int currentTotal = post['reaction_counts']['total'] ?? 0;
    post['reaction_counts']['total'] =
        isLiked ? currentTotal - 1 : currentTotal + 1;

    notifyListeners();

    // Call API
    try {
      await ApiService.post('reaction', {
        'post_id': postId,
        'react': post['userReaction'] ?? 'unlike',
      });
    } catch (e) {
      logger.e("Post Like API Error: $e");
    }
  }
}
