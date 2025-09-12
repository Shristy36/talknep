import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:talknep/constant/global.dart';

// Background message handler (top-level function)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (Platform.isAndroid) {
    String? fcmToken = await FirebaseMessaging.instance.getToken();

    if (fcmToken != null) {
      Global.FCMToken = fcmToken;
      print("FCM Token: $fcmToken");
    }
  } else {
    String? apnsToken = await FirebaseMessaging.instance.getAPNSToken();

    if (apnsToken != null) {
      Global.FCMToken = apnsToken;
      print("FCM Token: $apnsToken");
    }
  }

  print("Background message received: ${message.messageId}");

  await NotificationService.showNotificationFromFCM(message);
}

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  static final FirebaseMessaging _firebaseMessaging =
      FirebaseMessaging.instance;

  static Future<void> init() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@drawable/ic_notification');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
        );

    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        print('Notification tapped: ${response.payload}');
        handleNotificationTap(response.payload);
      },
    );

    // Create notification channel
    await _createNotificationChannel();

    // Firebase messaging initialization
    await _initializeFirebaseMessaging();
  }

  // Create notification channel for Android
  static Future<void> _createNotificationChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'chat_channel',
      'Chat Notifications',
      playSound: true,
      importance: Importance.high,
      description: 'Notification channel for chat messages',
      sound: RawResourceAndroidNotificationSound('notification_sound'),
    );

    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);
  }

  // Initialize Firebase Messaging
  static Future<void> _initializeFirebaseMessaging() async {
    // Request notification permissions
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    print('User granted permission: ${settings.authorizationStatus}');
    // Get FCM token
    String? token = await _firebaseMessaging.getToken();
    print('FCM Token: $token');

    // Set background message handler
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Foreground message received: ${message.messageId}');
      showNotificationFromFCM(message);
    });

    // Handle notification taps when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Message clicked! ${message.messageId}');
      handleNotificationTap(jsonEncode(message.data));
    });

    // Handle notification tap when app is terminated
    RemoteMessage? initialMessage =
        await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      print('App launched from notification: ${initialMessage.messageId}');
      handleNotificationTap(jsonEncode(initialMessage.data));
    }
  }

  // Show notification from Firebase message
  static Future<void> showNotificationFromFCM(RemoteMessage message) async {
    RemoteNotification? notification = message.notification;

    if (notification != null) {
      await showNotification(
        title: notification.title ?? 'New Message',
        body: notification.body ?? '',
        payload: jsonEncode(message.data),
        imageUrl: notification.android?.imageUrl,
      );
    }
  }

  // Show local notification
  static Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
    String? imageUrl,
  }) async {
    AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          'chat_channel',
          'Chat Notifications',
          ledOnMs: 1000,
          ledOffMs: 500,
          showWhen: true,
          ongoing: false,
          playSound: true,
          colorized: true,
          autoCancel: true,
          enableLights: true,
          showProgress: false,
          enableVibration: true,
          priority: Priority.high,
          importance: Importance.high,
          icon: '@drawable/ic_notification',
          when: DateTime.now().millisecondsSinceEpoch,
          color: const Color.fromARGB(255, 0, 123, 255),
          ledColor: const Color.fromARGB(255, 255, 0, 0),
          vibrationPattern: Int64List.fromList([0, 1000, 500, 1000]),
          channelDescription: 'Notification channel for chat messages',
          styleInformation: BigTextStyleInformation(
            body,
            contentTitle: title,
            htmlFormatBigText: true,
            htmlFormatContentTitle: true,
          ),
          /* actions: [
            const AndroidNotificationAction(
              'reply_action',
              'Reply',
              showsUserInterface: true,
              cancelNotification: false,
            ),
            const AndroidNotificationAction(
              'mark_read_action',
              'Mark as Read',
              showsUserInterface: false,
              cancelNotification: true,
            ),
          ], */
        );


    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        );

    NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await _notificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      payload: payload,
      platformChannelSpecifics,
    );
  }

  // Handle notification tap
  static void handleNotificationTap(String? payload) {
    if (payload != null) {
      try {
        Map<String, dynamic> data = jsonDecode(payload);
        print('Notification data: $data');
        // Navigate to specific screen based on notification data
        // Example: Navigate to chat screen
        // NavigationService.navigateToChat(data['chatId']);
      } catch (e) {
        print('Error parsing notification payload: $e');
      }
    }
  }

  // Get FCM token
  static Future<String?> getToken() async {
    return await _firebaseMessaging.getToken();
  }

  // Subscribe to topic
  static Future<void> subscribeToTopic(String topic) async {
    await _firebaseMessaging.subscribeToTopic(topic);
  }

  // Unsubscribe from topic
  static Future<void> unsubscribeFromTopic(String topic) async {
    await _firebaseMessaging.unsubscribeFromTopic(topic);
  }

  // Cancel specific notification
  static Future<void> cancelNotification(int id) async {
    await _notificationsPlugin.cancel(id);
  }

  // Cancel all notifications
  static Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
  }
}
