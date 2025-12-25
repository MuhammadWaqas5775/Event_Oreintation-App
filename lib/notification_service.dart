import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'dart:io';

class NotificationService {
  static final NotificationService _service = NotificationService._internal();
  factory NotificationService() => _service;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    
    tz.initializeTimeZones();
    
    await _notifications.initialize(
      settings,
      onDidReceiveNotificationResponse: (details) {
        print("Notification clicked: ${details.payload}");
      },
    );
    
    if (Platform.isAndroid) {
      await _notifications.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()?.requestNotificationsPermission();
    }
  }

  Future<void> showInstantNotification(String title, String body) async {
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'event_channel_id',
        'Event Notifications',
        importance: Importance.max,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    );
    await _notifications.show(DateTime.now().millisecond, title, body, details);
  }

  Future<void> scheduleNotification(int id, String title, String body, DateTime eventDate) async {
    // For testing, schedule for 10 seconds from now
    DateTime scheduledTime = DateTime.now().add(const Duration(seconds: 10));
    final tzScheduledTime = tz.TZDateTime.from(scheduledTime, tz.local);

    try {
      await _notifications.zonedSchedule(
        id,
        title,
        body,
        tzScheduledTime,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'event_channel_id',
            'Event Notifications',
            importance: Importance.max,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        // Changed to inexact to avoid the "exact_alarms_not_permitted" error on Android 14+
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle, 
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      );
      print("Scheduled notification '$title' for $scheduledTime");
    } catch (e) {
      print("Error scheduling notification: $e");
    }
  }
}
