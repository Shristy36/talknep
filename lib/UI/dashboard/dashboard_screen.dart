import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:talknep/UI/another%20user%20profile/another_user_profile_screen.dart';
import 'package:talknep/UI/dashboard/astrology/rashi_screen.dart';
import 'package:talknep/UI/dashboard/post/post_card.dart';
import 'package:talknep/UI/dashboard/story/stories.dart';
import 'package:talknep/constant/global.dart';
import 'package:talknep/provider/another%20user%20profile/another_user_profile_provider.dart';
import 'package:talknep/provider/dashboard/dashboard_provider.dart';
import 'package:talknep/provider/dashboard/story_provider.dart';
import 'package:talknep/util/check_connectively.dart';
import 'package:talknep/util/theme_extension.dart';
import 'package:talknep/widget/app_loader.dart';
import 'package:talknep/widget/app_sizer.dart';
import 'package:talknep/widget/app_text.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DashboardProvider>(context);
    final storyProvider = Provider.of<StoryProvider>(context);

    return Scaffold(
      backgroundColor: context.scaffoldBackgroundColor,
      body: Column(
        children: [
          SizedBox(height: Sizer.h(1)),
          Expanded(
            child:
                provider.isLoading
                    ? CommonLoader(color: context.colorsScheme.primary)
                    : RefreshIndicator.adaptive(
                      onRefresh: () async {
                        checkInternetConnection(
                          onConnected: () async {
                            await storyProvider.getStories(refresh: true);
                            await provider.scrollToTopAndRefresh();
                          },
                        );
                      },
                      child: NotificationListener<ScrollNotification>(
                        onNotification: (scrollInfo) {
                          if (!provider.isFetchingMore &&
                              provider.hasMore &&
                              scrollInfo.metrics.pixels >=
                                  scrollInfo.metrics.maxScrollExtent - 200) {
                            provider.getTimelineListData(false);
                          }
                          return false;
                        },
                        child: CustomScrollView(
                          controller: provider.scrollController,
                          slivers: [
                            const SliverToBoxAdapter(child: RashiScreen()),

                            // Story Section
                            SliverToBoxAdapter(
                              child: SizedBox(
                                height: Sizer.h(25),
                                child: const Stories(),
                              ),
                            ),

                            // Posts List using SliverList for better performance
                            SliverList(
                              delegate: SliverChildBuilderDelegate(
                                childCount: provider.posts.length + 1,
                                (context, index) {
                                  // Handle loading indicator
                                  if (index == provider.posts.length) {
                                    if (provider.isFetchingMore) {
                                      return const Padding(
                                        padding: EdgeInsets.symmetric(
                                          vertical: 16,
                                        ),
                                        child: Center(child: CommonLoader()),
                                      );
                                    } else if (!provider.hasMore &&
                                        provider.posts.isNotEmpty) {
                                      return const Padding(
                                        padding: EdgeInsets.symmetric(
                                          vertical: 16,
                                        ),
                                        child: Center(
                                          child: AppText(
                                            fontSize: 14,
                                            color: Colors.grey,
                                            text: "No more posts to load",
                                          ),
                                        ),
                                      );
                                    }
                                    return const SizedBox.shrink();
                                  }

                                  final post = provider.posts[index];
                                  if (post['post_id'] == null) {
                                    return const SizedBox.shrink();
                                  }

                                  return postCard(
                                    index,
                                    post,
                                    context,
                                    provider,
                                    trailing:
                                        post['user_id'] ==
                                                Global.userProfileData['id']
                                            ? ""
                                            : post['follow'],
                                    showMenu: () {
                                      if (post['user_id'] !=
                                          Global.userProfileData['id']) {
                                        if (post['follow'] == "Unfollow") {
                                          provider.unFollowUser(
                                            post['user_id'],
                                            index,
                                          );
                                        } else {
                                          provider.followUser(
                                            post['user_id'],
                                            index,
                                          );
                                        }
                                      }
                                    },
                                    onUserNavigate: () {
                                      anotherUserProfileId =
                                          post['user_id'].toString();
                                      Get.to(
                                        () => AnotherUserProfileScreen(),
                                        transition: Transition.fadeIn,
                                        duration: const Duration(
                                          milliseconds: 500,
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
          ),
        ],
      ),
    );
  }
}
