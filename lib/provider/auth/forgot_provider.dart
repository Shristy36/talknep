import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talknep/main.dart';
import 'package:talknep/service/api_service.dart';
import 'package:talknep/UI/auth/login_screen.dart';
import 'package:talknep/widget/app_snackbar.dart';

class ForgotProvider extends ChangeNotifier {
  TextEditingController emailController = TextEditingController();
  bool isLoading = false;

  Future<void> forgotAPI(BuildContext context) async {
    final email = emailController.text.trim();

    isLoading = true;
    notifyListeners();

    if (email.isEmpty) {
      showCustomSnackbar(
        context,
        "The email field is required.",
        type: SnackbarType.error,
      );
      isLoading = false;
      notifyListeners();
      return;
    }

    if (!email.contains('@') || !email.contains('.')) {
      showCustomSnackbar(
        context,
        "Please enter a valid email address.",
        type: SnackbarType.error,
      );
      isLoading = false;
      notifyListeners();
      return;
    }

    try {
      final response = await ApiService.post('forgot_password', {
        'email': email,
      });

      if (response != null && response.statusCode == 200) {
        print("Forgot Password Response: ${response.data}");
        emailController.clear();
        Get.off(
          () => LoginScreen(),
          transition: Transition.fadeIn,
          duration: const Duration(milliseconds: 500),
        );
        showCustomSnackbar(
          context,
          response.data['message'],
          type: SnackbarType.success,
        );
      } else {
        showCustomSnackbar(
          context,
          response!.data['message'],
          type: SnackbarType.error,
        );
      }
    } catch (e) {
      logger.e("Forgot Error: $e");
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
