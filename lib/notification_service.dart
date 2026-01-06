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
    playSound: true,
    enableVibration: true,
  );

  Future<void> init() async {
    print("Initializing NotificationService...");

    // ✅ Correct timezone setup
    tz.initializeTimeZones();

    // Reverting to the @mipmap prefix which is required for resources in mipmap folders
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    const settings = InitializationSettings(android: androidSettings);

    try {
      await _notifications.initialize(
        settings,
        onDidReceiveNotificationResponse: (details) {
          print("Notification tapped: ${details.payload}");
        },
      );
    } catch (e) {
      print("Error during Notification initialization: $e");
      // Fallback to a generic launcher icon name if ic_launcher fails
      try {
        await _notifications.initialize(
          const InitializationSettings(android: AndroidInitializationSettings('@mipmap/launcher_icon')),
          onDidReceiveNotificationResponse: (details) {
            print("Notification tapped: ${details.payload}");
          },
        );
      } catch (e2) {
        print("Final fallback failed: $e2");
      }
    }

    // ✅ CREATE CHANNEL + REQUEST PERMISSION
    if (Platform.isAndroid) {
      final androidPlugin = _notifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      if (androidPlugin != null) {
        await androidPlugin.createNotificationChannel(_eventChannel);
        await androidPlugin.requestNotificationsPermission();
      }
    }

    print("NotificationService Initialized.");
  }

  /// ✅ Check if exact alarm permission is granted
  Future<bool> canScheduleExactAlarms() async {
    if (Platform.isAndroid) {
      final androidPlugin = _notifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlugin != null) {
        try {
          return await (androidPlugin as dynamic).canScheduleExactAlarms() ?? true;
        } catch (e) {
          return true;
        }
      }
    }
    return true;
  }

  /// ✅ Request exact alarm permission
  Future<void> requestExactAlarmPermission() async {
    if (Platform.isAndroid) {
      final androidPlugin = _notifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlugin != null) {
        try {
          await (androidPlugin as dynamic).requestExactAlarmPermission();
        } catch (e) {
          print("Could not request exact alarm permission: $e");
        }
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
          // Removed explicit icon to use the default initialized icon
        ),
      ),
    );
  }

  /// ✅ 10-SECOND TEST NOTIFICATION (EXACT)
  Future<void> scheduleTestNotification() async {
    final scheduledTime =
        tz.TZDateTime.now(tz.local).add(const Duration(seconds: 10));

    print("Scheduling EXACT test notification for $scheduledTime");

    await _notifications.zonedSchedule(
      2,
      'Scheduled Test',
      'This should appear in exactly 10 seconds',
      scheduledTime,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'event_channel_id',
          'Event Notifications',
          importance: Importance.max,
          priority: Priority.high,
          // Removed explicit icon to use the default initialized icon
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
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
          // Removed explicit icon to use the default initialized icon
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );

    print("Scheduled: $title");
  }
}
