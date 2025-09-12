import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:talknep/UI/bottomBar/bottom_screen.dart';
import 'package:talknep/constant/global.dart';
import 'package:talknep/main.dart';
import 'package:talknep/provider/bottomBar/bottomBar_provider.dart';
import 'package:talknep/service/api_service.dart';
import 'package:talknep/widget/app_snackbar.dart';
import 'package:talknep/widget/shared_preference.dart';

class LoginProvider extends ChangeNotifier {
  bool isLoading = false;
  bool rememberMe = false;
  bool isGoogleLoading = false;
  final FirebaseAuth auth = FirebaseAuth.instance;
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  void toggleRememberMe() {
    rememberMe = !rememberMe;
    notifyListeners();
  }

  final GoogleSignIn googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);

  /* final GoogleSignIn googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
    clientId:
        kDebugMode
            ?
            // debug clientId:
            '96604115475-3cdhbnpipfaegkv0dghtgsjpq6fl4b56.apps.googleusercontent.com'
            :
            // release
            '96604115475-asuum7ik5gu31dvo0jvn1vv4kf7g6466.apps.googleusercontent.com',
  ); */

  Future<void> loginAPI(BuildContext context) async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    isLoading = true;
    notifyListeners();

    if (email.isEmpty) {
      showCustomSnackbar(
        context,
        type: SnackbarType.error,
        "The email field is required.",
      );
      isLoading = false;
      notifyListeners();
      return;
    }

    if (!email.contains('@') || !email.contains('.')) {
      showCustomSnackbar(
        context,
        type: SnackbarType.error,
        "Please enter a valid email address.",
      );
      isLoading = false;
      notifyListeners();
      return;
    }

    // Password validation
    if (password.isEmpty) {
      showCustomSnackbar(
        context,
        type: SnackbarType.error,
        "The password field is required.",
      );
      isLoading = false;
      notifyListeners();
      return;
    }

    try {
      final response = await ApiService.post('login', {
        'email': email,
        'password': password,
      });

      if (response != null && response.statusCode == 201) {
        final token = response.data["token"];

        ApiService.setToken(token);
        saveToken(token);
        saveUser(response.data['user']);
        saveUserId(response.data['user']['id']);
        saveUserImage(response.data['user_image']);
        saveUserCoverImage(response.data['cover_photo']);
        //Save FCM Token From
        await ApiService.post('/fcm/save', {'token': Global.FCMToken});

        showCustomSnackbar(
          context,
          response.data['message'],
          type: SnackbarType.success,
        );

        Global.userProfile();
        emailController.clear();
        passwordController.clear();

        final bottomBarProvider = Provider.of<BottomBarProvider>(
          context,
          listen: false,
        );
        bottomBarProvider.changeIndex(context, 0);
        Get.off(
          () => BottomBarScreen(),
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

  Future<void> signInWithGoogle(BuildContext context) async {
    isGoogleLoading = true;
    notifyListeners();

    try {
      // Trigger Google Sign-In flow
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        isGoogleLoading = false;
        notifyListeners();
        print('Sign-in aborted by user');
        return;
      }

      // Obtain authentication details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // ✅ Create Firebase credential
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // ✅ Sign in to Firebase
      final UserCredential userCredential = await auth.signInWithCredential(
        credential,
      );

      final User? firebaseUser = userCredential.user;
      if (firebaseUser == null) {
        throw FirebaseAuthException(
          code: 'ERROR_MISSING_USER',
          message: 'No user returned from Firebase',
        );
      } else {
        print(
          'Firebase User: ${firebaseUser.displayName}, Email: ${firebaseUser.email}',
        );
      }

      await sendGoogleDataToBackend(context, googleUser, googleAuth);
    } catch (error) {
      logger.e("Google Sign-In Error: $error");
      showCustomSnackbar(
        context,
        "Google Sign-In failed: $error",
        type: SnackbarType.error,
      );
    } finally {
      isGoogleLoading = false;
      notifyListeners();
    }
  }

  Future<void> sendGoogleDataToBackend(
    BuildContext context,
    GoogleSignInAccount googleUser,
    GoogleSignInAuthentication googleAuth,
  ) async {
    try {
      final response = await ApiService.post('auth/google/callback', {
        'access_token': googleAuth.accessToken,
      });

      if (response != null &&
          (response.statusCode == 200 || response.statusCode == 201)) {
        final token = response.data["token"];

        ApiService.setToken(token);

        saveToken(token);

        saveUser(response.data['user']);

        // Handle Google response structure with null safety
        final userPhoto =
            response.data['user']?['photo']?.toString() ?? googleUser.photoUrl;

        final coverPhoto = response.data['user']?['cover_photo']?.toString();

        saveUserId(response.data['user']['id']);

        await ApiService.post('/fcm/save', {'token': Global.FCMToken});

        // Only save if not null
        if (userPhoto != null) {
          saveUserImage(userPhoto);
        }
        if (coverPhoto != null) {
          saveUserCoverImage(coverPhoto);
        }

        showCustomSnackbar(
          context,
          response.data['message'] ?? "Google login successful!",
          type: SnackbarType.success,
        );

        Global.userProfile();

        // Navigate to main screen
        Get.off(
          () => BottomBarScreen(),
          transition: Transition.fadeIn,
          duration: const Duration(milliseconds: 500),
        );
      } else {
        showCustomSnackbar(
          context,
          response?.data['message'] ?? "Google login failed",
          type: SnackbarType.error,
        );
        print('Google Backend Error: ${response?.data}');
      }
    } catch (e) {
      logger.e("Google callback error: $e");
      showCustomSnackbar(
        context,
        "Google login failed: $e",
        type: SnackbarType.error,
      );
    }
  }

  // Add these methods when Firebase is properly setup
  Stream<User?> get authStateChanges => auth.authStateChanges();
  User? get currentUser => auth.currentUser;
}
