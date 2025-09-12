import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:talknep/UI/dashboard/dashboard_screen.dart';
import 'package:talknep/UI/market%20place/market_place_screen.dart';
import 'package:talknep/UI/menu/menu_screen.dart';
import 'package:talknep/UI/notification/notification_screen.dart';
import 'package:talknep/UI/reel%20videos/short_feed_screen.dart';
import 'package:talknep/UI/video/video_screen.dart';
import 'package:talknep/provider/dashboard/dashboard_provider.dart';
import 'package:talknep/util/check_connectively.dart';

class BottomBarProvider with ChangeNotifier {
  int _currentIndex = 0;

  DateTime? lastTapTime;

  int get currentIndex => _currentIndex;

  bool _isVisible = true;

  bool get isVisible => _isVisible;

  final List pages = [
    DashboardScreen(),
    ShortFeedScreen(),
    VideoScreen(),
    MarketPlaceScreen(),
    NotificationScreen(),
    MenuScreen(),
  ];

  void changeIndex(BuildContext context, int newIndex) {
    DateTime now = DateTime.now();

    checkInternetConnection(
      onConnected: () {
        if (_currentIndex == newIndex &&
            lastTapTime != null &&
            now.difference(lastTapTime!) < const Duration(milliseconds: 300)) {
          if (newIndex == 0) {
            context.read<DashboardProvider>().scrollToTopAndRefresh();
          }
        }
        lastTapTime = now;

        if (_currentIndex != newIndex) {
          _currentIndex = newIndex;
          notifyListeners();
        }
      },
    );
  }
}
