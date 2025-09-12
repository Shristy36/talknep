import 'dart:io';
import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:talknep/constant/app_color.dart';
import 'package:talknep/gen/assets.gen.dart';
import 'package:talknep/main.dart';
import 'package:talknep/service/api_service.dart';
import 'package:talknep/widget/app_sizer.dart';
import 'package:talknep/widget/app_snackbar.dart';
import 'package:talknep/widget/app_text.dart';
import 'package:talknep/widget/dialog_loader.dart';

class StoryProvider extends ChangeNotifier {
  File? video;
  File? selectedStoryImage;
  final picker = ImagePicker();
  bool isLoading = false; // for create story

  List<dynamic> stories = [];
  int _currentPage = 1;
  bool _isLoading = false; // for pagination loading
  bool _hasMore = true;

  bool get hasMore => _hasMore;
  bool get isFetching => _isLoading;
  List<dynamic> get allStories => stories;

  StoryProvider() {
    getStories(refresh: true);
  }

  Future<void> getStories({bool refresh = false}) async {
    try {
      if (refresh) {
        _currentPage = 1;
        _hasMore = true;
        stories.clear();
        _isLoading = true;
        notifyListeners();
      } else {
        if (_isLoading || !_hasMore) {
          return;
        }
        _isLoading = true;
        notifyListeners();
      }

      final response = await ApiService.get('getStories?page=$_currentPage');

      if (response != null &&
          (response.statusCode == 200 || response.statusCode == 201)) {
        final responseData = response.data;
        final List<dynamic> newStories = responseData['stories'] ?? [];
        final paginationInfo = responseData['stories_pagination'];

        if (newStories.isEmpty) {
          _hasMore = false;
        } else {
          // Add new stories
          stories.addAll(newStories);

          // Update pagination info using API response
          if (paginationInfo != null) {
            final currentPage = paginationInfo['current_page'] ?? _currentPage;
            final lastPage = paginationInfo['last_page'] ?? _currentPage;
            final nextPageUrl = paginationInfo['next_page_url'];

            // Check if there's a next page
            _hasMore = nextPageUrl != null && currentPage < lastPage;

            if (_hasMore) {
              _currentPage++; // Increment page for next API call
            }
          } else {
            // Fallback: if no pagination info, increment page
            _currentPage++;
          }
        }
      } else {
        print("❌ Stories API Error: ${response?.statusCode}");
        // Don't set hasMore to false on API error, might be temporary
      }
    } catch (e) {
      print("❌ GetStories Error: $e");
      logger.e("GetStories Error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ---------------- Privacy ---------------- //
  String _selectedPrivacy = 'Public';

  String get selectedPrivacy => _selectedPrivacy;

  List<String> get itemsSelectedPrivacy => ['Public', 'Friends', 'Only me'];
  void setSelectedPrivacy(String newValue) {
    _selectedPrivacy = newValue;
    notifyListeners();
  }

  // ---------------- Pick Media ---------------- //
  Future<void> pickCamera() async {
    try {
      final pickedCamera = await picker.pickImage(
        imageQuality: 90,
        requestFullMetadata: true,
        source: ImageSource.camera,
      );

      if (pickedCamera != null) {
        selectedStoryImage = File(pickedCamera.path);
        video = null;
        notifyListeners();
      }
    } catch (e) {
      debugPrint("❌ Error picking image from camera: $e");
    }
  }

  Future<void> pickImageFromGallery() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      selectedStoryImage = File(pickedFile.path);
      video = null;
      notifyListeners();
    }
  }

  Future<void> pickVideoFromGallery() async {
    final pickedVideo = await picker.pickVideo(source: ImageSource.gallery);
    if (pickedVideo != null) {
      video = File(pickedVideo.path);
      selectedStoryImage = null;
      notifyListeners();
    }
  }

  // ---------------- Create Story ---------------- //
  Future<void> createStory(BuildContext context) async {
    if (selectedStoryImage == null && video == null) {
      showCustomSnackbar(
        context,
        "Please select an image or video before sharing.",
        type: SnackbarType.error,
      );
      return;
    }

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
              text: 'Uploading...',
              fontWeight: FontWeight.w800,
              color: AppColors.whiteColor,
            ),
          ],
        ),
      );

      String contentType = "text";
      dio.MultipartFile? file;

      if (selectedStoryImage != null) {
        file = await dio.MultipartFile.fromFile(
          selectedStoryImage!.path,
          filename: selectedStoryImage!.path.split('/').last,
        );
        contentType = "file";
      } else if (video != null) {
        file = await dio.MultipartFile.fromFile(
          video!.path,
          filename: video!.path.split('/').last,
        );
        contentType = "file";
      }

      if (file != null) {
        final response = await ApiService.postMultipart(
          'create_story',
          {
            'publisher': 'user',
            'content_type': contentType,
            'privacy': _selectedPrivacy.toString(),
          },
          {'story_files[]': file},
        );
        Get.back();
        if (response != null &&
            (response.statusCode == 201 || response.statusCode == 200)) {
          final resData = response.data;
          final apiMessage = resData['message'] ?? "Something went wrong.";
          final isSuccess = resData['success'] == true;

          if (isSuccess) {
            selectedStoryImage = null;
            video = null;

            await getStories(refresh: true);
            notifyListeners();
            showCustomSnackbar(context, apiMessage, type: SnackbarType.success);
            Get.back();
          } else {
            showCustomSnackbar(context, apiMessage, type: SnackbarType.error);
          }
        } else {
          showCustomSnackbar(
            context,
            "Failed to upload story. Please try again.",
            type: SnackbarType.error,
          );
        }
      }
    } catch (e) {
      Get.back();
      logger.e("Create Story Error: $e");
      showCustomSnackbar(
        context,
        "Something went wrong: $e",
        type: SnackbarType.error,
      );
    }
  }
}
