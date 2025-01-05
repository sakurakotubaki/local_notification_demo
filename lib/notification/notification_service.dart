import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:flutter/material.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;
  NotificationService._();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    try {
      tzdata.initializeTimeZones();

      const androidInitializationSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const initializationSettingsIOS = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
        defaultPresentAlert: true,
        defaultPresentBadge: true,
        defaultPresentSound: true,
      );

      const initializationSettings = InitializationSettings(
        iOS: initializationSettingsIOS,
        android: androidInitializationSettings,
      );

      await _notifications.initialize(initializationSettings);

      // Android 13以降の場合、通知権限を要求
      final androidPlugin =
          _notifications.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlugin != null) {
        await androidPlugin.requestNotificationsPermission();
      }

      // iOS用の権限リクエスト
      final iosPlugin = _notifications.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      if (iosPlugin != null) {
        await iosPlugin.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
          critical: true,
        );
      }
    } catch (e) {
      debugPrint('通知の初期化に失敗: $e');
    }
  }

  Future<void> scheduleNotification(DateTime scheduledTime) async {
    try {
      var scheduledDate = tz.TZDateTime.from(scheduledTime, tz.local);

      // 過去の時間が指定された場合は翌日の同時刻に設定
      if (scheduledDate.isBefore(tz.TZDateTime.now(tz.local))) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      await _notifications.zonedSchedule(
        0,
        '🔔',
        'ローカル通知です。',
        scheduledDate,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'notification_channel_id',
            'Notification Channel',
            channelDescription:
                'This channel is used for important notifications.',
            importance: Importance.max,
            priority: Priority.high,
            icon: null,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
            sound: 'default',
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
      debugPrint('通知をスケジュール: $scheduledTime');
    } catch (e) {
      debugPrint('通知のスケジュールに失敗: $e');
      rethrow;
    }
  }

  Future<void> cancelAllNotifications() async {
    try {
      await _notifications.cancelAll();
      debugPrint('全ての通知をキャンセルしました');
    } catch (e) {
      debugPrint('通知のキャンセルに失敗: $e');
      rethrow;
    }
  }
}
