import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bloom_habit_tracker/main.dart';

void main() {
  testWidgets('App starts and renders its navigation', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    expect(tester.takeException(), isNull);
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.byType(NavigationDestination), findsNWidgets(4));
    expect(find.text('الرئيسية'), findsOneWidget);
  });
}
