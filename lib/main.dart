import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/models/alarm.dart';
import 'core/services/live_alarm_ticker.dart';
import 'core/services/local_alarm_service.dart';
import 'core/services/notification_alarm_service.dart';
import 'core/theme/app_theme.dart';
import 'features/ambient_wake/views/alarm_ringing_screen.dart';
import 'features/navigation/main_nav_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize notification service & request permissions for high-priority wake
  final notificationService = NotificationAlarmService();
  await notificationService.initialize();
  await notificationService.requestPermissions();

  runApp(const ProviderScope(child: CalmAlarmApp()));
}

class CalmAlarmApp extends ConsumerStatefulWidget {
  const CalmAlarmApp({super.key});

  @override
  ConsumerState<CalmAlarmApp> createState() => _CalmAlarmAppState();
}

class _CalmAlarmAppState extends ConsumerState<CalmAlarmApp> {
  @override
  void initState() {
    super.initState();
    // Listen for notification triggers to launch full screen wake activity
    NotificationAlarmService().onAlarmTrigger.listen((alarmId) {
      final alarms = ref.read(alarmListProvider);
      final targetAlarm = alarms.firstWhere(
        (a) => a.id == alarmId,
        orElse: () => alarms.first,
      );

      final nav = navigatorKey.currentState;
      if (nav != null) {
        nav.push(
          MaterialPageRoute(
            builder: (_) => AlarmRingingScreen(alarm: targetAlarm),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Keep live alarm ticker active
    ref.watch(liveAlarmTickerProvider);

    return MaterialApp(
      title: 'CalmAlarm — Social & Ambient Wake',
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      theme: AppTheme.lightLinenTheme(context),
      darkTheme: AppTheme.darkMidnightTheme(context),
      themeMode: ThemeMode.system,
      home: const MainNavScreen(),
    );
  }
}
