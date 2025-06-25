import 'dart:async';
import 'package:demo/main.dart';
import 'package:demo/widgets/curvednavigator.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:permission_handler/permission_handler.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  @override
  void initState() {
    super.initState();
    initFirebaseMessaging();
    initLocalNotifications();
  }

  Future<void> initLocalNotifications() async {
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initializationSettings = InitializationSettings(android: androidInit);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
    tz.initializeTimeZones();

    await requestNotificationPermission();
    await scheduleDailyNotifications();
  }

  Future<void> requestNotificationPermission() async {
    final status = await Permission.notification.status;

    if (!status.isGranted) {
      final newStatus = await Permission.notification.request();
      if (newStatus.isGranted) {
        print("✅ Notification permission granted.");
      } else {
        print("❌ Notification permission denied.");
      }
    } else {
      print("✅ Notification permission already granted.");
    }
  }

  void initFirebaseMessaging() {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    messaging.requestPermission();

    messaging.getToken().then((token) {
      print("📡 FCM Token: $token");
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("📬 Foreground notification: ${message.notification?.title}");
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("📲 Opened from notification: ${message.notification?.title}");
    });
  }

  Future<void> scheduleDailyNotifications() async {
    const androidDetails = AndroidNotificationDetails(
      'daily_notifications_channel',
      'Daily Reminders',
      channelDescription: 'Daily skincare and health reminders',
      importance: Importance.max,
      priority: Priority.high,
    );

    const notificationDetails = NotificationDetails(android: androidDetails);

    // 10:00 AM
    await flutterLocalNotificationsPlugin.zonedSchedule(
      1010,
      '☀️ Morning Skincare',
      'Protect your skin daily with SPF 30+ to prevent wrinkles and sun damage.',
      _nextInstanceOfTime(10, 0),
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );

    // 11:00 AM
    await flutterLocalNotificationsPlugin.zonedSchedule(
      1110,
      '🥗 Meal Tip',
      'Add a serving of greens to your lunch today — rich in vitamins for glowing skin!',
      _nextInstanceOfTime(11, 0),
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );

    // 12:00 AM (midnight)
    await flutterLocalNotificationsPlugin.zonedSchedule(
      1200,
      '🧘 Wellness Reminder',
      'Take 5 minutes today to breathe deeply or meditate. Stress management = better skin + better mood!',
      _nextInstanceOfTime(0, 0),
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color1, color2],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.only(top: 45.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Text(
                    "Notification",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 35,
                    ),
                  ),
                ),
                const Divider(color: Colors.white60),
                buildSection("Skin:", "✨Apply Sunscreen!",
                    "Protect your skin daily with SPF 30+ to prevent wrinkles and sun damage."),
                const SizedBox(height: 30),
                const Divider(color: Colors.black54),
                buildSection("Meals:", "🍎 Healthy Eating Tip!",
                    "Add a serving of greens to your lunch today — rich in vitamins for glowing skin!"),
                const SizedBox(height: 30),
                const Divider(color: Colors.black54),
                buildSection("Tips:", "🧘 Mental Health Reminder!",
                    "Take 5 minutes today to breathe deeply or meditate. Stress management = better skin + better mood!"),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const Curvednavigator(),
    );
  }

  Widget buildSection(String title, String cardTitle, String message) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 8.0, left: 8.0),
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 25,
            ),
          ),
        ),
        Center(
          child: Card(
            margin: const EdgeInsets.all(12),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(cardTitle,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 8),
                  Text(message),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
