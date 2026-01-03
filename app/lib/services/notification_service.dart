/*import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('Notifications autorisées');
    } else {
      debugPrint('Notifications non autorisées');
    }

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iOSSettings =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );
    const InitializationSettings initializationSettings =
        InitializationSettings(android: androidSettings, iOS: iOSSettings);
    await _localNotifications.initialize(initializationSettings);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint(
        'Notification reçue : ${message.notification?.title} - ${message.notification?.body}',
      );
      _showLocalNotification(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('Notification cliquée : ${message.notification?.title}');
    });

    RemoteMessage? initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      debugPrint(
        'App ouverte via notification : ${initialMessage.notification?.title}',
      );
    }

    String? token = await _messaging.getToken();
    debugPrint('FCM Token : $token');
  }

  static Future<void> _showLocalNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'high_importance_channel',
          'High Importance Notifications',
          channelDescription: 'Canal pour notifications importantes',
          importance: Importance.max,
          priority: Priority.high,
        );
    const DarwinNotificationDetails iOSDetails = DarwinNotificationDetails();
    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iOSDetails,
    );

    await _localNotifications.show(
      0,
      message.notification?.title ?? 'Miabé ASSISTANT',
      message.notification?.body ?? 'Nouvelle notification',
      platformDetails,
    );
  }
}
*/