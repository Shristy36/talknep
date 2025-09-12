import 'dart:io';
import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talknep/main.dart';
import 'package:talknep/service/api_service.dart';
import 'package:talknep/widget/app_snackbar.dart';

class BlogProvider with ChangeNotifier {
  dynamic blogData;

  final formKey = GlobalKey<FormState>();

  bool isLoading = false;
  File? selectedBlogImage;

  Map<String, dynamic>? _selectedCategoryItem;
  Map<String, dynamic>? get selectedCategoryItem => _selectedCategoryItem;

  List<dynamic> filteredBlogName = [];
  List<dynamic> _itemsSelectedBlogType = [];
  List<dynamic> get itemsSelectedBlogType => _itemsSelectedBlogType;

  TextEditingController tagController = TextEditingController();
  TextEditingController titleController = TextEditingController();
  TextEditingController searchController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  BlogProvider() {
    getBlogListData();
    getPageCategoryData();
  }

  void setSelectedBlogType(Map<String, dynamic> newValue) {
    _selectedCategoryItem = newValue;
    notifyListeners();
  }

  void setSelectedBlogImage(File image) {
    selectedBlogImage = image;
    notifyListeners();
  }

  void createBlog(context) async {
    if (formKey.currentState!.validate()) {
      try {
        isLoading = true;
        notifyListeners();
        if (selectedBlogImage != null) {
          final file = await dio.MultipartFile.fromFile(
            selectedBlogImage!.path,
            filename: selectedBlogImage!.path.split('/').last,
          );

          final response = await ApiService.postMultipart(
            'create_blogs',
            {
              'tag': tagController.text.trim(),
              'title': titleController.text.trim(),
              'category': _selectedCategoryItem?['category_id'],
              'description': descriptionController.text.trim(),
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
            Get.back();
            getBlogListData();
            tagController.clear();
            titleController.clear();
            selectedBlogImage = null;
            descriptionController.clear();
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
            "No image selected for upload",
          );
        }
      } catch (e) {
        logger.e("Create Blog Error: $e");
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

  Future getBlogListData() async {
    isLoading = true;
    notifyListeners();
    try {
      final response = await ApiService.get('blogs');
      if (response != null &&
          (response.statusCode == 201 || response.statusCode == 200)) {
        blogData = response.data;

        filteredBlogName = List.from(blogData);
      }
    } catch (e) {
      logger.e("Blog Error: $e");
    } finally {
      isLoading = false;
    }
    notifyListeners();
  }

  void filterBlogName(String query) {
    if (query.isEmpty) {
      filteredBlogName = List.from(blogData);
    } else {
      filteredBlogName =
          blogData
              .where(
                (friend) => friend['title'].toString().toLowerCase().contains(
                  query.toLowerCase(),
                ),
              )
              .toList();
    }
    notifyListeners();
  }

  void getPageCategoryData() async {
    try {
      isLoading = true;
      final response = await ApiService.get('blog_category');

      if (response != null &&
          (response.statusCode == 201 || response.statusCode == 200)) {
        _itemsSelectedBlogType = response.data;
        if (_itemsSelectedBlogType.isNotEmpty) {
          _selectedCategoryItem = _itemsSelectedBlogType[0];
        }
      }
    } catch (e) {
      logger.e("Category Error: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
