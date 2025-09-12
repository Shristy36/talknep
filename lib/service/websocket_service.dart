import 'dart:async';
import 'dart:convert';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';
import 'package:talknep/main.dart';
import 'package:talknep/service/api_service.dart';
import 'package:talknep/widget/shared_preference.dart';

class WebSocketService {
  static final WebSocketService _instance = WebSocketService._internal();
  factory WebSocketService() => _instance;
  WebSocketService._internal();

  final PusherChannelsFlutter _pusher = PusherChannelsFlutter.getInstance();
  bool _isConnected = false;
  String? _channelName;

  // Stream controllers for different types of events
  final StreamController<Map<String, dynamic>> _messageController =
      StreamController.broadcast();

  final StreamController<Map<String, dynamic>> _chatListUpdateController =
      StreamController.broadcast();

  // Getters for streams
  Stream<Map<String, dynamic>> get messageStream => _messageController.stream;

  Stream<Map<String, dynamic>> get chatListUpdateStream =>
      _chatListUpdateController.stream; 

  bool get isConnected => _isConnected;

  Future<void> connect() async {
    if (_isConnected) return;

    try {
      await _pusher.init(
        apiKey: "9d6f75e244425d042cda",
        cluster: "ap2",
        onConnectionStateChange: (currentState, previousState) {
          logger.i("Pusher state: $currentState");
          _isConnected = currentState == "CONNECTED";
        },
        onError: (message, code, e) {
          logger.w("Pusher error: $message | code:$code | ex:$e");
        },
        onSubscriptionSucceeded: (channel, data) {
          logger.i("Subscribed: $channel");
        },
        onEvent: _onPusherEvent,
        onAuthorizer: (channelName, socketId, options) async {
          try {
            final resp = await ApiService.post(
              "https://talknep.com/broadcasting/auth",
              {"socket_id": socketId, "channel_name": channelName},
            );
            return resp!.data;
          } catch (e) {
            logger.e("Authorizer error: $e");
            rethrow;
          }
        },
      );

      final uid = await getUserId();
      _channelName = "private-chat.$uid";

      await _pusher.subscribe(channelName: _channelName!);
      await _pusher.connect();

      logger.i("Pusher connected & subscribed: $_channelName");
    } catch (e) {
      logger.e("PusherService connect error: $e");
    }
  }

  Future<void> disconnect() async {
    try {
      if (_channelName != null) {
        await _pusher.unsubscribe(channelName: _channelName!);
      }
      await _pusher.disconnect();
      _isConnected = false;
      _channelName = null;
      logger.i("Pusher disconnected successfully");
    } catch (e) {
      logger.e("PusherService disconnect error: $e");
    }
  }

  void _onPusherEvent(PusherEvent event) {
    // ignore internal pusher events
    if (event.eventName.startsWith('pusher:')) return;

    try {
      final payload = _safeDecode(event.data);
      logger.i("Pusher event received: ${event.eventName} - $payload");

      // Handle different event types
      switch (event.eventName) {
        case 'new.message':
        case 'message.sent':
        case 'private-message':
          final normalizedMessage = _normalizeIncoming(payload);
          if (normalizedMessage != null) {
            // Broadcast to both message stream and chat list update stream
            _messageController.add(normalizedMessage);
            _chatListUpdateController.add({
              'type': 'new_message',
              'data': normalizedMessage,
            });
          }
          break;

        case 'chat.deleted':
          _chatListUpdateController.add({
            'type': 'chat_deleted',
            'data': payload,
          });
          break;

        case 'user.typing':
          _messageController.add({'type': 'typing', 'data': payload});
          break;

        default:
          // For unknown events, try to normalize and broadcast
          final msg = _normalizeIncoming(payload);
          if (msg != null) {
            _messageController.add(msg);
            _chatListUpdateController.add({
              'type': 'unknown_message',
              'data': msg,
            });
          }
      }
    } catch (e) {
      logger.w("Event parse failed (${event.eventName}): $e");
    }
  }

  /// Accepts String/Map and always returns Map<String, dynamic>
  Map<String, dynamic> _safeDecode(dynamic raw) {
    if (raw is String) {
      final decoded = jsonDecode(raw);
      if (decoded is Map) {
        return decoded.map((k, v) => MapEntry(k.toString(), v));
      }
      return {'data': decoded};
    } else if (raw is Map) {
      return raw.map((k, v) => MapEntry(k.toString(), v));
    } else {
      return {'data': raw};
    }
  }

  /// Expected keys: id?, sender_id, message_type, message, created_at
  Map<String, dynamic>? _normalizeIncoming(Map<String, dynamic> p) {
    Map<String, dynamic> m;

    if (p['message'] is Map) {
      m = (p['message'] as Map).map((k, v) => MapEntry(k.toString(), v));
    } else if (p['data'] is Map) {
      final d = (p['data'] as Map).map((k, v) => MapEntry(k.toString(), v));
      if (d['message'] is Map) {
        m = (d['message'] as Map).map((k, v) => MapEntry(k.toString(), v));
      } else {
        m = d;
      }
    } else {
      m = p;
    }

    // Map common alternate fields
    if (!m.containsKey('created_at') && m['timestamp'] != null) {
      m['created_at'] = m['timestamp'];
    }
    if (!m.containsKey('message') && m['text'] != null) {
      m['message'] = m['text'];
    }
    if (!m.containsKey('message_type')) {
      m['message_type'] =
          (m['file_url'] != null || m['file'] != null) ? 'file' : 'text';
    }

    // Add slug mapping for message_thread_id
    if (!m.containsKey('slug') && !m.containsKey('msgthread_id')) {
      if (m['message_thread_id'] != null) {
        m['msgthread_id'] = m['message_thread_id'].toString();
        m['slug'] = m['message_thread_id'].toString();
      }
    }

    // Must have at least message or message_type to render a bubble
    if (!(m.containsKey('message') || m.containsKey('message_type'))) {
      return null;
    }
    return m;
  }

  void dispose() {
    _messageController.close();
    _chatListUpdateController.close();
  }
}
