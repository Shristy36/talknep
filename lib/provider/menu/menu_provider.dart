import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talknep/constant/global.dart';
import 'package:talknep/gen/assets.gen.dart';
import 'package:talknep/UI/auth/login_screen.dart';

class MenuProvider with ChangeNotifier {
  List menuList = [
    {"height": 30, "Image": Assets.icon.icTimeline.path, "Title": "Timeline"},
    {"height": 30, "Image": Assets.icon.icUser.path, "Title": "Profile"},
    {"height": 40, "Image": Assets.icon.icGroups.path, "Title": "Group"},
    {"height": 40, "Image": Assets.icon.icFlag.path, "Title": "Page"},
    {"height": 30, "Image": Assets.icon.icMarket.path, "Title": "Marketplace"},
    {
      "height": 25,
      "Title": "Video & Shorts",
      "Image": Assets.icon.icMedia.path,
    },
    {"height": 30, "Image": Assets.icon.icEvents.path, "Title": "Event"},
    {"height": 30, "Image": Assets.icon.icBlog.path, "Title": "Blog"},
  ];

  void logout(BuildContext context) async {
    final FirebaseAuth auth = FirebaseAuth.instance;

    final GoogleSignIn googleSignIn = GoogleSignIn(
      scopes: ['email', 'profile'],
    );

    await auth.signOut();
    await googleSignIn.signOut();

    Get.off(
      () => LoginScreen(),
      transition: Transition.fadeIn,
      duration: const Duration(milliseconds: 500),
    );
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();
    Global.userImage = null;
    Global.userCoverImage = null;
    Global.userProfileData = null;
  }
}
