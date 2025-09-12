import 'dart:io';
import 'package:get/get.dart';
import 'package:talknep/constant/app_color.dart';
import 'package:talknep/gen/assets.gen.dart';
import 'package:talknep/main.dart';
import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:talknep/widget/app_sizer.dart';
import 'package:talknep/widget/app_snackbar.dart';
import 'package:talknep/service/api_service.dart';
import 'package:talknep/widget/app_text.dart';
import 'package:talknep/widget/dialog_loader.dart';

class CreatePostProvider with ChangeNotifier {
  File? selectedImage;
  File? selectedVideo;

  String selectedMediaType = "";
  String _selectedPrivacy = 'Public';

  bool isLoading = false;

  dynamic friendDataList;

  dynamic searchMapName;

  dynamic selectedFriendList;

  List<int> selectedFriendIndexes = [];

  String get selectedPrivacy => _selectedPrivacy;

  TextEditingController descriptionController = TextEditingController();

  final ImagePicker _picker = ImagePicker();

  CreatePostProvider() {
    getFriends();
  }

  void toggleFriendSelection(int index, dynamic friendData) {
    if (selectedFriendIndexes.contains(index)) {
      selectedFriendIndexes.remove(index);
    } else {
      selectedFriendIndexes.add(index);
    }
    selectedFriendList =
        selectedFriendIndexes
            .map((i) => friendDataList['friendsList'][i])
            .toList();
    notifyListeners();
  }

  void setSelectedPrivacy(String newValue) {
    _selectedPrivacy = newValue;
    notifyListeners();
  }

  Future<void> pickMediaFromGallery({required bool isVideo}) async {
    final XFile? pickedFile;
    if (isVideo) {
      pickedFile = await _picker.pickVideo(source: ImageSource.gallery);
    } else {
      pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    }

    if (pickedFile != null) {
      if (isVideo) {
        selectedImage = null;
        selectedVideo = null;
        notifyListeners();

        selectedVideo = File(pickedFile.path);
        selectedMediaType = "video";
        notifyListeners();
      } else {
        selectedVideo = null;
        selectedImage = null;
        notifyListeners();
        selectedImage = File(pickedFile.path);
        selectedMediaType = "image";
      }
    }
  }

  List<String> get itemsSelectedPrivacy => ['Public', 'Private'];

  void clearImage() {
    selectedImage = null;
    selectedVideo = null;
    selectedMediaType = "";
    notifyListeners();
  }

  Future<void> getFriends() async {
    isLoading = true;
    notifyListeners();
    try {
      final response = await ApiService.get('friends');

      if (response != null &&
          (response.statusCode == 200 || response.statusCode == 201)) {
        friendDataList = response.data;
        notifyListeners();
      } else {
        final message =
            response?.data is Map && response?.data['message'] != null
                ? response?.data['message']
                : 'Unexpected error occurred.';

        showCustomSnackbar(Get.context!, message, type: SnackbarType.error);
      }
    } catch (e) {
      logger.e("Get Friend API Error: $e");
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

  createPost(context) async {
    try {
      showLoadingDialog(
        context: context,
        widgets: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Assets.lottie.upload.lottie(
              height: Sizer.h(20),
              fit: BoxFit.contain,
            ),
            AppText(
              text: 'Uploading',
              fontWeight: FontWeight.w800,
              color: AppColors.whiteColor,
            ),
          ],
        ),
      );
      if (selectedImage != null || selectedVideo != null) {
        final File selectedFile = selectedImage ?? selectedVideo!;
        final String fileName = selectedFile.path.split('/').last;

        final file = await dio.MultipartFile.fromFile(
          selectedFile.path,
          filename: fileName,
          contentType:
              selectedMediaType == "video"
                  ? MediaType("video", "mp4")
                  : MediaType("image", "jpeg"),
        );

        List<int> taggedUserIds =
            selectedFriendList != null
                ? selectedFriendList
                    .map<int>(
                      (friend) => int.parse(friend['friend_id'].toString()),
                    )
                    .toList()
                : [];

        Map<String, dynamic> fields = {
          'privacy': _selectedPrivacy,
          'publisher': "post",
          'post_type': "general",
          'address': searchMapName ?? '',
          'description': descriptionController.text,
        };

        for (int i = 0; i < taggedUserIds.length; i++) {
          fields['tagged_users_id[$i]'] = taggedUserIds[i].toString();
        }

        final response = await ApiService.postMultipart('create_post', fields, {
          'multiple_files[]': file,
        });

        if (response != null &&
            (response.statusCode == 200 || response.statusCode == 201)) {
          showCustomSnackbar(
            context,
            response.data['message'],
            type: SnackbarType.success,
          );
          searchMapName = null;
          descriptionController.clear();
          selectedImage = null;
          selectedVideo = null;
          selectedMediaType = "";
          selectedFriendIndexes.clear();
          selectedFriendList = null;
          Get.back();
        } else {
          showCustomSnackbar(
            context,
            response!.data['message'],
            type: SnackbarType.error,
          );
        }
      } else {
        showCustomSnackbar(
          context,
          type: SnackbarType.error,
          "No media selected for upload",
        );
      }
    } catch (e) {
      logger.e("Create Post Error: $e");
      showCustomSnackbar(
        context,
        "Something went wrong: $e",
        type: SnackbarType.error,
      );
    } finally {
      Get.back();
    }
  }
}
