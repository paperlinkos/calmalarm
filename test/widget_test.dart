import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:calmalarm/main.dart';
import 'package:calmalarm/core/services/live_alarm_ticker.dart';
import 'package:calmalarm/core/services/local_alarm_service.dart';

void main() {
  testWidgets('CalmAlarm smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          liveAlarmTickerProvider.overrideWith((ref) => LiveAlarmTicker(ref)),
          alarmTickerStreamProvider.overrideWith((ref) => Stream.value(DateTime.now())),
        ],
        child: const CalmAlarmApp(),
      ),
    );
    expect(find.text('CalmAlarm'), findsOneWidget);
  });
}
