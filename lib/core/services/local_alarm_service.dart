import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/alarm.dart';
import 'notification_alarm_service.dart';

final alarmListProvider = StateNotifierProvider<AlarmListNotifier, List<Alarm>>((ref) {
  return AlarmListNotifier();
});

final nextUpcomingAlarmProvider = Provider<Alarm?>((ref) {
  final alarms = ref.watch(alarmListProvider).where((a) => a.isEnabled).toList();
  if (alarms.isEmpty) return null;

  alarms.sort((a, b) => a.getNextTriggerDateTime().compareTo(b.getNextTriggerDateTime()));
  return alarms.first;
});

/// Emits a tick every 15 seconds to keep the in-card time countdown fresh and responsive
final alarmTickerStreamProvider = StreamProvider.autoDispose<DateTime>((ref) {
  return Stream.periodic(const Duration(seconds: 15), (_) => DateTime.now());
});

class AlarmListNotifier extends StateNotifier<List<Alarm>> {
  AlarmListNotifier()
      : super([
          const Alarm(
            id: 'alarm_1',
            time: TimeOfDay(hour: 7, minute: 0),
            label: 'Circadian Sunrise Wake',
            isEnabled: true,
            repeatDays: [1, 2, 3, 4, 5],
            ambientDurationMinutes: 15,
            soundscape: 'Morning Birds',
            volumeLevel: 0.85,
            gradualFadeDurationSeconds: 60,
            vibrationPattern: 'Gentle Waves',
            snoozeDurationMinutes: 9,
            maxSnoozeCount: 3,
            isSmartSnooze: false,
            snoozePenaltyEnabled: true,
            dismissChallenge: 'Slide to Dismiss',
            syncPodId: 'pod_commute_1',
          ),
          const Alarm(
            id: 'alarm_2',
            time: TimeOfDay(hour: 8, minute: 30),
            label: 'Morning Focus & Coffee',
            isEnabled: false,
            repeatDays: [1, 2, 3, 4, 5, 6, 7],
            ambientDurationMinutes: 10,
            soundscape: 'Morning Dew',
            volumeLevel: 0.7,
            gradualFadeDurationSeconds: 30,
            vibrationPattern: 'Heartbeat',
            snoozeDurationMinutes: 5,
            maxSnoozeCount: 1,
            isSmartSnooze: true,
            snoozePenaltyEnabled: false,
            dismissChallenge: 'Slide to Dismiss',
          ),
        ]) {
    _syncAllScheduledNotifications();
  }

  void _syncAllScheduledNotifications() {
    for (final alarm in state) {
      if (alarm.isEnabled) {
        NotificationAlarmService().scheduleAlarmNotification(alarm);
      }
    }
  }

  void toggleAlarm(String id) {
    state = [
      for (final alarm in state)
        if (alarm.id == id) alarm.copyWith(isEnabled: !alarm.isEnabled) else alarm
    ];

    final updated = state.firstWhere((a) => a.id == id);
    if (updated.isEnabled) {
      NotificationAlarmService().scheduleAlarmNotification(updated);
    } else {
      NotificationAlarmService().cancelAlarmNotification(updated.id);
    }
  }

  void addAlarm(Alarm alarm) {
    state = [...state, alarm];
    if (alarm.isEnabled) {
      NotificationAlarmService().scheduleAlarmNotification(alarm);
    }
  }

  void updateAlarm(Alarm updated) {
    state = [
      for (final alarm in state)
        if (alarm.id == updated.id) updated else alarm
    ];
    if (updated.isEnabled) {
      NotificationAlarmService().scheduleAlarmNotification(updated);
    } else {
      NotificationAlarmService().cancelAlarmNotification(updated.id);
    }
  }

  void deleteAlarm(String id) {
    state = state.where((a) => a.id != id).toList();
    NotificationAlarmService().cancelAlarmNotification(id);
  }
}
