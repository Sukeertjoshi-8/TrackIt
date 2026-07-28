import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../models/task_model.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    
    // For iOS, configure the notification settings appropriately.
    const DarwinInitializationSettings initializationSettingsDarwin = DarwinInitializationSettings();
    
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    await flutterLocalNotificationsPlugin.initialize(settings: initializationSettings);
  }

  Future<void> scheduleTaskReminder(Task task, DateTime deadline) async {
    final tz.TZDateTime reminderTime = tz.TZDateTime.from(deadline.subtract(const Duration(hours: 1)), tz.local);
    
    // Only schedule if the reminder time is in the future
    if (reminderTime.isAfter(tz.TZDateTime.now(tz.local))) {
      await flutterLocalNotificationsPlugin.zonedSchedule(
        id: task.id.hashCode, 
        title: 'Task Pending: ${task.title}',
        body: 'Your task "${task.title}" is pending and close to its deadline!',
        scheduledDate: reminderTime,
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails('task_deadline_channel', 'Task Deadlines', importance: Importance.high),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    }
  }

  Future<void> cancelAll() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }


  /// Stubs out escalating notifications for a strict task tracker app.
  Future<void> scheduleEscalatingNotifications(Task task) async {
    // 1. Initial Notification (e.g., 1 hour before deadline)
    // _flutterLocalNotificationsPlugin.zonedSchedule(...)

    // 2. Urgent Notification (e.g., 10 minutes before deadline)
    // _flutterLocalNotificationsPlugin.zonedSchedule(...)

    // 3. MISSED DEADLINE & ESCALATION
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'strict_channel_id',
      'Strict Tracking Alerts',
      channelDescription: 'Used for critical task deadline missed alerts.',
      fullScreenIntent: true,
      priority: Priority.max,
      importance: Importance.max,
    );
    
    const NotificationDetails notificationDetails = NotificationDetails(android: androidDetails);

    // Schedule only if the deadline is in the future
    if (task.deadline.isAfter(DateTime.now())) {
      await flutterLocalNotificationsPlugin.zonedSchedule(
        id: task.id.hashCode,
        title: 'Critical Task Missed!',
        body: 'You missed the deadline for ${task.title}. Upload proof now!',
        scheduledDate: tz.TZDateTime.from(task.deadline, tz.local),
        notificationDetails: notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    }
  }
}
