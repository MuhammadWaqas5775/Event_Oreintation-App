import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  // 🔔 NEW CHANNEL ID (To reset any old settings)
  static const String _channelId = 'ueo_high_priority_channel';

  Future<void> init() async {
    print("Initializing NotificationService...");
    tz.initializeTimeZones();

    // Use @mipmap/ic_launcher as it is standard for resources in mipmap
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: androidSettings);

    await _notifications.initialize(
      settings,
      onDidReceiveNotificationResponse: (details) {
        print("Notification tapped: ${details.payload}");
      },
    );

    if (Platform.isAndroid) {
      final androidPlugin = _notifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      if (androidPlugin != null) {
        // Create a very high importance channel
        await androidPlugin.createNotificationChannel(const AndroidNotificationChannel(
          _channelId,
          'UEO Event Notifications',
          description: 'High priority notifications for UEO events',
          importance: Importance.max,
          playSound: true,
          enableVibration: true,
          enableLights: true,
        ));
        await androidPlugin.requestNotificationsPermission();
      }
    }
    print("NotificationService Initialized.");
  }

  Future<void> showInstantNotification() async {
    await _notifications.show(
      1,
      'Notification Working!',
      'This is an instant test notification 🎉',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          'UEO Event Notifications',
          importance: Importance.max,
          priority: Priority.max,
          showWhen: true,
          fullScreenIntent: true, // Helps wake up screen on some devices
        ),
      ),
    );
  }

  Future<void> scheduleTestNotification() async {
    final scheduledTime = tz.TZDateTime.now(tz.local).add(const Duration(seconds: 10));
    print("Scheduling notification for: $scheduledTime");

    await _notifications.zonedSchedule(
      2,
      'Test Successful',
      'The 10-second timer worked!',
      scheduledTime,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          'UEO Event Notifications',
          importance: Importance.max,
          priority: Priority.max,
          fullScreenIntent: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> scheduleEventNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduleDate,
  }) async {
    if (scheduleDate.isBefore(DateTime.now())) return;

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduleDate, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          'UEO Event Notifications',
          importance: Importance.max,
          priority: Priority.max,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  // Fallbacks for the Test Page UI
  Future<bool> canScheduleExactAlarms() async => true;
  Future<void> requestExactAlarmPermission() async {}
}
