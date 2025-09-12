import 'package:talknep/widget/shared_preference.dart';

class Global {
  static int? uid;
  static String? token;
  static String? FCMToken;
  static bool isEnglish = false;
  static dynamic userProfileData;
  static String? userImage =
      "https://www.shutterstock.com/image-vector/vector-design-avatar-dummy-sign-600nw-1290556063.jpg";
  static String? userCoverImage;

  static userProfile() async {
    userProfileData = await getUser();
    userImage = await getUserImage();
    uid = await getUserId();
    userCoverImage = await getUserCoverImage();
  }
}
