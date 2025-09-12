import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talknep/UI/chat/call/agora_call_screen.dart';
import 'package:talknep/constant/global.dart';
import 'package:talknep/main.dart';
import 'package:talknep/service/agora_config.dart';
import 'package:talknep/service/api_service.dart';
import 'package:talknep/service/websocket_service.dart';
import 'package:talknep/widget/app_snackbar.dart';
import 'package:talknep/widget/shared_preference.dart';

class ChatViewProvider extends ChangeNotifier {
  // UI/Data
  String? currentSlug;
  bool isSending = false;
  List<dynamic> messagesData = [];
  bool isLoadingMessages = false;
  final ScrollController scrollController = ScrollController();

  bool _disposed = false;
  bool get disposed => _disposed;

  // Pusher Service
  final WebSocketService _webSocketService = WebSocketService();
  StreamSubscription<Map<String, dynamic>>? _messageSubscription;

  // ---------------- PUBLIC API ---------------- //

  void startCall({
    required int id,
    required bool isVideo,
    required BuildContext context,
  }) async {
    if (_disposed) return;

    final agoraResponse = await ApiService.post('generateToken', {
      'channelName': 'demo-room-1',
    });
    if (agoraResponse != null && agoraResponse.statusCode == 200) {
      final uid = agoraResponse.data['uid'];
      final token = agoraResponse.data['token'];
      final appId = agoraResponse.data['appID'];
      final channelName = agoraResponse.data['channelName'];

      if (uid != null) saveAgoraUID(uid);
      if (token != null) saveAgoraToken(token);
      if (appId != null) saveAgoraAppID(appId);
      if (channelName != null) saveAgoraChannelName(channelName);
    } else {
      logger.e("❌ get Agora token: ${agoraResponse?.data}");
    }

    await AgoraConfig.agoraCredential();

    await ApiService.post('fcm/send', {
      'receiver_id': id,
      'title': 'Call Notification',
      'data[action]': 'call-initiated',
      'data[channel]': AgoraConfig.channelName,
      'data[from_user]': Global.userProfileData['id'],
      'data[from_name]': Global.userProfileData['name'],
      // 'data[type]': isVideo ? 'video-call' : 'audio-call',
      'body': isVideo ? 'Incoming Video Call' : 'Incoming Audio Call',
    }).then((value) {
      print('---Response:---${value?.data}-');
      print('---statusCode:---${value?.statusCode}-');

      if (_disposed) return;
      if (value == null || value.statusCode != 200) {
        showCustomSnackbar(context, "Calling Failed", type: SnackbarType.error);
        return;
      } else {
        Get.to(
          () => AgoraCallScreen(
            receiverId: id,
            isVideo: isVideo,
            uid: AgoraConfig.uid ?? 0,
            appId: AgoraConfig.appId ?? "",
            token: AgoraConfig.token ?? "",
            channelName: AgoraConfig.channelName ?? "",
          ),
        );
      }
    });
  }

  /// Fetch messages
  Future<void> getMessages(String slug, {bool isLoading = true}) async {
    if (_disposed) return;

    currentSlug = slug;
    try {
      if (isLoading) {
        isLoadingMessages = true;
        if (!_disposed) notifyListeners();
      }
      // Connect to Pusher and listen for messages
      await _setupPusherListener();

      final response = await ApiService.get('message-threads/$slug');

      if (_disposed) return;

      if (response != null && response.statusCode == 200) {
        messagesData = response.data['messages'] ?? [];
      }
    } catch (e) {
      logger.e("Fetch messages error: $e");
    } finally {
      if (!_disposed) {
        isLoadingMessages = false;
        notifyListeners();
      }
    }
  }

  /// Setup Pusher message listener
  Future<void> _setupPusherListener() async {
    if (_disposed || _messageSubscription != null) return;

    // Connect to Pusher service if not connected
    if (!_webSocketService.isConnected) {
      await _webSocketService.connect();
    }

    // Listen for messages
    _messageSubscription = _webSocketService.messageStream.listen(
      (messageData) {
        if (_disposed) return;

        // Handle typing indicator
        if (messageData['type'] == 'typing') {
          // Handle typing indicator if needed
          return;
        }

        // Handle new message
        final incomingId = messageData['id'];
        if (incomingId != null &&
            messagesData.any((m) => (m is Map && m['id'] == incomingId))) {
          return; // avoid duplicates
        }

        messagesData.add(messageData);
        notifyListeners();
        scrollToBottom();
      },
      onError: (error) {
        logger.e("Message stream error: $error");
      },
    );
  }

  /// Send message
  Future<void> sendMessage(
    BuildContext context, {
    required String slug,
    required String message,
    required int receiverId,
    required VoidCallback onSuccess,
  }) async {
    if (_disposed) return;

    if (message.trim().isEmpty) {
      showCustomSnackbar(
        context,
        "Please enter a message.",
        type: SnackbarType.error,
      );
      return;
    }

    final currentUserId = await getUserId();

    // optimistic add
    final optimistic = {
      'message': message,
      'message_type': 'text',
      'sender_id': currentUserId,
      'created_at': DateTime.now().toIso8601String(),
    };
    messagesData.add(optimistic);
    if (!_disposed) notifyListeners();
    scrollToBottom();

    try {
      final response = await ApiService.post('chat/send', {
        'message': message,
        'message_type': 'text',
        'receiver_id': receiverId.toString(),
      });

      if (_disposed) return;

      if (response != null && response.statusCode == 200) {
        onSuccess();
        await getMessages(slug, isLoading: false);
      } else {
        messagesData.remove(optimistic);
        if (!_disposed) notifyListeners();
        showCustomSnackbar(
          context,
          response?.data['message'] ?? "Failed to send message.",
          type: SnackbarType.error,
        );
      }
    } catch (e) {
      if (!_disposed) {
        messagesData.remove(optimistic);
        notifyListeners();
      }
      logger.e("Send message error: $e");
      showCustomSnackbar(
        context,
        "Something went wrong: $e",
        type: SnackbarType.error,
      );
    }
  }

  /// Delete message
  Future<void> deleteMessage(BuildContext context, int messageId) async {
    if (_disposed) return;

    try {
      final response = await ApiService.delete('chat/message/$messageId');
      if (_disposed) return;

      if (response != null && response.statusCode == 200) {
        messagesData.removeWhere((msg) => msg['id'] == messageId);
        if (!_disposed) notifyListeners();
      } else {
        showCustomSnackbar(
          context,
          "Failed to delete message.",
          type: SnackbarType.error,
        );
      }
    } catch (e) {
      logger.e("Delete message error: $e");
      showCustomSnackbar(
        context,
        "Something went wrong: $e",
        type: SnackbarType.error,
      );
    }
  }

  /// For reversed ListView (reverse:true), bottom = minScrollExtent
  void scrollToBottom() {
    if (_disposed) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_disposed && scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.minScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _disposed = true;

    // Cancel message subscription
    _messageSubscription?.cancel();
    _messageSubscription = null;

    // Dispose scroll controller
    if (scrollController.hasClients) {
      scrollController.dispose();
    }

    super.dispose();
  }
}
