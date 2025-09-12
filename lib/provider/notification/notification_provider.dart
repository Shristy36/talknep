import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talknep/main.dart';
import 'package:talknep/service/api_service.dart';
import 'package:talknep/widget/app_snackbar.dart';

class NotificationProvider with ChangeNotifier {
  bool isLoading = false;
  int? lastNotificationId;
  dynamic notificationData;
  bool hasLoadedOnce = false;

  NotificationProvider() {
    notificationAPI(force: true);
  }

  Future<void> notificationAPI({bool force = false}) async {
    if (!hasLoadedOnce) {
      isLoading = true;
      notifyListeners();
    }

    try {
      final response = await ApiService.get('notifications');

      if (response != null &&
          (response.statusCode == 200 || response.statusCode == 201)) {
        final newData = response.data;

        final newFirstId =
            newData['new_notifications'].isNotEmpty
                ? newData['new_notifications'][0]['id']
                : null;

        if (lastNotificationId != null &&
            newFirstId == lastNotificationId &&
            !force) {
          print("🔁 No new notifications.");
        } else {
          notificationData = newData;
          lastNotificationId = newFirstId;
          print("✅ New notifications loaded.");
        }
      } else {
        final message =
            response?.data is Map && response?.data['message'] != null
                ? response?.data['message']
                : 'Unexpected error occurred.';
        showCustomSnackbar(Get.context!, message, type: SnackbarType.error);
      }
      notifyListeners();
    } catch (e) {
      logger.e("Notification API Error: $e");
      showCustomSnackbar(
        Get.context!,
        "Something went wrong: $e",
        type: SnackbarType.error,
      );
    } finally {
      hasLoadedOnce = true;
      isLoading = false;
      notifyListeners();
    }
    notifyListeners();
  }

  Future<void> acceptFriendRequest(dynamic id) async {
    isLoading = true;
    notifyListeners();
    try {
      final response = await ApiService.post(
        'accept_friend_notification/$id',
        {},
      );

      if (response != null &&
          (response.statusCode == 200 || response.statusCode == 201)) {
        logger.i("✅ Friend request accepted for ID: $id");

        if (notificationData != null &&
            notificationData['new_notifications'] is List) {
          notificationData['new_notifications'].removeWhere(
            (item) => item['sender_user_id'].toString() == id.toString(),
          );
        }
      } else {
        final message =
            response?.data is Map && response?.data['message'] != null
                ? response?.data['message']
                : 'Unexpected error occurred.';
        showCustomSnackbar(Get.context!, message, type: SnackbarType.error);
      }
    } catch (e) {
      logger.e("Accept Friend Request API Error: $e");
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

  Future<void> rejectFriendRequest(dynamic id) async {
    isLoading = true;
    notifyListeners();
    try {
      final response = await ApiService.post(
        'decline_friend_notification/$id',
        {},
      );
      if (response != null &&
          (response.statusCode == 200 || response.statusCode == 201)) {
        logger.i("✅ Friend request rejected for ID: $id");

        if (notificationData != null &&
            notificationData['new_notifications'] is List) {
          notificationData['new_notifications'].removeWhere(
            (item) => item['sender_user_id'].toString() == id.toString(),
          );
        }
      } else {
        final message =
            response?.data is Map && response?.data['message'] != null
                ? response?.data['message']
                : 'Unexpected error occurred.';

        showCustomSnackbar(Get.context!, message, type: SnackbarType.error);
      }
    } catch (e) {
      logger.e("Accept Friend Request API Error: $e");
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
