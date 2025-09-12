import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:talknep/main.dart';
import 'package:talknep/service/api_service.dart';
import 'package:talknep/widget/app_snackbar.dart';

dynamic anotherUserProfileId;

class AnotherUserProfileProvider with ChangeNotifier {
  bool isLoading = false;

  Map<String, dynamic> anotherUserProfileData = {};

  Future<void> userProfileDetails() async {
    isLoading = true;
    notifyListeners();
    try {
      final response = await ApiService.get(
        'other_profile/$anotherUserProfileId',
      );

      if (response != null &&
          (response.statusCode == 200 || response.statusCode == 201)) {
        anotherUserProfileData = response.data ?? {};
      } else {
        final message =
            response?.data is Map && response?.data['message'] != null
                ? response?.data['message']
                : 'Unexpected error occurred.';
        showCustomSnackbar(Get.context!, message, type: SnackbarType.error);

        anotherUserProfileData = {};
      }
    } catch (e) {
      logger.e("Another User Profile Data: $e");
      showCustomSnackbar(
        Get.context!,
        "Something went wrong: $e",
        type: SnackbarType.error,
      );

      anotherUserProfileData = {};
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
