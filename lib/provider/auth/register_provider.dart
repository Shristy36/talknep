import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talknep/main.dart';
import 'package:talknep/service/api_service.dart';
import 'package:talknep/UI/auth/login_screen.dart';
import 'package:talknep/widget/app_snackbar.dart';

class RegisterProvider extends ChangeNotifier {
  TextEditingController usernameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  bool isLoading = false;

  Future<void> registerAPI(BuildContext context) async {
    final userName = usernameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

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

    if (password.isEmpty) {
      showCustomSnackbar(
        context,
        "The password field is required.",
        type: SnackbarType.error,
      );
      isLoading = false;
      notifyListeners();
      return;
    }

    if (confirmPassword.isEmpty) {
      showCustomSnackbar(
        context,
        "The confirm password field is required.",
        type: SnackbarType.error,
      );
      isLoading = false;
      notifyListeners();
      return;
    }

    if (password != confirmPassword) {
      showCustomSnackbar(
        context,
        "Passwords do not match.",
        type: SnackbarType.error,
      );
      isLoading = false;
      notifyListeners();
      return;
    }

    try {
      final response = await ApiService.post('signup', {
        'name': userName,
        'email': email,
        'password': password,
        'password_confirmation': confirmPassword,
      });

      final responseData =
          response?.data is String
              ? jsonDecode(response!.data)
              : response?.data;

      if (responseData['success'] == true) {
        showCustomSnackbar(
          context,
          responseData['message'],
          type: SnackbarType.success,
        );
        usernameController.clear();
        emailController.clear();
        passwordController.clear();
        confirmPasswordController.clear();
        Get.off(
          () => LoginScreen(),
          transition: Transition.fadeIn,
          duration: const Duration(milliseconds: 500),
        );
      } else {
        final validationErrors = responseData['validationError'];
        String firstError = "Something went wrong";

        if (validationErrors is Map<String, dynamic>) {
          for (var entry in validationErrors.entries) {
            if (entry.value is List && entry.value.isNotEmpty) {
              firstError = entry.value[0];
              break;
            }
          }
        }

        showCustomSnackbar(context, firstError, type: SnackbarType.error);
      }
    } catch (e) {
      logger.e("Register Error: ${e.toString()}");
      showCustomSnackbar(context, e.toString(), type: SnackbarType.error);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
