import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:talknep/main.dart';
import 'package:talknep/service/api_service.dart';
import 'package:talknep/service/astrology_service.dart';

class DashboardProvider with ChangeNotifier {
  final ScrollController scrollController = ScrollController();

  List likeCounts = [];

  int _currentPage = 1;
  bool isLoading = false;
  bool isFetchingMore = false;
  bool hasMore = true;
  List<Map<String, dynamic>> posts = [];

  DashboardProvider() {
    getTimelineListData(true);
    AstrologyService.getZodiacForToday();
    final now = DateTime.now();
    formattedDate = DateFormat('d MMMM y').format(now);
    dayName = DateFormat('EEEE').format(now);
  }

  Future scrollToTopAndRefresh() async {
    if (scrollController.hasClients) {
      scrollController.animateTo(
        0,
        curve: Curves.easeInOutCubicEmphasized,
        duration: const Duration(milliseconds: 500),
      );
    }
    await getTimelineListData(true);
  }

  Future<void> getTimelineListData(bool isRefresh) async {
    try {
      if (isRefresh) {
        isLoading = true;
        hasMore = true;
        _currentPage = 1;
        posts.clear();
        likeCounts.clear(); // Clear like counts too
        notifyListeners();
      } else {
        // Check if already fetching or no more data
        if (isFetchingMore || !hasMore) {
          return;
        }
        isFetchingMore = true;
        notifyListeners();
      }
      final response = await ApiService.get('getTimeline?page=$_currentPage');
      if (response != null &&
          (response.statusCode == 200 || response.statusCode == 201)) {
        final responseData = response.data;
        final List<dynamic> newPosts = (responseData['post'] ?? []);
        final paginationInfo = responseData['posts_pagination'];

        if (newPosts.isEmpty) {
          hasMore = false;
        } else {
          // Add new posts
          posts.addAll(newPosts.cast<Map<String, dynamic>>());

          // Add corresponding like counts
          likeCounts.addAll(
            newPosts
                .map((post) => post['likesCount'] ?? (post['total'] ?? 0))
                .toList(),
          );

          // Update pagination info
          if (paginationInfo != null) {
            final currentPage = paginationInfo['current_page'] ?? _currentPage;
            final lastPage = paginationInfo['last_page'] ?? _currentPage;
            final nextPageUrl = paginationInfo['next_page_url'];

            // Check if there's a next page
            hasMore = nextPageUrl != null && currentPage < lastPage;

            if (hasMore) {
              _currentPage++; // Increment page for next API call
            }
          } else {
            _currentPage++;
          }
        }
      } else {
        print("❌ API Error: ${response?.statusCode}");
      }
    } catch (e) {
      print("❌ Timeline Error: $e");
    } finally {
      if (isRefresh) {
        isLoading = false;
      } else {
        isFetchingMore = false;
      }
      notifyListeners();
    }
  }

  /// ---------------- LIKE / FOLLOW / UNFOLLOW -----------------

  void followUser(id, int index) async {
    try {
      final response = await ApiService.post('follow/$id', {});
      if (response != null &&
          (response.statusCode == 201 || response.statusCode == 200)) {
        posts[index]['follow'] = "Unfollow";
        notifyListeners();
      }
    } catch (e) {
      logger.e("Follow Data Error: $e");
    }
  }

  void unFollowUser(id, int index) async {
    try {
      final response = await ApiService.post('unfollow/$id', {});
      if (response != null &&
          (response.statusCode == 201 || response.statusCode == 200)) {
        posts[index]['follow'] = "Follow";
        notifyListeners();
      }
    } catch (e) {
      logger.e("unFollow Data Error: $e");
    }
  }

  void postLike({postId, postLike, index}) async {
    if (index < likeCounts.length) {
      if (postLike == 'like') {
        likeCounts[index] += 1;
      } else {
        if (likeCounts[index] > 0) {
          likeCounts[index] -= 1;
        }
      }
      notifyListeners();
    }

    try {
      await ApiService.post('reaction', {'post_id': postId, 'react': postLike});
    } catch (e) {
      logger.e("Post Like Data Error: $e");
    }
  }

  // ----- Zodiac part unchanged -----
  bool isZodiacLoading = false;
  String? selectedZodiac;
  String Zodiac = '';
  late final String formattedDate;
  late final String dayName;

  final List<Map<String, String>> rashis = [
    {'name': 'Aries', 'en': 'aries'},
    {'name': 'Taurus', 'en': 'taurus'},
    {'name': 'Gemini', 'en': 'gemini'},
    {'name': 'Cancer', 'en': 'cancer'},
    {'name': 'Leo', 'en': 'leo'},
    {'name': 'Virgo', 'en': 'virgo'},
    {'name': 'Libra', 'en': 'libra'},
    {'name': 'Scorpio', 'en': 'scorpio'},
    {'name': 'Sagittarius', 'en': 'sagittarius'},
    {'name': 'Capricorn', 'en': 'capricorn'},
    {'name': 'Aquarius', 'en': 'aquarius'},
    {'name': 'Pisces', 'en': 'pisces'},
  ];

  List<Map<String, String>> get allRashis => rashis;

  void updateSelectedZodiac(String value) {
    selectedZodiac = value;
    fetchZodiac(value);
  }

  Future<void> fetchZodiac(String sign) async {
    isZodiacLoading = true;
    Zodiac = '';
    notifyListeners();

    final url = Uri.parse(
      'https://api.api-ninjas.com/v1/horoscope?zodiac=$sign',
    );
    final response = await http.get(
      url,
      headers: {'X-Api-Key': 'dPgNbamxZXjqb7TyFDqTCA==iH6NC0m81ej6QuZw'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      Zodiac = data['horoscope'];
    } else {
      Zodiac = 'Error loading horoscope.';
    }

    isZodiacLoading = false;
    notifyListeners();
  }
}
