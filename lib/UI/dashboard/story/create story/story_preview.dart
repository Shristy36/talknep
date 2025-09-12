import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talknep/components/net_image.dart';
import 'package:talknep/constant/app_color.dart';
import 'package:talknep/util/theme_extension.dart';
import 'package:talknep/util/file_checker.dart';
import 'package:talknep/widget/app_loader.dart';
import 'package:talknep/widget/app_sizer.dart';
import 'package:talknep/widget/app_text.dart';
import 'package:pod_player/pod_player.dart';

class StoryPreviewScreen extends StatefulWidget {
  final int startUserIndex;
  final Map<String, List<dynamic>> groupedStories;

  const StoryPreviewScreen({
    super.key,
    required this.groupedStories,
    required this.startUserIndex,
  });

  @override
  State<StoryPreviewScreen> createState() => StoryPreviewScreenState();
}

class StoryPreviewScreenState extends State<StoryPreviewScreen>
    with SingleTickerProviderStateMixin {
  late final List<String> userIds;
  late int currentUserIndex;
  int currentIndex = 0;
  List<Map<String, dynamic>> contents = [];

  bool isLoading = true;
  bool isContentReady = false;
  bool isHolding = false;
  int lastSwitchDirection = 1;

  PodPlayerController? podController;

  late AnimationController progressController;

  @override
  void initState() {
    super.initState();

    userIds = widget.groupedStories.keys.toList();
    currentUserIndex = widget.startUserIndex.clamp(
      0,
      max(0, userIds.length - 1),
    );

    contents = [];

    progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );

    progressController.addListener(() => setState(() {}));

    progressController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (currentIndex < contents.length - 1) {
          goToNext();
        } else {
          if (currentUserIndex < userIds.length - 1) {
            _switchUser(currentUserIndex + 1, animateForward: true);
          } else {
            Get.back();
          }
        }
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      prepareUserItems(currentUserIndex);
      if (contents.isNotEmpty) loadContentAtIndex(0);
    });
  }

  @override
  void dispose() {
    podController?.dispose();
    progressController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _buildContentsForStory(dynamic story) {
    final List<Map<String, dynamic>> items = [];

    final description = (story['description'] ?? '').toString().trim();
    final bgHex = (story['bg-color'] ?? '').toString();

    // Always prioritize description first if it exists
    if (description.isNotEmpty) {
      items.add({'type': 'text', 'data': description, 'bgColor': bgHex});
    }

    // Then add media items (images/videos)
    final imgs = (story['post_images'] as List?) ?? [];

    for (final item in imgs) {
      if (item is Map && item.containsKey('type') && item.containsKey('data')) {
        items.add({
          'type': item['type'],
          'data': item['data'],
          'bgColor': bgHex,
        });
      } else if (item is String) {
        items.add({
          'type': isVideoFile(item) ? 'video' : 'image',
          'data': item,
          'bgColor': bgHex,
        });
      }
    }

    if (items.isEmpty) {
      items.add({'type': 'unknown', 'data': null});
    }
    return items;
  }

  void prepareUserItems(int userIndex) {
    final uid = userIds[userIndex];
    final userStories = widget.groupedStories[uid] ?? [];
    final List<Map<String, dynamic>> flat = [];

    for (final s in userStories) {
      flat.addAll(_buildContentsForStory(s));
    }

    contents = flat;
    currentIndex = 0;
  }

  void disposeVideo() {
    podController?.dispose();
    podController = null;
  }

  Duration clampedVideoDuration(Duration d) {
    if (d.inMilliseconds <= 0) return const Duration(seconds: 5);
    return d > const Duration(seconds: 15) ? const Duration(seconds: 15) : d;
  }

  void loadContentAtIndex(int index) {
    setState(() {
      isLoading = true;
      isContentReady = false;
    });

    disposeVideo();
    progressController.stop();
    progressController.reset();

    final content = contents[index];
    final type = content['type'];

    if (type == 'video') {
      podController = PodPlayerController(
          playVideoFrom: PlayVideoFrom.network(content['data']),
        )
        ..initialise()
            .then((_) {
              final vd =
                  podController!.videoPlayerValue?.duration ??
                  const Duration(seconds: 5);

              progressController.duration = clampedVideoDuration(vd);

              podController!
                ..play()
                ..unMute();
              setState(() {
                isContentReady = true;
                isLoading = false;
              });
              progressController.forward(from: 0);
            })
            .catchError((err) {
              progressController.duration = const Duration(seconds: 5);
              setState(() {
                isContentReady = true;
                isLoading = false;
              });
              progressController.forward(from: 0);
            });
      return;
    }

    if (type == 'image') {
      progressController.duration = const Duration(seconds: 5);

      precacheImage(NetworkImage(content['data']), context)
          .then((_) {
            if (!mounted) return;
            setState(() {
              isContentReady = true;
              isLoading = false;
            });
            progressController.forward(from: 0);
          })
          .catchError((_) {
            if (!mounted) return;
            setState(() {
              isContentReady = true;
              isLoading = false;
            });
            progressController.forward(from: 0);
          });
      return;
    }

    progressController.duration = const Duration(seconds: 5);
    setState(() {
      isContentReady = true;
      isLoading = false;
    });
    progressController.forward(from: 0);
  }

  void goToNext() {
    if (currentIndex < contents.length - 1) {
      setState(() => currentIndex++);
      loadContentAtIndex(currentIndex);
    } else {
      if (currentUserIndex < userIds.length - 1) {
        _switchUser(currentUserIndex + 1, animateForward: true);
      } else {
        Get.back();
      }
    }
  }

  void goToPrevious() {
    if (currentIndex > 0) {
      setState(() => currentIndex--);
      loadContentAtIndex(currentIndex);
    } else {
      if (currentUserIndex > 0) {
        _switchUser(
          currentUserIndex - 1,
          animateForward: false,
          jumpToLastItem: true,
        );
      } else {
        Get.back();
      }
    }
  }

  void _switchUser(
    int newUserIndex, {
    required bool animateForward,
    bool jumpToLastItem = false,
  }) {
    lastSwitchDirection = animateForward ? 1 : -1;

    setState(() {
      currentUserIndex = newUserIndex;
      disposeVideo();
      prepareUserItems(currentUserIndex);
      if (jumpToLastItem) {
        currentIndex = max(0, contents.length - 1);
      } else {
        currentIndex = 0;
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadContentAtIndex(currentIndex);
    });
  }

  Color bgFromHex(String? hex) {
    try {
      if (hex == null || hex.isEmpty) return Colors.white;
      return Color(int.parse('0xFF$hex'));
    } catch (_) {
      return AppColors.whiteColor;
    }
  }

  Color bestTextColor(Color bg) {
    final lum = bg.computeLuminance();
    return lum > 0.5 ? Colors.black : Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    final uid = userIds[currentUserIndex];

    final currentContent =
        contents.isNotEmpty
            ? contents[currentIndex]
            : {'type': 'unknown', 'data': null, 'bgColor': ''};

    final type = currentContent['type'];

    final bgColor =
        type == 'text' ? bgFromHex(currentContent['bgColor']) : Colors.white;

    final textColor = bestTextColor(bgColor);

    return Scaffold(
      backgroundColor: context.scaffoldBackgroundColor,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapUp: (details) {
          if (!isHolding) {
            final dx = details.globalPosition.dx;
            final width = MediaQuery.of(context).size.width;
            if (dx < width / 2) {
              goToPrevious();
            } else {
              goToNext();
            }
          }
        },
        onLongPressStart: (_) {
          setState(() {
            isHolding = true;
            progressController.stop();
          });
          podController?.pause();
        },
        onLongPressEnd: (_) {
          setState(() {
            isHolding = false;
            progressController.forward();
          });
          podController?.play();
        },
        child: SafeArea(
          child: Stack(
            children: [
              Positioned.fill(
                child: AnimatedSwitcher(
                  switchInCurve: Curves.easeOut,
                  switchOutCurve: Curves.easeIn,
                  duration: const Duration(milliseconds: 280),
                  transitionBuilder: (child, animation) {
                    final offsetTween = Tween<Offset>(
                      begin: Offset(0.10 * lastSwitchDirection, 0),
                      end: Offset.zero,
                    );
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        child: child,
                        position: animation.drive(offsetTween),
                      ),
                    );
                  },
                  child: StoryContentView(
                    type: type,
                    bgColor: bgColor,
                    textColor: textColor,
                    isLoading: isLoading,
                    podController: podController,
                    data: currentContent['data'],
                    key: ValueKey('$uid-$currentIndex'),
                  ),
                ),
              ),

              Positioned(
                top: 2.h,
                left: 2.w,
                right: 2.w,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 300),
                  opacity: isHolding ? 0.0 : 1.0,
                  child: Row(
                    children: List.generate(contents.length, (i) {
                      double value;
                      if (i < currentIndex) {
                        value = 1.0;
                      } else if (i == currentIndex && isContentReady) {
                        value = progressController.value;
                      } else {
                        value = 0.0;
                      }
                      return Expanded(
                        child: Container(
                          height: 3,
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              value: value,
                              backgroundColor: AppColors.greyColor,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                context.colorsScheme.primary,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class StoryContentView extends StatelessWidget {
  final String type;
  final dynamic data;
  final Color bgColor;
  final Color textColor;
  final bool isLoading;
  final PodPlayerController? podController;

  const StoryContentView({
    super.key,
    required this.type,
    required this.data,
    required this.bgColor,
    required this.textColor,
    required this.isLoading,
    required this.podController,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Center(child: CommonLoader());

    switch (type) {
      case 'image':
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: NetImage(
            fit: BoxFit.contain,
            imageUrl: data ?? '',
            width: double.infinity,
            height: double.infinity,
          ),
        );

      case 'text':
        return Container(
          color: bgColor,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: AppText(
            fontSize: 24,
            color: textColor,
            textAlign: TextAlign.center,
            text: (data ?? '').toString(),
          ),
        );

      case 'video':
        if (podController != null && podController!.isInitialised) {
          return PodVideoPlayer(
            overlayBuilder: (options) {
              return SizedBox();
            },

            controller: podController!,
            alwaysShowProgressBar: false,
            matchFrameAspectRatioToVideo: true,
            matchVideoAspectRatioToFrame: true,
          );
        } else {
          return const Center(child: CommonLoader());
        }

      default:
        return Center(
          child: AppText(
            fontSize: 18,
            textAlign: TextAlign.center,
            color: AppColors.greyColor,
            text: 'Content not available.',
          ),
        );
    }
  }
}
