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
    await flutterLocalNotificationsPlugin.zonedSchedule(
      1348,
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
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
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
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Custom Header
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 20,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          //const SizedBox(width: 12),
                          const Text(
                            "Notifications",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 28,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                // Notification Sections
                _buildSection(
                  icon: Icons.wb_sunny_outlined,
                  title: "Skin",
                  cardTitle: "✨ Apply Sunscreen!",
                  message:
                      "Protect your skin daily with SPF 30+ to prevent wrinkles and sun damage.",
                  cardColor: Colors.orange.shade100.withOpacity(0.7),
                  iconColor: Colors.orange.shade700,
                ),
                _buildSection(
                  icon: Icons.restaurant,
                  title: "Meals",
                  cardTitle: "🍎 Healthy Eating Tip!",
                  message:
                      "Add a serving of greens to your lunch today — rich in vitamins for glowing skin!",
                  cardColor: Colors.green.shade100.withOpacity(0.7),
                  iconColor: Colors.green.shade700,
                ),
                _buildSection(
                  icon: Icons.self_improvement,
                  title: "Tips",
                  cardTitle: "🧘 Mental Health Reminder!",
                  message:
                      "Take 5 minutes today to breathe deeply or meditate. Stress management = better skin + better mood!",
                  cardColor: Colors.purple.shade100.withOpacity(0.7),
                  iconColor: Colors.purple.shade700,
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const Curvednavigator(),
    );
  }

  Widget _buildSection({
    required IconData icon,
    required String title,
    required String cardTitle,
    required String message,
    required Color cardColor,
    required Color iconColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Center(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.07),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cardTitle,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      message,
                      style: const TextStyle(
                        fontSize: 15,
                        color: Colors.black87,
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