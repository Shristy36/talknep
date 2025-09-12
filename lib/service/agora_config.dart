import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:talknep/service/api_service.dart';
import 'package:talknep/widget/shared_preference.dart';

class AgoraConfig {
  static int? uid;
  static String? appId;
  static String? token;
  static String? channelName;

  static agoraCredential() async {
    uid = await getAgoraUID();
    appId = await getAgoraAppID();
    token = await getAgoraToken();
    channelName = await getAgoraChannelName();
  }
}

class AgoraResponse extends ChangeNotifier {
  static final AgoraResponse _instance = AgoraResponse._internal();

  factory AgoraResponse() => _instance;

  AgoraResponse._internal();

  int? uid;
  String? token;
  String? appId;
  String? channelName;
  DateTime? lastCallTime;

  final logger = Logger();

  /// Load saved values on init
  Future<void> init() async {
    uid = await getAgoraUID();
    token = await getAgoraToken();
    appId = await getAgoraAppID();
    channelName = await getAgoraChannelName();
    lastCallTime = await getAgoraLastCallTime();
  }

  /// Fetch token only if 24 hours passed
  Future<void> fetchAgoraTokenIfNeeded() async {
    final now = DateTime.now();

    if (lastCallTime != null) {
      final diff = now.difference(lastCallTime!).inHours;
      if (diff < 24) {
        logger.i("⏳ Token still valid, last call $diff hours ago.");
        return;
      }
    }
    await _fetchAgoraToken();
  }

  /// Actual API call
  Future<void> _fetchAgoraToken() async {
    try {
      final response = await ApiService.post('generateToken', {
        'channelName': 'demo-room-1',
      });

      if (response != null && response.statusCode == 200) {
        uid = response.data['uid'];
        token = response.data['token'];
        appId = response.data['appID'];
        channelName = response.data['channelName'];

        // save locally
        if (uid != null) saveAgoraUID(uid!);
        if (token != null) saveAgoraToken(token!);
        if (appId != null) saveAgoraAppID(appId!);
        if (channelName != null) saveAgoraChannelName(channelName!);

        lastCallTime = DateTime.now();
        saveAgoraLastCallTime(lastCallTime!);

        notifyListeners();
        logger.i("✅ Agora token updated successfully.");
      } else {
        logger.e("❌ Failed to get Agora token: ${response?.data}");
      }
    } catch (e) {
      logger.e("❌ Exception in fetchAgoraToken: $e");
    }
  }
}
