import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talknep/main.dart';
import 'package:talknep/service/api_service.dart';
import 'package:talknep/UI/bottomBar/bottom_screen.dart';
import 'package:talknep/widget/app_snackbar.dart';

class TextStoryProvider extends ChangeNotifier {
  String bgColor = "fafafa";
  String textColor = "636363";
  String privacy = "public";

  bool isLoading = false;

  TextEditingController descriptionController = TextEditingController();

  List<Map<String, dynamic>> privacyOptions = [
    {"label": "public", "icon": Icons.public},
    {"label": "friends", "icon": Icons.group},
    {"label": "only me", "icon": Icons.lock},
  ];

  void setPrivacy(String newPrivacy) {
    privacy = newPrivacy;
    notifyListeners();
  }

  void setColors({required String bg, required String text}) {
    bgColor = bg;
    textColor = text;
    notifyListeners();
  }

  addStory(context) async {
    isLoading = true;
    notifyListeners();
    try {
      final response = await ApiService.post('create_story', {
        'content_type': 'text',
        'privacy': privacy,
        'color': textColor,
        'bg-color': bgColor,
        'description': descriptionController.text,
      });

      if (response!.statusCode == 201 || response.statusCode == 200) {
        Get.offAll(
          () => BottomBarScreen(),
          transition: Transition.fadeIn,
          duration: const Duration(milliseconds: 500),
        );
        descriptionController.clear();
      }
    } catch (e) {
      logger.e("Create Story Place Error: $e");
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

  void clear() {
    descriptionController.clear();
    bgColor = "fafafa";
    textColor = "636363";
    privacy = "public";
    notifyListeners();
  }
}
