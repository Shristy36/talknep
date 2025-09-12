import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:talknep/UI/reel%20videos/short_feed_video_card.dart';
import 'package:talknep/provider/shortFeed/short_feed_provider.dart';
import 'package:talknep/util/theme_extension.dart';
import 'package:talknep/widget/app_loader.dart';

class ShortFeedScreen extends StatelessWidget {
  const ShortFeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final pageController = PageController();

    return Consumer<ShortFeedProvider>(
      builder: (context, provider, _) {
        return provider.isLoading
            ? CommonLoader(
              fullScreen: true,
              color: context.colorsScheme.primary,
            )
            : RefreshIndicator.adaptive(
              onRefresh: provider.fetchVideos,
              child: PageView.builder(
                controller: pageController,
                allowImplicitScrolling: true,
                scrollDirection: Axis.vertical,
                physics: const PageScrollPhysics(),
                itemCount: provider.videos.length,
                onPageChanged: (index) {
                  provider.setCurrentIndex(index);
                },
                itemBuilder: (context, index) {
                  return VideoCard(
                    video: provider.videos[index],
                    isActive: provider.currentIndex == index,
                  );
                },
              ),
            );
      },
    );
  }
}
