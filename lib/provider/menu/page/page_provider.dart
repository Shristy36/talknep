import 'dart:io';
import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talknep/service/api_service.dart';
import 'package:talknep/UI/menu/page/pages_screen.dart';
import 'package:talknep/widget/app_snackbar.dart';
import 'package:talknep/main.dart';

class PageProvider with ChangeNotifier {
  dynamic pageListData;

  bool isLiked = false;
  bool isLoading = false;
  bool isCreatePage = false;

  File? selectedPageImage;
  File? selectedUserCoverImage;

  List<dynamic> myPages = [];
  List<dynamic> likedPages = [];
  List<dynamic> suggestedPages = [];

  final formKey = GlobalKey<FormState>();

  Map<String, dynamic>? _selectedCategoryItem;
  List<dynamic> _itemsSelectedCategoryType = [];
  Map<String, dynamic>? get selectedCategoryItem => _selectedCategoryItem;
  List<dynamic> get itemsSelectedCategoryType => _itemsSelectedCategoryType;

  TextEditingController nameController = TextEditingController();
  TextEditingController aboutController = TextEditingController();

  PageProvider() {
    getPageListData(true);
    getPageCategoryData();
  }

  void setSelectedPageType(Map<String, dynamic> newValue) {
    _selectedCategoryItem = newValue;
    notifyListeners();
  }

  void setSelectedPageImage(File image) {
    selectedPageImage = image;
    notifyListeners();
  }

  void setSelectedPageCoverImage(File image) {
    selectedUserCoverImage = image;
    notifyListeners();
  }

  void createPage(context) async {
    isCreatePage = true;
    notifyListeners();
    if (formKey.currentState!.validate()) {
      try {
        if (selectedPageImage != null) {
          final file = await dio.MultipartFile.fromFile(
            selectedPageImage!.path,
            filename: selectedPageImage!.path.split('/').last,
          );

          final coverImage = await dio.MultipartFile.fromFile(
            selectedUserCoverImage!.path,
            filename: selectedUserCoverImage!.path.split('/').last,
          );

          final response = await ApiService.postMultipart(
            'pages_create',
            {
              'name': nameController.text,
              'description': aboutController.text.trim(),
              'category': _selectedCategoryItem?['category_id'],
            },
            {'image': file, 'cover_image': coverImage},
          );

          if (response != null &&
              (response.statusCode == 201 || response.statusCode == 200)) {
            showCustomSnackbar(
              context,
              response.data['message'],
              type: SnackbarType.success,
            );
            nameController.clear();
            aboutController.clear();
            selectedPageImage = null;
            getPageListData(true);
            Get.to(
              () => PagesScreen(),
              transition: Transition.fadeIn,
              duration: const Duration(milliseconds: 500),
            );
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
            "No image selected for upload.",
            type: SnackbarType.error,
          );
        }
      } catch (e) {
        logger.e("Create Page Error: $e");
        showCustomSnackbar(
          context,
          "Something went wrong: $e",
          type: SnackbarType.error,
        );
      } finally {
        isCreatePage = false;
        notifyListeners();
      }
    }
  }

  void updateCoverPhoto(context, id) async {
    isLoading = true;
    try {
      if (selectedUserCoverImage != null) {
        final file = await dio.MultipartFile.fromFile(
          selectedUserCoverImage!.path,
          filename: selectedUserCoverImage!.path.split('/').last,
        );

        final response = await ApiService.postMultipart(
          'update_page_coverphoto/$id',
          {},
          {'cover_photo': file},
        );

        if (response != null &&
            (response.statusCode == 201 || response.statusCode == 200)) {
          showCustomSnackbar(
            context,
            response.data['message'],
            type: SnackbarType.success,
          );
          selectedUserCoverImage = null;
          getPageListData(true);
          Get.to(
            () => PagesScreen(),
            transition: Transition.fadeIn,
            duration: const Duration(milliseconds: 500),
          );
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
          "No image selected for upload.",
          type: SnackbarType.error,
        );
        logger.w("⚠️ No image selected for upload.");
      }
    } catch (e) {
      logger.e("Create Page Error: $e");
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

  void updatePage(context, id) async {
    isLoading = true;
    try {
      if (selectedPageImage != null) {
        final file = await dio.MultipartFile.fromFile(
          selectedPageImage!.path,
          filename: selectedPageImage!.path.split('/').last,
        );

        final response = await ApiService.postMultipart(
          'pages_update/$id',
          {
            'name': nameController.text,
            'category': _selectedCategoryItem?['category_id'],
            'description': aboutController.text.trim(),
          },
          {'image': file},
        );

        if (response != null &&
            (response.statusCode == 201 || response.statusCode == 200)) {
          showCustomSnackbar(
            context,
            response.data['message'],
            type: SnackbarType.success,
          );
          nameController.clear();
          aboutController.clear();
          selectedPageImage = null;
          getPageListData(true);
          Get.to(
            () => PagesScreen(),
            transition: Transition.fadeIn,
            duration: const Duration(milliseconds: 500),
          );
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
          "No image selected for upload.",
          type: SnackbarType.error,
        );
        logger.w("⚠️ No image selected for upload.");
      }
    } catch (e) {
      logger.e("Update Page Error: $e");
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

  void pageLikedAPI(context, id) async {
    try {
      final response = await ApiService.post('page_like/$id', {});

      if (response != null &&
          (response.statusCode == 201 || response.statusCode == 200)) {
        getPageListData(false);
      } else {
        showCustomSnackbar(
          context,
          response!.data['message'],
          type: SnackbarType.error,
        );
      }
    } catch (e) {
      logger.e("Page Liked Error: $e");
      showCustomSnackbar(
        context,
        "Something went wrong: $e",
        type: SnackbarType.error,
      );
    } finally {
      notifyListeners();
    }
  }

  void pageDisLikedAPI(context, id) async {
    try {
      final response = await ApiService.post('page_dislike/$id', {});
      if (response != null &&
          (response.statusCode == 201 || response.statusCode == 200)) {
        getPageListData(false);
      } else {
        showCustomSnackbar(
          context,
          response!.data['message'],
          type: SnackbarType.error,
        );
      }
    } catch (e) {
      logger.e("Page DisLiked Error: $e");
      showCustomSnackbar(
        context,
        "Something went wrong: $e",
        type: SnackbarType.error,
      );
    } finally {
      notifyListeners();
    }
  }

  Future getPageListData(bool isRefresh) async {
    try {
      if (isRefresh) {
        isLoading = true;
        notifyListeners();
      }
      final response = await ApiService.get('pages');
      if (response != null &&
          (response.statusCode == 201 || response.statusCode == 200)) {
        pageListData = response.data;
        pageListData = response.data;
        myPages =
            pageListData.where((page) => page['my_page'] == 'my_page').toList();
        suggestedPages =
            pageListData
                .where((page) => page['is_Liked'] == 'Suggested')
                .toList();
        likedPages =
            pageListData.where((page) => page['is_Liked'] == 'Liked').toList();
      }
    } catch (e) {
      logger.e("Login Error: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void getPageCategoryData() async {
    try {
      final response = await ApiService.get('page_category');
      if (response != null &&
          (response.statusCode == 201 || response.statusCode == 200)) {
        _itemsSelectedCategoryType = response.data;
        if (_itemsSelectedCategoryType.isNotEmpty) {
          _selectedCategoryItem = _itemsSelectedCategoryType[0];
        }
      }
    } catch (e) {
      logger.e("Category Error: $e");
    }
    notifyListeners();
  }
}
