import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pod_player/pod_player.dart';
import 'package:talknep/util/theme_extension.dart';
import 'package:talknep/widget/app_loader.dart';
import 'package:talknep/widget/app_sizer.dart';
import 'package:talknep/widget/app_text.dart';

class CommonVideoPlayer extends StatefulWidget {
  final String source;
  final bool autoPlay;
  final bool isLooping;
  final Widget? loadingWidget;
  final Widget Function()? onVideoError;
  final List<int> videoQualityPriority;
  final bool? matchVideoAspectRatioToFrame;
  final bool? matchFrameAspectRatioToVideo;
  final PodProgressBarConfig? podProgressBarConfig;
  final Widget Function(OverLayOptions)? overlayBuilder;
  final void Function(PodPlayerController controller)? onControllerCreated;

  const CommonVideoPlayer({
    super.key,
    this.onVideoError,
    this.loadingWidget,
    this.overlayBuilder,
    required this.source,
    this.autoPlay = false,
    this.isLooping = false,
    this.onControllerCreated,
    this.podProgressBarConfig,
    this.matchVideoAspectRatioToFrame,
    this.matchFrameAspectRatioToVideo,
    this.videoQualityPriority = const [720, 360],
  });

  @override
  State<CommonVideoPlayer> createState() => _CommonVideoPlayerState();
}

class _CommonVideoPlayerState extends State<CommonVideoPlayer> {
  bool isInitialized = false;
  late final PodPlayerController controller;

  @override
  void initState() {
    super.initState();

    controller = PodPlayerController(
      podPlayerConfig: PodPlayerConfig(
        autoPlay: widget.autoPlay,
        isLooping: widget.isLooping,
        videoQualityPriority: widget.videoQualityPriority,
      ),

      playVideoFrom:
          widget.source.startsWith('http')
              ? PlayVideoFrom.network(widget.source)
              : PlayVideoFrom.file(File(widget.source)),
    );

    controller.initialise().then((_) {
      if (mounted) {
        setState(() {
          isInitialized = true;
        });
      }
      if (widget.onControllerCreated != null) {
        widget.onControllerCreated!(controller);
      }
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PodVideoPlayer(
      controller: controller,
      onVideoError:
          widget.onVideoError ??
          () {
            return Container(
              alignment: Alignment.center,
              color: context.colorsScheme.surface,
              child: AppText(text: 'Unsupported video format ⚠️'),
            );
          },
      podProgressBarConfig:
          widget.podProgressBarConfig ??
          PodProgressBarConfig(
            padding: EdgeInsets.symmetric(
              vertical: Sizer.h(1),
              horizontal: Sizer.h(1),
            ),
          ),
      overlayBuilder: widget.overlayBuilder,
      backgroundColor: context.scaffoldBackgroundColor,
      onLoading: (context) => widget.loadingWidget ?? CommonLoader(),
      videoAspectRatio: controller.videoPlayerValue?.aspectRatio ?? 16 / 9,
      matchFrameAspectRatioToVideo: widget.matchFrameAspectRatioToVideo ?? true,
      matchVideoAspectRatioToFrame: widget.matchVideoAspectRatioToFrame ?? true,
    );
  }
}
