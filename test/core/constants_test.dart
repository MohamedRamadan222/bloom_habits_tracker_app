import 'package:flutter_test/flutter_test.dart';

import 'package:bloom_habit_tracker/core/constants/constants.dart';

void main() {
  test('safeHabitIcon returns exact icon for valid index', () {
    expect(safeHabitIcon(0), habitIcons[0]);
    expect(safeHabitIcon(habitIcons.length - 1), habitIcons.last);
  });

  test('safeHabitIcon falls back instead of throwing RangeError', () {
    expect(safeHabitIcon(99), habitIcons[0]);
    expect(safeHabitIcon(-1), habitIcons[0]);
  });

  test('safePeriod returns exact period for valid index', () {
    expect(safePeriod(0).label, 'Morning');
    expect(safePeriod(2).label, 'Evening');
  });

  test('safePeriod falls back instead of throwing RangeError', () {
    expect(safePeriod(99).label, periods[0].label);
    expect(safePeriod(-1).label, periods[0].label);
  });
}
