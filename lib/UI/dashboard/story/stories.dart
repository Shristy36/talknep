import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:talknep/UI/dashboard/story/components/create_story_tab.dart';
import 'package:talknep/UI/dashboard/story/create%20story/create_story.dart';
import 'package:talknep/UI/dashboard/story/create%20story/story_preview.dart';
import 'package:talknep/provider/dashboard/story_provider.dart';
import 'package:talknep/widget/app_loader.dart';
import 'package:talknep/widget/app_sizer.dart';

class Stories extends StatelessWidget {
  const Stories({super.key});

  @override
  Widget build(BuildContext context) {
    final storyProvider = Provider.of<StoryProvider>(context);
    return SizedBox(
      height: Sizer.h(25),
      child: Builder(
        builder: (_) {
          final allStories = storyProvider.stories;

          final Map<String, List<dynamic>> groupedStories = {};

          for (final store in allStories) {
            final key = (store['user_id'] ?? '').toString();
            if (key.isEmpty) continue;
            groupedStories.putIfAbsent(key, () => []);
            groupedStories[key]!.add(store);
          }

          final userIds = groupedStories.keys.toList();

          return NotificationListener<ScrollNotification>(
            onNotification: (scrollInfo) {
              if (!storyProvider.isFetching &&
                  storyProvider.hasMore &&
                  scrollInfo.metrics.pixels ==
                      scrollInfo.metrics.maxScrollExtent) {
                storyProvider.getStories();
              }
              return false;
            },
            child: ListView.builder(
              itemCount: userIds.length + 2,
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemBuilder: (context, index) {
                if (index == 0) {
                  return GestureDetector(
                    onTap: () {
                      Get.to(
                        () => const AddStory(),
                        transition: Transition.fadeIn,
                        duration: const Duration(milliseconds: 500),
                      );
                    },
                    child: const CreateStory(),
                  );
                }
                if (index == userIds.length + 1) {
                  return storyProvider.isFetching
                      ? const Center(child: CommonLoader())
                      : const SizedBox.shrink();
                }

                final userId = userIds[index - 1];
                final userStories = groupedStories[userId]!;
                final firstStory = userStories.first;

                return GestureDetector(
                  onTap: () {
                    Get.to(
                      transition: Transition.fadeIn,
                      duration: const Duration(milliseconds: 300),
                      () => StoryPreviewScreen(
                        startUserIndex: index - 1,
                        groupedStories: groupedStories,
                      ),
                    );
                  },
                  child: StoryTabWidget(storyData: firstStory),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
