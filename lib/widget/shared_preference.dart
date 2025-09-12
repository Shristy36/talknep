import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> saveToken(String token) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('auth_token', token);
}

Future<String?> getToken() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('auth_token');
}

Future<void> saveAccessToken(String token) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('auth_accessToken', token);
}

Future<String?> getAccessToken() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('auth_accessToken');
}

Future<void> saveUser(Map<String, dynamic> user) async {
  final prefs = await SharedPreferences.getInstance();
  String userJson = jsonEncode(user);
  await prefs.setString("user_data", userJson);
}

Future<Map<String, dynamic>?> getUser() async {
  final prefs = await SharedPreferences.getInstance();
  String? userJson = prefs.getString("user_data");
  if (userJson == null) return null;
  return jsonDecode(userJson) as Map<String, dynamic>;
}

//How to get user data from shared preference
//final storedUser = await getUser();

Future<void> saveUserImage(String token) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('user_image', token);
}

Future<String?> getUserImage() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('user_image');
}

Future<void> saveUserCoverImage(String token) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('user_coverImage', token);
}

Future<String?> getUserCoverImage() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('user_coverImage');
}

//---------------------User ID-------------------//
Future<void> saveUserId(int userId) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setInt('user_id', userId);
}

Future<int?> getUserId() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getInt('user_id');
}

//---------------------Agora Preferences-------------------//
Future<void> saveAgoraUID(int uid) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setInt('uid', uid);
}

Future<int?> getAgoraUID() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getInt('uid');
}

Future<void> saveAgoraToken(String agoraToken) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('token', agoraToken);
}

Future<String?> getAgoraToken() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('token');
}

Future<void> saveAgoraAppID(String agoraAppID) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('appID', agoraAppID);
}

Future<String?> getAgoraAppID() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('appID');
}

Future<void> saveAgoraChannelName(String channelName) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('channelName', channelName);
}

Future<String?> getAgoraChannelName() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('channelName');
}

Future<void> saveAgoraLastCallTime(DateTime time) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('lastCallTime', time.toIso8601String());
}

Future<DateTime?> getAgoraLastCallTime() async {
  final prefs = await SharedPreferences.getInstance();
  final str = prefs.getString('lastCallTime');
  if (str != null) {
    return DateTime.tryParse(str);
  }
  return null;
}
