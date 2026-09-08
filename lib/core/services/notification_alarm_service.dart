import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../models/alarm.dart';

class NotificationAlarmService {
  static NotificationAlarmService? _instance;
  factory NotificationAlarmService() => _instance ??= NotificationAlarmService._internal();
  NotificationAlarmService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();
  final StreamController<String> _onAlarmTriggerController = StreamController<String>.broadcast();

  Stream<String> get onAlarmTrigger => _onAlarmTriggerController.stream;

  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Initialize TimeZone database
      tz.initializeTimeZones();

      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      const darwinSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: darwinSettings,
        macOS: darwinSettings,
      );

      await _notificationsPlugin.initialize(
        initSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          if (response.payload != null && response.payload!.isNotEmpty) {
            _onAlarmTriggerController.add(response.payload!);
          }
        },
      );

      // Create High-Priority Notification Channel for Android
      const androidChannel = AndroidNotificationChannel(
        'calm_alarm_channel_id',
        'CalmAlarm Sunrise Wake Channel',
        description: 'High priority full-screen wake channel for CalmAlarm circadian sunrise',
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
      );

      await _notificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(androidChannel);
    } catch (e) {
      debugPrint('NotificationAlarmService initialize skipped or failed (test env): $e');
    }

    _isInitialized = true;
  }

  Future<void> requestPermissions() async {
    try {
      if (await Permission.notification.isDenied) {
        await Permission.notification.request();
      }

      if (await Permission.scheduleExactAlarm.isDenied) {
        await Permission.scheduleExactAlarm.request();
      }
    } catch (e) {
      debugPrint('NotificationAlarmService requestPermissions skipped (test env): $e');
    }
  }

  Future<void> scheduleAlarmNotification(Alarm alarm) async {
    await initialize();

    if (!alarm.isEnabled) {
      await cancelAlarmNotification(alarm.id);
      return;
    }

    final triggerDateTime = alarm.getNextTriggerDateTime();
    final tzTrigger = tz.TZDateTime.from(triggerDateTime, tz.local);

    final notificationId = alarm.id.hashCode;

    const androidDetails = AndroidNotificationDetails(
      'calm_alarm_channel_id',
      'CalmAlarm Sunrise Wake Channel',
      channelDescription: 'High priority full-screen wake channel for CalmAlarm circadian sunrise',
      importance: Importance.max,
      priority: Priority.max,
      fullScreenIntent: true,
      category: AndroidNotificationCategory.alarm,
      audioAttributesUsage: AudioAttributesUsage.alarm,
      ongoing: true,
      autoCancel: false,
      actions: [
        AndroidNotificationAction(
          'snooze',
          'Snooze 9 mins',
          showsUserInterface: true,
        ),
        AndroidNotificationAction(
          'dismiss',
          'Dismiss Alarm',
          showsUserInterface: true,
        ),
      ],
    );

    const darwinDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentSound: true,
      presentBadge: true,
      interruptionLevel: InterruptionLevel.critical,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
      macOS: darwinDetails,
    );

    try {
      await _notificationsPlugin.zonedSchedule(
        notificationId,
        '🌅 ${alarm.label}',
        'Circadian sunrise wake in progress...',
        tzTrigger,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: alarm.id,
      );
    } catch (e) {
      debugPrint('Error scheduling notification: $e');
    }
  }

  Future<void> cancelAlarmNotification(String alarmId) async {
    await initialize();
    await _notificationsPlugin.cancel(alarmId.hashCode);
  }

  Future<void> cancelAllNotifications() async {
    await initialize();
    await _notificationsPlugin.cancelAll();
  }
}
