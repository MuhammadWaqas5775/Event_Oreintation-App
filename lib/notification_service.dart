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

  /// 🔔 ANDROID CHANNEL (REQUIRED)
  static const AndroidNotificationChannel _eventChannel =
  AndroidNotificationChannel(
    'event_channel_id',
    'Event Notifications',
    description: 'Notifications for upcoming events',
    importance: Importance.max,
  );

  Future<void> init() async {
    print("Initializing NotificationService...");

    // ✅ Correct timezone setup
    tz.initializeTimeZones();

    const androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const settings = InitializationSettings(android: androidSettings);

    await _notifications.initialize(
      settings,
      onDidReceiveNotificationResponse: (details) {
        print("Notification tapped: ${details.payload}");
      },
    );

    // ✅ CREATE CHANNEL + REQUEST PERMISSION
    if (Platform.isAndroid) {
      final androidPlugin =
      _notifications.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();

      if (androidPlugin != null) {
        await androidPlugin.createNotificationChannel(_eventChannel);
        await androidPlugin.requestNotificationsPermission();
      }
    }

    print("NotificationService Initialized.");
  }

  /// 🔐 CHECK IF EXACT ALARM PERMISSION IS GRANTED (Android 12+)
  Future<bool> canScheduleExactAlarms() async {
    if (Platform.isAndroid) {
      final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      
      if (androidPlugin != null) {
        final canSchedule = await androidPlugin.canScheduleExactNotifications();
        print("Can schedule exact alarms: $canSchedule");
        return canSchedule ?? false;
      }
    }
    return true; // iOS or fallback
  }

  /// 🔐 REQUEST EXACT ALARM PERMISSION (Android 12+)
  Future<void> requestExactAlarmPermission() async {
    if (Platform.isAndroid) {
      final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      
      if (androidPlugin != null) {
        print("Requesting exact alarm permission...");
        await androidPlugin.requestExactAlarmsPermission();
      }
    }
  }

  /// ✅ INSTANT TEST (MUST WORK)
  Future<void> showInstantNotification() async {
    await _notifications.show(
      1,
      'Instant Notification',
      'If you see this, notifications are working 🎉',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'event_channel_id',
          'Event Notifications',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
    );
  }

  /// ✅ 10-SECOND TEST NOTIFICATION
  Future<void> scheduleTestNotification() async {
    // Check if we have permission to schedule exact alarms
    final canSchedule = await canScheduleExactAlarms();
    if (!canSchedule) {
      print("⚠️ Cannot schedule test notification - exact alarm permission not granted");
      print("Please request permission first using requestExactAlarmPermission()");
      return;
    }

    final scheduledTime =
    tz.TZDateTime.now(tz.local).add(const Duration(seconds: 10));

    print("📅 Scheduling test notification for $scheduledTime");

    await _notifications.zonedSchedule(
      2,
      'Scheduled Test',
      'This should appear in 10 seconds ⏰',
      scheduledTime,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'event_channel_id',
          'Event Notifications',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
    );
    
    print("✅ Test notification scheduled successfully!");
  }

  /// ✅ REAL EVENT NOTIFICATION
  Future<void> scheduleEventNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduleDate,
  }) async {
    if (scheduleDate.isBefore(DateTime.now())) {
      print("Skipped $title (past time)");
      return;
    }

    // Check if we have permission to schedule exact alarms
    final canSchedule = await canScheduleExactAlarms();
    if (!canSchedule) {
      print("⚠️ Cannot schedule $title - exact alarm permission not granted");
      return;
    }

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduleDate, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'event_channel_id',
          'Event Notifications',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
    );

    print("✅ Scheduled: $title for ${scheduleDate.toString()}");
  }
}
