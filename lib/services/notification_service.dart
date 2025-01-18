import 'dart:async';
import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flex_server/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;

import '../screens/home_screen.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await NotificationService.instance.setupFlutterNotifications();
  await NotificationService.instance.showNotification(message);
}

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final _messaging = FirebaseMessaging.instance;
  final _localNotifications = FlutterLocalNotificationsPlugin();
  bool _isFlutterLocalNotificationsInitialized = false;

  Future<void> initialize() async {
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Request permission
    await _requestPermission();

    // Setup messsage handlers
    await _setupMessageHandlers();
    await setupFlutterNotifications();

    // GET FCM TOKEN
    final token = await _messaging.getToken();
    print('FCM Token: $token');

    // subribe to all devices/broadcast
    subscribeToTopic('all_devices');
  }

  Future<void> _requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
      announcement: false,
      carPlay: false,
      criticalAlert: false,
    );

    print('Permission status: ${settings.authorizationStatus}');
  }

  Future<void> setupFlutterNotifications() async {
    if (_isFlutterLocalNotificationsInitialized) {
      return;
    }
    const channel = AndroidNotificationChannel(
      'high_importance_channel', // id
      'High Importance Notifications', // title
      description:
          'This channel is used for important notifications.', // description
      importance: Importance.high, // importance
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    const InitializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final initializationSettings = InitializationSettings(
      android: InitializationSettingsAndroid,
    );

    // fluter notifications setup
    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse details) =>
          _handleBackgroundMessage(details.payload!),
    );
    _isFlutterLocalNotificationsInitialized = true;
  }

  Future<void> showNotification(RemoteMessage message) async {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;
    if (notification != null && android != null) {
      await _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'high_importance_channel',
            'High Importance Notifications',
            channelDescription:
                'This channel is used for important notifications.',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
        ),
        payload: message.data['type'].toString(),
      );
    }
  }

  Future<void> _setupMessageHandlers() async {
    // foreground message
    FirebaseMessaging.onMessage.listen((message) {
      showNotification(message);
      _showDialogWithNotification(message);
    });

    // background message
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      _handleBackgroundMessage(message.data['type']);
    });

    // opened app
    final initialMassage = await _messaging.getInitialMessage();
    if (initialMassage != null) {
      _handleBackgroundMessage(initialMassage.data['type']);
    }
  }

  void _handleBackgroundMessage(String message) {
    if (message == 'news') {
      // open news screen
      navigatorKey.currentState?.push(MaterialPageRoute(
        builder: (context) => HomeScreen(),
      ));
    }
  }

  Future<void> subscribeToTopic(String topic) async {
    await FirebaseMessaging.instance.subscribeToTopic(topic);
    print("Subcribed to $topic");
  }

  Future<void> sendNotification(String title, String body) async {
    String accessToken =
        "ya29.c.c0ASRK0GZNij66kWohTOdO3-1YmslFHRe7hecVI8KJkcnf_2kEMilyOTME0Ii6i1Hj8EL-BZejpfV8AtwLUaq3lvfexUBapBO1KGNZOs6KaYUZuNNohro07IVbwNnnlSujOWjBx3hlO5l6Hj_D4Oynse2KU_7H9JXU24AXK7VZT1bUYLeTArIM07VuL0lLTG1IteajV2UawE8Z9QtJW0KQC50OXE11CTycPPL4qmF-MPYbZ6CByKdd4xzlbS1PIuKovfkgdafthojc3HWH0lklRLlZeaJ9y9ZlA0BY_nMQMsnLEUNR7VT3b5xePlv-TIsOJhePuFFY9IApec6PilnVKyyuTqVli773FKPYEx-5hgpdoNBt60Xt1hqDL385D7q5SS3nMwFFnmtzZrb6ovjX9v-z2eJohzStRWOcQcXs-Xuk_MvXpby06bt3WytRhsR9hWRc1_OxoOndrsJw0FYjkl6cXJ7znOxl6rXkd2VB57iv-xsiabJW3Ujehrzr-5F00Ug1OuU4fna_Q-yxeoQlISWc1RkoSjBxBlgVpp0u8s9fOFShuw2j82dmv9i7UMuJmwBneY4UkedOkZRVmsuphu6V5hoF1BhtX5M3-2UtcJ4d01Mirbgm7eccvjdgga27b0x9gOc_SxhpvJo3X28pynVmRYqU3vi9cicu9zRJuiaZs-X8-0qM_vhhu14IWaYxzZmqtW2tUXI1Ble2SkyjSzFyO0R3-IBFcMw3k3_vk8F6Br4nd__Y2Rso17Mtc6v33z9o9V-JeX5Rej8OIQ79opYcsXYycMbstpqlfM4qYy5j39tmXv68Y2zzBBcZJWqUcWOhRYX6SUMt4MwlodROkyRjzlmuv1ud3wz2qFjehrFwXvBZpBuQdsQrOp-qWr-RjBlbuSFe9Mh1Y_-xQQ_y-ybRFUxbcaqtno6g757y8-UR7XXVvMSc4WUsMVF5x4lfcf45z9BygfxoI-9Y-QqepyeIU245le7UXilykr6cVVWR7lQWuVJzWdM";
    var messagePayload = {
      'message': {
        'topic': 'all_devices',
        'notification': {
          'title': title,
          'body': body,
        },
        'data': {'type': 'news'},
        'android': {
          'priority': 'high',
          'notification': {'channel_id': 'high_importance_channel'}
        }
      }
    };
    final url =
        'https://fcm.googleapis.com/v1/projects/flexnews-dc855/messages:send';
    final headers = {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    };

    final response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: jsonEncode(messagePayload),
    );
    if (response.statusCode == 200) {
      print('Notification sent successfully');
    } else {
      print('Failed to send notification ${response.body}');
    }
  }

  void _showDialogWithNotification(RemoteMessage message) {
    final context = navigatorKey.currentContext;
    if (context != null) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(message.notification?.title ?? 'Notification'),
            content: Text(message.notification?.body ??
                "Don't miss what happaned today!!"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Close'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _handleBackgroundMessage(message.data['type'] ?? '');
                },
                child: const Text('View'),
              ),
            ],
          );
        },
      );
    }
  }
}
