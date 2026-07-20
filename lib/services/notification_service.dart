import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../models/task_model.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    
    // For iOS, configure the notification settings appropriately.
    const DarwinInitializationSettings initializationSettingsDarwin = DarwinInitializationSettings();
    
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    await _flutterLocalNotificationsPlugin.initialize(settings: initializationSettings);
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
      await _flutterLocalNotificationsPlugin.zonedSchedule(
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
