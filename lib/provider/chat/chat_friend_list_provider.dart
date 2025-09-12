import 'dart:async';
import 'package:flutter/material.dart';
import 'package:talknep/constant/global.dart';
import 'package:talknep/main.dart';
import 'package:talknep/service/api_service.dart';
import 'package:talknep/service/notification_service.dart';
import 'package:talknep/service/websocket_service.dart';
import 'package:talknep/widget/app_snackbar.dart';

class ChatFriendListProvider extends ChangeNotifier {
  bool isLoading = false;
  bool _mounted = true;
  bool get mounted => _mounted;

  List<dynamic> chatFriendList = [];

  dynamic allUserList;

  List<dynamic> filteredChatFriendList = [];

  String _searchQuery = '';

  Map<String, int> unreadCounts = {};

  // Use singleton Pusher service
  final WebSocketService _pusherService = WebSocketService();

  StreamSubscription<Map<String, dynamic>>? _chatListSubscription;

  ChatFriendListProvider() {
    initData();
    _setupPusherListener();
  }

  Future<void> initData() async {
    await Future.wait([getChatFriendListData(), getAllUserData()]);

    // Connect to Pusher service
    if (!_pusherService.isConnected) {
      await _pusherService.connect();
    }
  }

  void _setupPusherListener() {
    if (!_mounted) return;

    // Listen for chat list updates
    _chatListSubscription = _pusherService.chatListUpdateStream.listen(
      (updateData) {
        if (!_mounted) return;

        final updateType = updateData['type'];
        final data = updateData['data'];

        switch (updateType) {
          case 'new_message':
            _handleIncomingMessage(data);
            break;
          case 'chat_deleted':
            _handleChatDeleted(data);
            break;
          case 'unknown_message':
            _handleIncomingMessage(data);
            break;
        }
      },
      onError: (error) {
        logger.e("Chat list update stream error: $error");
      },
    );
  }

  Future<void> getChatFriendListData({bool isLoad = true}) async {
    if (!_mounted) return;

    try {
      if (isLoad) {
        isLoading = true;
        notifyListeners();
      }

      final response = await ApiService.get('chat-list');

      if (!_mounted) return;

      if (response != null &&
          (response.statusCode == 200 || response.statusCode == 201)) {
        chatFriendList = response.data;

        for (var item in chatFriendList) {
          final slug = item['slug'] ?? item['msgthread_id'];
          if (slug != null) {
            if (item.containsKey('unread_count')) {
              unreadCounts[slug] = item['unread_count'] ?? 0;
            } else if (!unreadCounts.containsKey(slug)) {
              unreadCounts[slug] = 0;
            }
          }
        }

        if (_searchQuery.isEmpty) {
          filteredChatFriendList = List.from(chatFriendList);
        }
      }
    } catch (e) {
      logger.e("Chat Friend List Error: $e");
    } finally {
      if (_mounted) {
        isLoading = false;
        notifyListeners();
      }
    }
  }

  Future<void> getAllUserData({bool isLoad = true}) async {
    if (!_mounted) return;

    try {
      final response = await ApiService.get('all_user');

      if (!_mounted) return;

      if (response != null &&
          (response.statusCode == 200 || response.statusCode == 201)) {
        allUserList = response.data['data'];
      }
    } catch (e) {
      logger.e("All User List Error: $e");
    }
  }

  void updateSearchQuery(String query) {
    if (!_mounted) return;
    _searchQuery = query.trim().toLowerCase();
    applySearchFilter();
  }

  void applySearchFilter() {
    if (!_mounted) return;

    if (_searchQuery.isEmpty) {
      filteredChatFriendList = List.from(chatFriendList);
    } else {
      if (allUserList != null) {
        filteredChatFriendList =
            allUserList.where((item) {
              final name = (item['name'] ?? '').toString().toLowerCase();
              return name.contains(_searchQuery);
            }).toList();
      }
    }
    notifyListeners();
  }

  int getUnreadCount(String slug) {
    return unreadCounts[slug] ?? 0;
  }

  void markAsRead(String slug) {
    if (!_mounted) return;
    unreadCounts[slug] = 0;
    notifyListeners();
  }

  void _handleIncomingMessage(Map<String, dynamic> message) {
    if (!_mounted) return;

    final currentUserId = Global.uid;

    final senderId = message["sender_id"]?.toString();

    // Don't update for own messages
    if (senderId == currentUserId.toString()) {
      return;
    }

    // Try to find slug from various possible fields
    String? slug;

    // Check for slug in various possible locations
    slug =
        message["msgthread_slug"] ??
        message["slug"] ??
        message["thread_id"] ??
        message["msgthread_id"];

    // If still no slug, try to extract from message data
    if (slug == null && message.containsKey('data')) {
      final data = message['data'];
      if (data is Map) {
        slug =
            data["msgthread_slug"] ??
            data["slug"] ??
            data["thread_id"] ??
            data["msgthread_id"];
      }
    }

    // Extract slug from message_thread_id if available
    if (slug == null && message.containsKey('message_thread_id')) {
      slug = message['message_thread_id']?.toString();
    }

    if (slug != null) {
      logger.i(
        "Handling incoming message for slug: $slug from sender: $senderId",
      );

      // Update unread count
      unreadCounts[slug] = (unreadCounts[slug] ?? 0) + 1;

      bool chatExists = false;
      int existingChatIndex = -1;

      // Find existing chat - check both slug and sender_id for better matching
      for (int i = 0; i < chatFriendList.length; i++) {
        final chatSlug =
            chatFriendList[i]['slug']?.toString() ??
            chatFriendList[i]['msgthread_id']?.toString() ??
            chatFriendList[i]['message_thread_id']?.toString();

        final chatUserId =
            chatFriendList[i]['user_id']?.toString() ??
            chatFriendList[i]['id']?.toString();

        // Match by slug first, then by user_id as fallback
        if (chatSlug == slug || (chatUserId == senderId)) {
          existingChatIndex = i;
          chatExists = true;
          break;
        }
      }

      final messageText =
          message['message'] ??
          message['text'] ??
          message['last_message'] ??
          'New message';

      final messageType = message['message_type'] ?? message['type'] ?? 'text';

      if (chatExists && existingChatIndex >= 0) {
        // Update existing chat
        chatFriendList[existingChatIndex]['latest_message'] = {
          'text': messageText,
          'type': messageType,
          'created_at':
              message['created_at'] ?? DateTime.now().toIso8601String(),
        };

        // Update slug in case it changed
        chatFriendList[existingChatIndex]['slug'] = slug;
        chatFriendList[existingChatIndex]['msgthread_id'] = slug;
        if (message.containsKey('message_thread_id')) {
          chatFriendList[existingChatIndex]['message_thread_id'] =
              message['message_thread_id'];
        }

        // Move to top only if not already at top
        if (existingChatIndex > 0) {
          final chatItem = chatFriendList.removeAt(existingChatIndex);
          chatFriendList.insert(0, chatItem);
        }

        logger.i(
          "Updated existing chat at position $existingChatIndex, moved to top",
        );
      } else {
        // Create new chat entry
        final newChatItem = {
          'slug': slug,
          'msgthread_id': slug,
          'user_id': int.tryParse(senderId ?? '0') ?? 0,
          'message_thread_id': message['message_thread_id'],
          'photo': message['sender_avatar'] ?? message['photo'] ?? '',
          'avatar': message['sender_avatar'] ?? message['avatar'] ?? '',
          'name':
              message['sender_name'] ?? message['from_name'] ?? 'Unknown User',
          'latest_message': {
            'text': messageText,
            'type': messageType,
            'created_at':
                message['created_at'] ?? DateTime.now().toIso8601String(),
          },
        };

        chatFriendList.insert(0, newChatItem);
        logger.i("Created new chat entry for slug: $slug, sender: $senderId");
      }

      // Update filtered list if no search query
      if (_searchQuery.isEmpty) {
        filteredChatFriendList = List.from(chatFriendList);
      }

      if (_mounted) {
        notifyListeners();
        logger.i("Chat list updated, total chats: ${chatFriendList.length}");
        final senderName = message['sender_name'] ?? 'New Message';
        final messageText = message['message'] ?? 'You have a new message';

        NotificationService.showNotification(
          title: senderName,
          body: messageText,
        );
      }
    } else {
      logger.w("No slug found in incoming message: $message");
    }
  }

  void _handleChatDeleted(Map<String, dynamic> data) {
    if (!_mounted) return;

    final slug = data['slug'] ?? data['msgthread_id'];
    if (slug != null) {
      chatFriendList.removeWhere(
        (item) => item['slug'] == slug || item['msgthread_id'] == slug,
      );
      unreadCounts.remove(slug);
      applySearchFilter();
      notifyListeners();
    }
  }

  Future<void> deleteChatThread(BuildContext context, String slug) async {
    if (!_mounted) return;

    try {
      final response = await ApiService.delete('chat/delete/$slug');

      if (!_mounted) return;

      if (response != null && response.statusCode == 200) {
        chatFriendList.removeWhere(
          (item) => item['slug'] == slug || item['msgthread_id'] == slug,
        );

        unreadCounts.remove(slug);
        applySearchFilter();

        showCustomSnackbar(
          context,
          "Chat deleted successfully",
          type: SnackbarType.success,
        );
      } else {
        showCustomSnackbar(
          context,
          response?.data['message'] ?? 'Delete failed',
          type: SnackbarType.error,
        );
      }
    } catch (e) {
      logger.e("Delete chat error: $e");
      if (_mounted) {
        showCustomSnackbar(context, 'Error: $e', type: SnackbarType.error);
      }
    }
  }

  @override
  void dispose() {
    _mounted = false;
    _chatListSubscription?.cancel();
    super.dispose();
  }
}
