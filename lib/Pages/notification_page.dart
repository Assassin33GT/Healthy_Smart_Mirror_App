import 'package:demo/main.dart';
import 'package:demo/widgets/curvednavigator.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

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
    requestNotificationPermission();
  }

  void requestNotificationPermission() async {
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();

    final bool? granted =
        await flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >()
            ?.requestNotificationsPermission();

    if (granted == true) {
      print("✅ Notification permission granted.");
    } else {
      print("❌ Notification permission denied.");
    }
  }

  void initFirebaseMessaging() {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    // Request permission
    messaging.requestPermission();

    // Get the token
    messaging.getToken().then((token) {
      print("FCM Token: $token");
    });

    // Foreground message handling
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("Foreground notification: ${message.notification?.title}");
    });

    // App opened from background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("Opened from notification: ${message.notification?.title}");
    });
  }

  void initLocalNotifications() async {
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);

    // Schedule repeating notification
    scheduleSleepReminder();
  }

  void scheduleSleepReminder() async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'sleep_channel_id',
          'Sleep Reminder',
          channelDescription: 'Periodic reminder to go to sleep',
          importance: Importance.max,
          priority: Priority.high,
        );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
    );

    await flutterLocalNotificationsPlugin.periodicallyShow(
      0, // Notification ID
      '😴 Time to Sleep',
      'Go to sleep now for better health and skin!',
      RepeatInterval.everyMinute,
      platformDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  @override
  Widget build(context) {
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
                const Padding(
                  padding: EdgeInsets.only(top: 8.0, left: 8.0),
                  child: Text(
                    "Skin:",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 25,
                    ),
                  ),
                ),
                buildCard(
                  "✨Apply Sunscreen!",
                  "Protect your skin daily with SPF 30+ to prevent wrinkles and sun damage.",
                ),
                const SizedBox(height: 30),
                const Divider(color: Colors.black54),
                const Padding(
                  padding: EdgeInsets.only(top: 8.0, left: 8.0),
                  child: Text(
                    "Meals:",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 25,
                    ),
                  ),
                ),
                buildCard(
                  "🍎 Healthy Eating Tip!",
                  "Add a serving of greens to your lunch today — rich in vitamins for glowing skin!",
                ),
                const SizedBox(height: 30),
                const Divider(color: Colors.black54),
                const Padding(
                  padding: EdgeInsets.only(top: 8.0, left: 8.0),
                  child: Text(
                    "Tips:",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 25,
                    ),
                  ),
                ),
                buildCard(
                  "🧘 Mental Health Reminder!",
                  "Take 5 minutes today to breathe deeply or meditate. Stress management = better skin + better mood!",
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

  Widget buildCard(String title, String message) {
    return Center(
      child: Card(
        margin: const EdgeInsets.all(12),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 8),
              Text(message),
            ],
          ),
        ),
      ),
    );
  }
}
