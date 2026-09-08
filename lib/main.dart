import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/services/live_alarm_ticker.dart';
import 'core/theme/app_theme.dart';
import 'features/navigation/main_nav_screen.dart';

void main() {
  runApp(const ProviderScope(child: CalmAlarmApp()));
}

class CalmAlarmApp extends ConsumerWidget {
  const CalmAlarmApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
