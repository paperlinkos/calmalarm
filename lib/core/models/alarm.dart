import 'package:flutter/material.dart';

class Alarm {
  final String id;
  final TimeOfDay time;
  final String label;
  final bool isEnabled;
  final List<int> repeatDays; // 1 = Monday, 7 = Sunday
  final int ambientDurationMinutes; // Pre-alarm sunrise fade in minutes
  final String soundscape;
  final double volumeLevel; // 0.0 to 1.0
  final int gradualFadeDurationSeconds; // Gradual sound ramp: 0, 30, 60, 120, 300
  final String vibrationPattern; // 'Heartbeat', 'Ascending', 'Waves', 'Off'
  
  // Snooze Rules
  final int snoozeDurationMinutes; // 5, 9, 10, 15, 20
  final int maxSnoozeCount; // 0 (Hard Mode - no snooze), 1, 2, 3, 99 (Unlimited)
  final bool isSmartSnooze; // Decreasing snooze window: 10m -> 7m -> 5m -> 2m
  final bool snoozePenaltyEnabled; // Fires up embers on pod plot if snoozed
  final int snoozeCountUsed;
  
  // Dismissal Challenge
  final String dismissChallenge; // 'Slide to Dismiss', 'Mindful Breath', 'Water Plant'
  final String? syncPodId;

  const Alarm({
    required this.id,
    required this.time,
    required this.label,
    this.isEnabled = true,
    this.repeatDays = const [1, 2, 3, 4, 5],
    this.ambientDurationMinutes = 15,
    this.soundscape = 'Morning Birds',
    this.volumeLevel = 0.8,
    this.gradualFadeDurationSeconds = 60,
    this.vibrationPattern = 'Gentle Waves',
    this.snoozeDurationMinutes = 9,
    this.maxSnoozeCount = 3,
    this.isSmartSnooze = false,
    this.snoozePenaltyEnabled = true,
    this.snoozeCountUsed = 0,
    this.dismissChallenge = 'Slide to Dismiss',
    this.syncPodId,
  });

  Alarm copyWith({
    String? id,
    TimeOfDay? time,
    String? label,
    bool? isEnabled,
    List<int>? repeatDays,
    int? ambientDurationMinutes,
    String? soundscape,
    double? volumeLevel,
    int? gradualFadeDurationSeconds,
    String? vibrationPattern,
    int? snoozeDurationMinutes,
    int? maxSnoozeCount,
    bool? isSmartSnooze,
    bool? snoozePenaltyEnabled,
    int? snoozeCountUsed,
    String? dismissChallenge,
    String? syncPodId,
  }) {
    return Alarm(
      id: id ?? this.id,
      time: time ?? this.time,
      label: label ?? this.label,
      isEnabled: isEnabled ?? this.isEnabled,
      repeatDays: repeatDays ?? this.repeatDays,
      ambientDurationMinutes: ambientDurationMinutes ?? this.ambientDurationMinutes,
      soundscape: soundscape ?? this.soundscape,
      volumeLevel: volumeLevel ?? this.volumeLevel,
      gradualFadeDurationSeconds: gradualFadeDurationSeconds ?? this.gradualFadeDurationSeconds,
      vibrationPattern: vibrationPattern ?? this.vibrationPattern,
      snoozeDurationMinutes: snoozeDurationMinutes ?? this.snoozeDurationMinutes,
      maxSnoozeCount: maxSnoozeCount ?? this.maxSnoozeCount,
      isSmartSnooze: isSmartSnooze ?? this.isSmartSnooze,
      snoozePenaltyEnabled: snoozePenaltyEnabled ?? this.snoozePenaltyEnabled,
      snoozeCountUsed: snoozeCountUsed ?? this.snoozeCountUsed,
      dismissChallenge: dismissChallenge ?? this.dismissChallenge,
      syncPodId: syncPodId ?? this.syncPodId,
    );
  }

  String get formattedTime {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  String get repeatSummary {
    if (repeatDays.isEmpty) return 'Once';
    if (repeatDays.length == 7) return 'Every day';
    if (repeatDays.length == 5 && repeatDays.every((d) => d >= 1 && d <= 5)) {
      return 'Weekdays';
    }
    if (repeatDays.length == 2 && repeatDays.contains(6) && repeatDays.contains(7)) {
      return 'Weekends';
    }
    const daysStr = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return repeatDays.map((d) => daysStr[d - 1]).join(', ');
  }

  /// Calculates the next occurrence of this alarm
  DateTime getNextTriggerDateTime() {
    final now = DateTime.now();
    DateTime target = DateTime(now.year, now.month, now.day, time.hour, time.minute);

    if (repeatDays.isEmpty) {
      // One-time alarm: if today's time has passed, schedule for tomorrow
      if (target.isBefore(now)) {
        target = target.add(const Duration(days: 1));
      }
      return target;
    }

    // Repeating alarm: find the closest scheduled day
    for (int dayOffset = 0; dayOffset < 7; dayOffset++) {
      final checkDate = now.add(Duration(days: dayOffset));
      final checkWeekday = checkDate.weekday; // 1 = Monday, 7 = Sunday
      if (repeatDays.contains(checkWeekday)) {
        final candidate = DateTime(
          checkDate.year,
          checkDate.month,
          checkDate.day,
          time.hour,
          time.minute,
        );
        if (candidate.isAfter(now)) {
          return candidate;
        }
      }
    }

    // Default fallback to next week
    return target.add(const Duration(days: 7));
  }

  /// Human readable countdown string (e.g. "Rings in 6 hrs 24 mins", "Rings in 2 days 4 hrs")
  String get countdownString {
    if (!isEnabled) return 'Alarm disabled';
    final now = DateTime.now();
    final next = getNextTriggerDateTime();
    final diff = next.difference(now);

    final days = diff.inDays;
    final hours = diff.inHours % 24;
    final minutes = diff.inMinutes % 60;

    if (diff.inMinutes <= 1) {
      return 'Rings in less than a minute';
    } else if (days > 0) {
      if (hours == 0) {
        return 'Rings in $days ${days == 1 ? "day" : "days"}';
      }
      return 'Rings in $days ${days == 1 ? "day" : "days"} $hours hrs';
    } else if (hours == 0) {
      return 'Rings in $minutes mins';
    } else if (minutes == 0) {
      return 'Rings in $hours hrs';
    } else {
      return 'Rings in $hours hrs $minutes mins';
    }
  }

  /// Compact duration until alarm rings (e.g. "in 6 hrs 24 mins", "in 2 days", "in 45 mins", "in < 1 min")
  String get timeUntilString {
    if (!isEnabled) return 'Off';
    final now = DateTime.now();
    final next = getNextTriggerDateTime();
    final diff = next.difference(now);

    final days = diff.inDays;
    final hours = diff.inHours % 24;
    final minutes = diff.inMinutes % 60;

    if (diff.inMinutes <= 1) {
      return 'in < 1 min';
    } else if (days > 0) {
      if (hours == 0) {
        return 'in $days ${days == 1 ? "day" : "days"}';
      }
      return 'in $days ${days == 1 ? "day" : "days"} $hours hrs';
    } else if (hours == 0) {
      return 'in $minutes mins';
    } else if (minutes == 0) {
      return 'in $hours hrs';
    } else {
      return 'in $hours hrs $minutes mins';
    }
  }

  /// Remaining snoozes allowed
  int get remainingSnoozes {
    if (maxSnoozeCount == 99) return 99; // Unlimited
    return (maxSnoozeCount - snoozeCountUsed).clamp(0, maxSnoozeCount);
  }
}
