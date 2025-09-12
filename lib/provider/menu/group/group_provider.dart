import 'dart:io';
import 'package:dio/dio.dart' as dio show MultipartFile;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talknep/service/api_service.dart';
import 'package:talknep/UI/menu/group/group_details_screen.dart';
import 'package:talknep/UI/menu/group/group_screen.dart';
import 'package:talknep/widget/app_snackbar.dart';
import '../../../main.dart';

class GroupProvider with ChangeNotifier {
  final TextEditingController searchController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController subtitleController = TextEditingController();
  final TextEditingController aboutController = TextEditingController();
  final FocusNode focusNode = FocusNode();
  String _selectedStatus = 'Active';
  String _selectedPrivacy = 'Public';
  bool isLoading = false;
  File? selectedGroupImage;
  dynamic groupData;
  List<dynamic> filteredGroupName = [];
  String? coverImageUrl;

  String get selectedStatus => _selectedStatus;
  String get selectedPrivacy => _selectedPrivacy;

  GroupProvider() {
    getGroupsListData();
  }

  void setSelectedStatus(String newValue) {
    _selectedStatus = newValue;
    notifyListeners();
  }

  void setSelectedPrivacy(String newValue) {
    _selectedPrivacy = newValue;
    notifyListeners();
  }

  void setSelectedGroupImage(File image) {
    selectedGroupImage = image;
    notifyListeners();
  }

  List<String> get itemsSelectedStatus => ['Active', 'Deactivate'];

  List<String> get itemsSelectedPrivacy => ['Public', 'Private'];

  createGroup(context) async {
    try {
      isLoading = true;
      if (selectedGroupImage != null) {
        final file = await dio.MultipartFile.fromFile(
          selectedGroupImage!.path,
          filename: selectedGroupImage!.path.split('/').last,
        );

        final response = await ApiService.postMultipart(
          'create_group',
          {
            'name': nameController.text,
            'subtitle': subtitleController.text.trim(),
            'about': aboutController.text.trim(),
            'privacy': _selectedPrivacy,
            'status': _selectedStatus,
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
          subtitleController.clear();
          aboutController.clear();
          selectedGroupImage = null;

          Get.to(
            () => GroupScreen(),
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
      logger.e("Login Error: $e");
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

  getGroupsListData() async {
    try {
      isLoading = true;
      notifyListeners();
      final response = await ApiService.get('groups');
      if (response != null &&
          (response.statusCode == 201 || response.statusCode == 200)) {
        groupData = response.data;
        filteredGroupName = List.from(groupData);
      }
    } catch (e) {
      logger.e("Login Error: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  getGroupsRemoveData(id) async {
    try {
      isLoading = true;
      final response = await ApiService.post('groups_join_remove/$id', {});

      if (response != null &&
          (response.statusCode == 201 || response.statusCode == 200)) {
        getGroupsListData();
        Get.back();
        notifyListeners();
      }
    } catch (e) {
      logger.e("Group Leave Error: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  getGroupsJoinData(id) async {
    try {
      isLoading = true;
      final response = await ApiService.post('groups_join/$id', {});

      if (response != null &&
          (response.statusCode == 201 || response.statusCode == 200)) {
        getGroupsListData();
      }
    } catch (e) {
      logger.e("Group Leave Error: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void filterGroupName(String query) {
    if (query.isEmpty) {
      filteredGroupName = List.from(groupData);
    } else {
      filteredGroupName =
          groupData
              .where(
                (friend) => friend['title'].toString().toLowerCase().contains(
                  query.toLowerCase(),
                ),
              )
              .toList();
    }
    notifyListeners();
  }

  getGroupDetails() async {
    try {
      isLoading = true;
      final response = await ApiService.get('groups_details/$groupDetailsId');

      if (response != null &&
          (response.statusCode == 201 || response.statusCode == 200)) {
        nameController.text = response.data['title'];
        subtitleController.text = response.data['subtitle'];
        aboutController.text = response.data['about'];
        coverImageUrl = response.data['logo'];
        _selectedStatus =
            (response.data['status'] ?? '').toString().toLowerCase() ==
                    'deactivate'
                ? 'Deactivate'
                : 'Active';

        _selectedPrivacy =
            (response.data['privacy'] ?? '').toString().toLowerCase() ==
                    'private'
                ? 'Private'
                : 'Public';
      }
    } catch (e) {
      logger.e("Login Error: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  updateGroup(context) async {
    try {
      isLoading = true;
      if (selectedGroupImage != null) {
        final file = await dio.MultipartFile.fromFile(
          selectedGroupImage!.path,
          filename: selectedGroupImage!.path.split('/').last,
        );

        final response = await ApiService.postMultipart(
          'update_group/$groupDetailsId',
          {
            'name': nameController.text,
            'subtitle': subtitleController.text.trim(),
            'about': aboutController.text.trim(),
            'privacy': _selectedPrivacy,
            'status': _selectedStatus,
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
          subtitleController.clear();
          aboutController.clear();
          selectedGroupImage = null;
          getGroupsListData();
          Get.off(
            () => GroupScreen(),
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
        logger.w("⚠️ No image selected for upload.");
      }
    } catch (e) {
      logger.e("Login Error: $e");
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
