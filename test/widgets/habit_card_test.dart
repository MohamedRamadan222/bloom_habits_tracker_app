import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:bloom_habit_tracker/features/home/presentation/widgets/daily_habit.dart';

Future<void> _pumpCard(
  WidgetTester tester, {
  required bool isDone,
  required VoidCallback onToggle,
  VoidCallback? onTap,
}) {
  return tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: HabitCard(
          icon: Icons.water_drop_outlined,
          name: 'Drink water',
          subtitle: '8 glasses · Morning',
          isDone: isDone,
          onTap: onTap,
          onToggle: onToggle,
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('habit card renders + toggle tap fires once', (tester) async {
    var toggles = 0;
    var taps = 0;
    await _pumpCard(
      tester,
      isDone: false,
      onToggle: () => toggles++,
      onTap: () => taps++,
    );

    // Renders contract, no exception.
    expect(tester.takeException(), isNull);
    expect(find.text('Drink water'), findsOneWidget);
    expect(find.text('8 glasses · Morning'), findsOneWidget);
    expect(find.byIcon(LucideIcons.check), findsNothing);

    // Inner circle is the last GestureDetector (outer = card onTap).
    await tester.tap(find.byType(GestureDetector).last);
    expect(toggles, 1);
    expect(taps, 0); // toggle must not leak into card tap

    // Done state renders check.
    await _pumpCard(tester, isDone: true, onToggle: () {});
    await tester.pump();
    expect(find.byIcon(LucideIcons.check), findsOneWidget);
  });
}
