import 'package:flutter/material.dart';
import 'package:flutter_advanced_avatar/flutter_advanced_avatar.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:talknep/UI/dashboard/components/comment_bottom_sheet.dart';
import 'package:talknep/constant/app_color.dart';
import 'package:talknep/model/reel_video_model.dart';
import 'package:talknep/provider/shortFeed/short_feed_provider.dart';
import 'package:talknep/util/theme_extension.dart';
import 'package:talknep/widget/app_loader.dart';
import 'package:talknep/widget/app_shared.dart';
import 'package:talknep/widget/app_sizer.dart';
import 'package:talknep/widget/app_text.dart';
import 'package:video_player/video_player.dart';

class VideoCard extends StatefulWidget {
  final VideoModel video;
  final bool isActive;

  const VideoCard({super.key, required this.video, required this.isActive});

  @override
  State<VideoCard> createState() => _VideoCardState();
}

class _VideoCardState extends State<VideoCard>
    with SingleTickerProviderStateMixin {
  bool _isPlaying = true;
  bool _isInitialized = false;
  late VideoPlayerController _controller;
  late AnimationController _playPauseIconController;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(
        Uri.parse(widget.video.videourl),
      )
      ..initialize().then((_) {
        setState(() {
          _isInitialized = true;
          if (widget.isActive) {
            _controller.play();
            _isPlaying = true;
          }
          _controller.setLooping(true);
        });
      });

    _playPauseIconController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
  }

  @override
  void didUpdateWidget(covariant VideoCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isActive && !_controller.value.isPlaying) {
      _controller.play();
      _isPlaying = true;
    } else if (!widget.isActive && _controller.value.isPlaying) {
      _controller.pause();
      _isPlaying = false;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _playPauseIconController.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    if (_controller.value.isPlaying) {
      _controller.pause();
      _isPlaying = false;
      _playPauseIconController.reverse();
    } else {
      _controller.play();
      _isPlaying = true;
      _playPauseIconController.forward();
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final videoProvider = Provider.of<ShortFeedProvider>(context);
    final isLiked = widget.video.userReaction == 'like';
    final likeCount = widget.video.reactionCounts['like'] ?? 0;

    return GestureDetector(
      onTap: _togglePlayPause,
      child: Stack(
        children: [
          Center(
            child:
                _isInitialized
                    ? AnimatedOpacity(
                      opacity: widget.isActive ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 500),
                      child: VideoPlayer(_controller),
                    )
                    : CommonLoader(
                      fullScreen: true,
                      color: context.colorsScheme.primary,
                    ),
          ),

          /// Play / Pause Animated Icon Center
          if (_isInitialized)
            Center(
              child: AnimatedOpacity(
                opacity: _isPlaying ? 0.0 : 1.0,
                duration: const Duration(milliseconds: 300),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 5,
                        blurStyle: BlurStyle.outer,
                        color: context.colorsScheme.onPrimary,
                      ),
                    ],
                    border: Border.all(color: context.colorsScheme.onSecondary),
                  ),
                  child: AnimatedIcon(
                    size: 80,
                    icon: AnimatedIcons.play_pause,
                    progress: _playPauseIconController,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ),
            ),

          /// Right side actions
          Positioned(
            right: Sizer.w(3),
            bottom: Sizer.h(10),
            child: Column(
              children: [
                _buildIconButton(
                  isLiked ? Icons.favorite : Icons.favorite_border,
                  '$likeCount',
                  onTap: () => videoProvider.toggleLike(widget.video),
                  color: isLiked ? AppColors.redColor : AppColors.whiteColor,
                ),
                SizedBox(height: Sizer.h(1)),
                _buildIconButton(
                  Icons.comment,
                  '${widget.video.commentsCount}',
                  onTap:
                      () => showCommentBottomSheet(
                        context: context,
                        postId: widget.video.postId,
                        postType: "short_videos",
                      ),
                ),
                SizedBox(height: Sizer.h(1)),
                _buildIconButton(
                  Icons.share,
                  'Share',
                  onTap: () {
                    _shareVideo(widget.video.videourl);
                  },
                ),
              ],
            ),
          ),

          /// Bottom profile + username + title
          Positioned(
            left: Sizer.w(3),
            bottom: 20,
            child: Row(
              children: [
                AdvancedAvatar(
                  autoTextSize: true,
                  image: NetworkImage(widget.video.profilePic),
                ),
                SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      fontWeight: FontWeight.bold,
                      color: AppColors.whiteColor,
                      text: '@${widget.video.username}',
                    ),
                    AppText(
                      fontSize: Sizer.sp(3.5),
                      text: widget.video.title,
                      color: AppColors.whiteColor,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton(
    IconData icon,
    String label, {
    Color color = Colors.white,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        IconButton(onPressed: onTap, icon: Icon(icon, color: color, size: 30)),
        AppText(
          text: label,
          fontSize: Sizer.sp(3.5),
          fontWeight: FontWeight.w500,
          color: AppColors.whiteColor,
        ),
      ],
    );
  }
}

void _shareVideo(dynamic videoUrl) {
  try {
    shareReelFromUrl(videoUrl);
  } catch (e) {
    Share.share(videoUrl);
  }
}
