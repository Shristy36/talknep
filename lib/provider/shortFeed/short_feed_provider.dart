import 'package:flutter/material.dart';
import 'package:talknep/model/reel_video_model.dart';
import 'package:talknep/service/api_service.dart';

class ShortFeedProvider with ChangeNotifier {
  bool _isLoading = false;
  List<VideoModel> _videos = [];
  int _currentIndex = 0;

  List<VideoModel> get videos => _videos;
  bool get isLoading => _isLoading;
  int get currentIndex => _currentIndex;

  ShortFeedProvider() {
    fetchVideos();
  }

  void setCurrentIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }

  Future<void> fetchVideos() async {
    _isLoading = true;

    notifyListeners();

    final response = await ApiService.get('/videos');

    if (response != null &&
        (response.statusCode == 201 || response.statusCode == 200)) {
      final List<dynamic> jsonData = response.data;

      _videos =
          jsonData
              .where((item) => item['category'] == 'shorts')
              .map((item) => VideoModel.fromJson(item))
              .toList();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> toggleLike(VideoModel video) async {
    final index = _videos.indexWhere((v) => v.postId == video.postId);

    if (index == -1) return;

    final current = _videos[index];
    final isLiked = current.userReaction == 'like';
    final updatedReactions = Map<String, dynamic>.from(current.reactionCounts);

    updatedReactions['like'] =
        isLiked
            ? (updatedReactions['like'] ?? 1) - 1
            : (updatedReactions['like'] ?? 0) + 1;

    _videos[index] = VideoModel(
      title: current.title,
      postId: current.postId,
      userId: current.userId,
      username: current.username,
      videourl: current.videourl,
      profilePic: current.profilePic,
      reactionCounts: updatedReactions,
      commentsCount: current.commentsCount,
      userReaction: isLiked ? null : 'like',
      taggedUserList: current.taggedUserList,
    );

    notifyListeners();

    await ApiService.post('/reaction', {
      'post_id': current.postId,
      'react': isLiked ? '' : 'like',
    });
  }
}
