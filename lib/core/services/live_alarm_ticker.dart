import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/alarm.dart';
import 'local_alarm_service.dart';
import '../../features/ambient_wake/views/alarm_ringing_screen.dart';

final navigatorKey = GlobalKey<NavigatorState>();

final liveAlarmTickerProvider = Provider<LiveAlarmTicker>((ref) {
  final ticker = LiveAlarmTicker(ref);
  ticker.start();
  ref.onDispose(() => ticker.dispose());
  return ticker;
});

class LiveAlarmTicker {
  final Ref _ref;
  Timer? _timer;
  final Map<String, String> _lastTriggeredMinute = {};

  LiveAlarmTicker(this._ref);

  void start() {
    _timer?.cancel();
    // Check every 3 seconds against real system clock
    _timer = Timer.periodic(const Duration(seconds: 3), (t) {
      _checkAlarms();
    });
  }

  void _checkAlarms() {
    final now = DateTime.now();
    final alarms = _ref.read(alarmListProvider).where((a) => a.isEnabled).toList();

    for (final alarm in alarms) {
      // Check repeat day criteria
      final todayWeekday = now.weekday; // 1 = Monday, 7 = Sunday
      final isDayScheduled = alarm.repeatDays.isEmpty || alarm.repeatDays.contains(todayWeekday);

      if (isDayScheduled &&
          now.hour == alarm.time.hour &&
          now.minute == alarm.time.minute) {
        
        final triggerKey = '${alarm.id}_${now.year}_${now.month}_${now.day}_${now.hour}_${now.minute}';
        if (_lastTriggeredMinute[alarm.id] != triggerKey) {
          _lastTriggeredMinute[alarm.id] = triggerKey;
          _fireAlarm(alarm);
        }
      }
    }
  }

  void _fireAlarm(Alarm alarm) {
    if (navigatorKey.currentState != null) {
      navigatorKey.currentState!.push(
        MaterialPageRoute(
          builder: (context) => AlarmRingingScreen(alarm: alarm),
        ),
      );
    }
  }

  /// Sets a test alarm for exactly X seconds from now so the user can easily see it fire live!
  void scheduleTestAlarmInSeconds(int seconds) {
    final fireTime = DateTime.now().add(Duration(seconds: seconds));
    final testAlarm = Alarm(
      id: 'quick_test_${DateTime.now().millisecondsSinceEpoch}',
      time: TimeOfDay(hour: fireTime.hour, minute: fireTime.minute),
      label: 'Live Test Wake',
      isEnabled: true,
      repeatDays: [],
      ambientDurationMinutes: 1,
      soundscape: 'Morning Birds',
      snoozeDurationMinutes: 5,
      maxSnoozeCount: 2,
    );
    _ref.read(alarmListProvider.notifier).addAlarm(testAlarm);
  }

  void dispose() {
    _timer?.cancel();
  }
}
