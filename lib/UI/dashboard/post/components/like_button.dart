import 'package:flutter/material.dart';
import 'package:talknep/provider/dashboard/dashboard_provider.dart';
import 'package:talknep/util/theme_extension.dart';
import 'package:talknep/widget/app_sizer.dart';
import 'package:talknep/widget/app_text.dart';

class LikeButton extends StatefulWidget {
  final dynamic data;
  final DashboardProvider provider;
  final int index;

  const LikeButton({
    super.key,
    required this.data,
    required this.provider,
    required this.index,
  });

  @override
  State<LikeButton> createState() => _LikeButtonState();
}

class _LikeButtonState extends State<LikeButton>
    with SingleTickerProviderStateMixin {
  late String? localReaction;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    localReaction = widget.data['userReaction'];

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  void onLikeTap() {
    String postId = widget.data['post_id'].toString();

    // Start animation
    _controller.forward().then((_) => _controller.reverse());

    // Optimistically update UI
    setState(() {
      localReaction = localReaction == 'like' ? null : 'like';
    });

    // Call actual API
    widget.provider.postLike(
      postId: postId,
      postLike: localReaction == 'like' ? 'like' : '',
      index: widget.index,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLiked = localReaction == 'like';
    return InkWell(
      onTap: onLikeTap,
      child: Row(
        children: [
          ScaleTransition(
            scale: _scaleAnimation,
            child: Icon(
              size: 20,
              color: context.colorsScheme.primary,
              isLiked ? Icons.favorite : Icons.favorite_border,
            ),
          ),
          SizedBox(width: Sizer.w(2)),
          AppText(
            text: "Like",
            fontSize: Sizer.sp(3.5),
            color: context.colorsScheme.primary,
          ),
        ],
      ),
    );
  }
}
