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

class VideoProvider extends ChangeNotifier {
  File? video;
  File? selectedGroupImage;
  final picker = ImagePicker();
  String _selectedPrivacy = 'Public';
  String _selectedCategory = 'video';
  bool isLoading = false;
  dynamic videosListData;
  bool isRefreshing = false;
  TextEditingController titleController = TextEditingController();

  String get selectedPrivacy => _selectedPrivacy;

  String get selectedCategory => _selectedCategory;

  VideoProvider() {
    getVideoListData(true);
  }

  void setSelectedGroupImage(File image) {
    selectedGroupImage = image;
    notifyListeners();
  }

  Future<void> pickVideoFromGallery() async {
    final pickedVideo = await picker.pickVideo(source: ImageSource.gallery);
    if (pickedVideo != null) {
      video = File(pickedVideo.path);
      notifyListeners();
    }
  }

  void removeSelectedVideo() {
    video = null;
    notifyListeners();
  }

  void setSelectedPrivacy(String newValue) {
    _selectedPrivacy = newValue;
    notifyListeners();
  }

  void setSelectedCategory(String newValue) {
    _selectedCategory = newValue;
    notifyListeners();
  }

  List<String> get itemsSelectedPrivacy => ['Public', 'Private'];

  List<String> get itemsSelectedCategory => ['video', 'shorts'];

  Future<void> getVideoListData(bool isLoader) async {
    if (isLoader) {
      isLoading = true;
      notifyListeners();
    } else {
      isRefreshing = true;
      notifyListeners();
    }
    if (hasListeners) notifyListeners();

    try {
      final response = await ApiService.get('videos');

      if (response != null &&
          (response.statusCode == 201 || response.statusCode == 200)) {
        List<dynamic> allVideos = response.data ?? [];

        videosListData =
            allVideos.where((item) {
              final category =
                  item['category']?.toString().trim().toLowerCase();
              final fileUrl = item['file']?.toString().trim().toLowerCase();
              return category == 'video' &&
                  fileUrl != null &&
                  fileUrl.endsWith('.mp4');
            }).toList();

        if (hasListeners) notifyListeners();
      }
    } catch (e) {
      logger.e("Videos Error: $e");
    } finally {
      isLoading = false;
      isRefreshing = false;
      if (hasListeners) notifyListeners();
    }
    notifyListeners();
  }

  void createVideos(context) async {
    try {
      final errors = {
        titleController.text.trim().isEmpty: "Please enter a title",
        video == null: "Please select a video",
      };
      final firstError = errors.entries.firstWhere(
        (entry) => entry.key,
        orElse: () => const MapEntry(false, ""),
      );
      if (firstError.key) {
        showCustomSnackbar(context, firstError.value, type: SnackbarType.error);
        return;
      }
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
      dio.MultipartFile? videosFile;
      dio.MultipartFile? imagesFile;
      notifyListeners();

      if (video != null) {
        videosFile = await dio.MultipartFile.fromFile(
          video!.path,
          filename: video!.path.split('/').last,
        );
      }

      if (selectedGroupImage != null) {
        imagesFile = await dio.MultipartFile.fromFile(
          selectedGroupImage!.path,
          filename: selectedGroupImage!.path.split('/').last,
        );
      }

      if (videosFile != null || imagesFile != null) {
        final response = await ApiService.postMultipart(
          'create_videos',
          {
            'title': titleController.text,
            'privacy': _selectedPrivacy,
            'category': _selectedCategory,
          },
          {
            'video': videosFile!,
            'mobile_app_image': imagesFile ?? dio.MultipartFile.fromString(''),
          },
        );
        if (response!.statusCode == 201 || response.statusCode == 200) {
          getVideoListData(true);
          showCustomSnackbar(
            context,
            response.data['message'],
            type: SnackbarType.success,
          );
          selectedGroupImage = null;
          video = null;
          titleController.clear();
          notifyListeners();
          Get.back();
          Get.back();
        } else {
          showCustomSnackbar(
            context,
            response.data['message'],
            type: SnackbarType.error,
          );
        }
      }
    } catch (e) {
      logger.e("Create Videos Error: $e");
      showCustomSnackbar(
        context,
        "Something went wrong: $e",
        type: SnackbarType.error,
      );
      Get.back();
    }
  }

  Future<void> followUser(id) async {
    try {
      isLoading = true;
      final response = await ApiService.post('follow/$id', {});
      if (response != null &&
          (response.statusCode == 201 || response.statusCode == 200)) {
        getVideoListData(false);
        notifyListeners();
      }
    } catch (e) {
      logger.e("Follow Data Error: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> unFollowUser(id) async {
    try {
      isLoading = true;
      final response = await ApiService.post('unfollow/$id', {});
      if (response != null &&
          (response.statusCode == 201 || response.statusCode == 200)) {
        getVideoListData(false);
        notifyListeners();
      }
    } catch (e) {
      logger.e("unFollow Data Error: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void postLike(postId, postLike) async {
    try {
      isLoading = true;
      final response = await ApiService.post('reaction', {
        'post_id': postId,
        'react': postLike,
      });
      if (response != null &&
          (response.statusCode == 201 || response.statusCode == 200)) {
        getVideoListData(false);
      }
    } catch (e) {
      logger.e("Post Like Data Error: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
