import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../core/providers/notification_settings_provider.dart';
import 'package:mobile_project_app/core/l10n/app_localizations.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    tz.initializeTimeZones();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: false, // Don't ask immediately on iOS, ask later
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: onNotificationTap,
    );
  }

  static void onNotificationTap(NotificationResponse notificationResponse) {
    final payload = notificationResponse.payload;
    if (payload != null) {
       // Logic to handle tapping (e.g. open map if it's a room payload)
    }
  }

  Future<bool> requestPermissions() async {
    bool granted = false;
    
    final androidImplementation = flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
            
    if (androidImplementation != null) {
      final result = await androidImplementation.requestNotificationsPermission();
      granted = result ?? false;
      // Also request exact alarms permission
      await androidImplementation.requestExactAlarmsPermission();
    }

    final iosImplementation = flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();
            
    if (iosImplementation != null) {
      final result = await iosImplementation.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      granted = result ?? false;
    }
    
    return granted;
  }

  bool _isWithinDndLimits(tz.TZDateTime time, NotificationSettings settings) {
    if (!settings.dndEnabled) return false;
    
    final hour = time.hour;
    if (settings.dndStartHour <= settings.dndEndHour) {
      // e.g. 2 PM to 5 PM
      return hour >= settings.dndStartHour && hour < settings.dndEndHour;
    } else {
      // e.g. 10 PM to 7 AM (crosses midnight)
      return hour >= settings.dndStartHour || hour < settings.dndEndHour;
    }
  }

  Future<void> scheduleLessonNotifications(List<LessonSchedule> lessons, NotificationSettings settings, AppLocalizations l10n) async {
    await flutterLocalNotificationsPlugin.cancelAll();

    if (!settings.isEnabled) return;
    if (settings.intervalsMinutes.isEmpty) return;

    for (var lesson in lessons) {
      for (var intervalMin in settings.intervalsMinutes) {
        
        // Calculate notification time
        final notifyTimeLocal = lesson.startTime.subtract(Duration(minutes: intervalMin));
        final scheduledTimeTZ = tz.TZDateTime.from(notifyTimeLocal, tz.local);
        
        // Don't schedule in the past
        if (scheduledTimeTZ.isBefore(tz.TZDateTime.now(tz.local))) {
          continue; 
        }

        // Apply DND rule
        if (_isWithinDndLimits(scheduledTimeTZ, settings)) {
          continue;
        }

        // Generate a unique ID for this specific interval notification
        final notificationId = lesson.id.hashCode ^ intervalMin;
        
        String timeStr = intervalMin >= 60 
          ? '${intervalMin ~/ 60} ${l10n.hourShort}' 
          : '$intervalMin ${l10n.minuteShort}';

        await _scheduleNotification(
          id: notificationId,
          title: l10n.lessonIn(timeStr),
          body: '${lesson.name} • ${l10n.roomAtFloor(lesson.roomNumber, lesson.floor)}',
          scheduledTime: scheduledTimeTZ,
          payload: 'room_${lesson.roomNumber}',
          l10n: l10n,
        );
      }
    }
  }

  Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required tz.TZDateTime scheduledTime,
    required AppLocalizations l10n,
    String? payload,
  }) async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduledTime,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'lesson_channel_v2',
          l10n.lessonNotifications,
          channelDescription: l10n.lessonReminders,
          importance: Importance.max,
          priority: Priority.max,
          enableVibration: true,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
    );
  }

  Future<void> showImmediateNotification({
    required String lessonName,
    required String roomNumber,
    required int floor,
    required AppLocalizations l10n,
  }) async {
    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'lesson_channel_v2',
      l10n.lessonNotifications,
      channelDescription: l10n.lessonReminders,
      importance: Importance.max,
      priority: Priority.max,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await flutterLocalNotificationsPlugin.show(
      roomNumber.hashCode,
      l10n.lessonStarting(lessonName),
      l10n.roomAtFloor(roomNumber, floor),
      platformDetails,
      payload: 'room_$roomNumber',
    );
  }

  // ── News Notifications ──

  Future<void> showNewsNotification({
    required String title,
    required String body,
    required AppLocalizations l10n,
  }) async {
    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'news_channel',
      l10n.timelyNews,
      channelDescription: l10n.newPublications,
      importance: Importance.high,
      priority: Priority.high,
      enableVibration: true,
      styleInformation: const BigTextStyleInformation(''),
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await flutterLocalNotificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      '📰 $title',
      body,
      platformDetails,
      payload: 'news',
    );
  }

  Future<void> scheduleNewsNotification({
    required String title,
    required String body,
    required DateTime scheduledTime,
    required AppLocalizations l10n,
  }) async {
    final scheduledTimeTZ = tz.TZDateTime.from(scheduledTime, tz.local);
    
    // Don't schedule in the past
    if (scheduledTimeTZ.isBefore(tz.TZDateTime.now(tz.local))) {
      // If time has passed, show immediately
      await showNewsNotification(title: title, body: body, l10n: l10n);
      return;
    }

    await _scheduleNotification(
      id: scheduledTime.millisecondsSinceEpoch ~/ 1000,
      title: '📰 $title',
      body: body,
      scheduledTime: scheduledTimeTZ,
      payload: 'news',
      l10n: l10n,
    );
  }
}

class LessonSchedule {
  final String id;
  final String name;
  final String roomNumber;
  final int floor;
  final DateTime startTime;
  final DateTime endTime;

  LessonSchedule({
    required this.id,
    required this.name,
    required this.roomNumber,
    required this.floor,
    required this.startTime,
    required this.endTime,
  });
}

