import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _eventChannel =
      AndroidNotificationChannel(
    'event_channel_id',
    'Event Notifications',
    description: 'Notifications for upcoming events',
    importance: Importance.max,
  );

  Future<void> init() async {
    print("Initializing NotificationService...");
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

    if (Platform.isAndroid) {
      final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlugin != null) {
        await androidPlugin.createNotificationChannel(_eventChannel);
        await androidPlugin.requestNotificationsPermission();
      }
    }
    print("NotificationService Initialized.");
  }

  /// Schedules notifications for a list of events, 2 days in advance.
  /// This is the new, robust method to be called once.
  Future<void> scheduleAllEventReminders(List<Map<String, dynamic>> events) async {
    print("Attempting to schedule reminders for ${events.length} events.");

    int scheduledCount = 0;
    for (final event in events) {
      // Use a unique, stable ID for each notification.
      // event['id'] must be a non-null String from Firestore document ID.
      final int notificationId = (event['id']?.hashCode ?? DateTime.now().millisecondsSinceEpoch) & 0x7FFFFFFF;
      final String title = event['title'] ?? 'Upcoming Event';
      final String dateString = event['date'] ?? '';

      DateTime? eventDate = _parseDate(dateString);
      if (eventDate == null) {
        print("Skipping '$title' due to invalid date format: '$dateString'");
        continue;
      }

      // Calculate reminder date (2 days before)
      final reminderDate = eventDate.subtract(const Duration(days: 2));

      if (reminderDate.isBefore(DateTime.now())) {
        print("Skipping '$title' because its reminder time is in the past.");
        continue;
      }

      await _scheduleNotification(
        id: notificationId,
        title: title,
        body: "Reminder: The '$title' event is happening in 2 days!",
        scheduleDate: reminderDate,
      );
      scheduledCount++;
    }
    print("Successfully scheduled $scheduledCount reminders.");
  }

  // Helper function to parse date strings like "MMM dd"
  DateTime? _parseDate(String dateStr) {
    if (dateStr.isEmpty) return null;
    try {
      final now = DateTime.now();
      final currentYear = now.year;
      // Assumes date format is like "Jul 25"
      DateTime parsed = DateFormat("MMM dd yyyy").parse("$dateStr $currentYear");

      // If the parsed date is in the past, assume it's for the next year.
      if (parsed.isBefore(now)) {
        parsed = DateTime(currentYear + 1, parsed.month, parsed.day);
      }
      return parsed;
    } catch (e) {
      print("Date parsing error for '$dateStr': $e");
      return null; // Return null on parsing failure
    }
  }

  /// Internal scheduling function.
  Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduleDate,
  }) async {
    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduleDate, tz.local),
      NotificationDetails(
        android: AndroidNotificationDetails(
          _eventChannel.id,
          _eventChannel.name,
          importance: Importance.max,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle, // More precise for reminders
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
    print("SCHEDULED: '$title' for $scheduleDate");
  }
  
  // Test functions remain for debugging.
  Future<void> showInstantNotification() async {
    // ... (implementation unchanged)
  }

  Future<void> scheduleTestNotification() async {
    // ... (implementation unchanged)
  }
}
