import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:talknep/UI/chat/chat_view_screen.dart';
import 'package:talknep/UI/chat/components/app_slidable_action.dart';
import 'package:talknep/UI/chat/components/chat_widget.dart';
import 'package:talknep/components/app_appbar.dart';
import 'package:talknep/components/app_spacing.dart';
import 'package:talknep/components/common_shimmer.dart';
import 'package:talknep/provider/chat/chat_friend_list_provider.dart';
import 'package:talknep/provider/chat/chat_view_provider.dart';
import 'package:talknep/util/theme_extension.dart';
import 'package:talknep/widget/app_sizer.dart';
import 'package:talknep/widget/app_text.dart';

class ChatFriendListScreen extends StatefulWidget {
  const ChatFriendListScreen({super.key});

  @override
  State<ChatFriendListScreen> createState() => _ChatFriendListScreenState();
}

class _ChatFriendListScreenState extends State<ChatFriendListScreen>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      final provider = Provider.of<ChatFriendListProvider>(
        context,
        listen: false,
      );

      provider.getChatFriendListData(isLoad: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ChatFriendListProvider>(
      create: (context) => ChatFriendListProvider(),
      child: Scaffold(
        appBar: AppAppbar(title: "Chat"),
        backgroundColor: context.scaffoldBackgroundColor,
        body: Consumer<ChatFriendListProvider>(
          builder: (BuildContext context, provider, Widget? child) {
            return AppHorizontalPadding(
              child: Column(
                children: [
                  SizedBox(height: Sizer.blockHeight),
                  SizedBox(
                    height: Sizer.h(5.5),
                    child: CupertinoSearchTextField(
                      onChanged: provider.updateSearchQuery,
                      placeholder: "Search your friends",
                      placeholderStyle: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: context.colorsScheme.onSurface,
                        fontFamily: GoogleFonts.poppins().fontFamily,
                      ),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: context.colorsScheme.onSurface,
                        fontFamily: GoogleFonts.poppins().fontFamily,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      prefixInsets: const EdgeInsets.only(left: 15.0),
                      suffixInsets: const EdgeInsets.only(right: 10.0),
                      prefixIcon: Icon(
                        CupertinoIcons.search,
                        color: context.colorsScheme.onSurface,
                      ),
                    ),
                  ),
                  SizedBox(height: Sizer.blockHeight),
                  provider.isLoading
                      ? Expanded(
                        child: CustomShimmerList(shimmerType: ShimmerType.list),
                      )
                      : provider.chatFriendList.isEmpty
                      ? const Expanded(
                        child: Center(
                          child: AppText(
                            text: "No friends found.",
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      )
                      : Expanded(
                        child: RefreshIndicator.adaptive(
                          onRefresh:
                              () =>
                                  provider.getChatFriendListData(isLoad: false),
                          child:
                              provider.filteredChatFriendList.isEmpty
                                  ? const Center(
                                    child: AppText(
                                      fontWeight: FontWeight.w400,
                                      text: "No matching friends found.",
                                    ),
                                  )
                                  : ListView.builder(
                                    physics:
                                        const AlwaysScrollableScrollPhysics(),
                                    keyboardDismissBehavior:
                                        ScrollViewKeyboardDismissBehavior
                                            .onDrag,
                                    itemCount:
                                        provider.filteredChatFriendList.length,
                                    itemBuilder: (context, index) {
                                      final item =
                                          provider
                                              .filteredChatFriendList[index];

                                      final isFromChatList = item.containsKey(
                                        'latest_message',
                                      );
                                      final name = item['name'] ?? 'No Name';

                                      final avatar =
                                          item['avatar'] ?? item['photo'];

                                      final slug =
                                          item['slug'] ?? item['msgthread_id'];

                                      final userId =
                                          item['user_id'] ?? item['id'] ?? 0;

                                      final latestMessage =
                                          isFromChatList
                                              ? item['latest_message']
                                              : null;

                                      final messageText =
                                          latestMessage?['type'] == 'file'
                                              ? '[File]'
                                              : latestMessage?['text'] ??
                                                  (item['isChat'] == 'chat'
                                                      ? '[Tap to view]'
                                                      : 'Start new chat');

                                      final createdAt = formatDate(
                                        latestMessage?['created_at'] ?? '',
                                      );

                                      final unreadCount = provider
                                          .getUnreadCount(slug ?? '');

                                      return Slidable(
                                        key: Key('${slug}_$index'),
                                        endActionPane:
                                            isFromChatList
                                                ? ActionPane(
                                                  extentRatio: 0.2,
                                                  dragDismissible: false,
                                                  motion: const DrawerMotion(),
                                                  children: [
                                                    AppSlidableAction(
                                                      onTap:
                                                          () => provider
                                                              .deleteChatThread(
                                                                context,
                                                                slug,
                                                              ),
                                                      icon: Icons.delete,
                                                    ),
                                                  ],
                                                )
                                                : null,
                                        child: ChatWidget(
                                          name: name,
                                          userId: userId,
                                          slug: slug ?? '',
                                          avatar: avatar ?? '',
                                          createdAt: createdAt,
                                          messageText: messageText,
                                          unreadCount: unreadCount,
                                          onTap: () {
                                            if (slug?.isEmpty == true ||
                                                userId == 0)
                                              return;

                                            if (unreadCount > 0) {
                                              provider.markAsRead(slug!);
                                            }
                                            Get.to(
                                              () => ChangeNotifierProvider(
                                                create:
                                                    (_) =>
                                                        ChatViewProvider()
                                                          ..getMessages(slug!),
                                                child: ChatViewScreen(
                                                  slug: slug!,
                                                  receiverId: userId,
                                                  receiverName: name,
                                                  receiverAvatarUrl: avatar,
                                                ),
                                              ),
                                              transition: Transition.fadeIn,
                                              duration: const Duration(
                                                milliseconds: 500,
                                              ),
                                            )?.then((_) {
                                              if (provider.mounted) {
                                                provider.getChatFriendListData(
                                                  isLoad: false,
                                                );
                                              }
                                            });
                                          },
                                        ),
                                      );
                                    },
                                  ),
                        ),
                      ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  String formatDate(String isoDate) {
    if (isoDate.isEmpty) return '';

    try {
      final date = DateTime.tryParse(isoDate);
      if (date == null) return '';

      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.isNegative) {
        return 'now';
      }

      // Better time formatting
      if (difference.inSeconds < 60) {
        return 'now';
      } else if (difference.inMinutes < 60) {
        return '${difference.inMinutes}m ago';
      } else if (difference.inHours < 24) {
        return '${difference.inHours}h ago';
      } else if (difference.inDays == 1) {
        return 'Yesterday';
      } else if (difference.inDays < 7) {
        return '${difference.inDays}d ago';
      } else {
        // For older messages, show actual date
        return '${date.day}/${date.month}/${date.year}';
      }
    } catch (e) {
      // If any error in parsing, return empty string
      return '';
    }
  }
}
