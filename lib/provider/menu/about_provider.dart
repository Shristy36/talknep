import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talknep/main.dart';
import 'package:talknep/service/api_service.dart';
import 'package:talknep/widget/app_snackbar.dart';

class AboutProvider with ChangeNotifier {
  bool isLoading = false;

  String? aboutData;
  String? privacyPolicyData;

  AboutProvider() {
    aboutAPI();
  }

  aboutAPI() async {
    isLoading = true;
    notifyListeners();
    try {
      final response = await ApiService.get('about_policy');

      if (response != null &&
          (response.statusCode == 200 || response.statusCode == 201)) {
        aboutData = response.data['about'];
        privacyPolicyData = response.data['policy'];
      } else {
        final message =
            response?.data is Map && response?.data['message'] != null
                ? response?.data['message']
                : 'Unexpected error occurred.';
        showCustomSnackbar(Get.context!, message, type: SnackbarType.error);
      }
    } catch (e) {
      logger.e("About API Error: $e");
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
}
