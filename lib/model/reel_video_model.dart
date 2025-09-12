class VideoModel {
  final String videourl;
  final String profilePic;
  final String title;
  final String username;
  final Map<String, dynamic> reactionCounts;
  final int commentsCount;
  final String? userReaction;
  final List<dynamic> taggedUserList;
  final int postId;
  final int userId;

  VideoModel({
    required this.videourl,
    required this.profilePic,
    required this.title,
    required this.username,
    required this.reactionCounts,
    required this.commentsCount,
    required this.userReaction,
    required this.taggedUserList,
    required this.postId,
    required this.userId,
  });

  factory VideoModel.fromJson(Map<String, dynamic> json) {
    return VideoModel(
      videourl: json['file'] ?? '',
      profilePic: json['photo'] ?? '',
      title: json['title'] ?? '',
      username: json['name'] ?? '',
      reactionCounts: json['reaction_counts'] ?? {'like': 0},
      commentsCount: json['comments_count'] ?? 0,
      userReaction: json['userReaction'],
      taggedUserList: json['taggedUserList'] ?? [],
      postId: json['post_id'] ?? 0,
      userId: json['user_id'] ?? 0,
    );
  }
}
