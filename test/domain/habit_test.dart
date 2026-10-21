import 'package:flutter/material.dart' show DateUtils;
import 'package:flutter_test/flutter_test.dart';

import 'package:bloom_habit_tracker/core/domain/entities/habit.dart';

HabitItem _habit({String id = 'h1', int goal = 8}) => HabitItem(
  id: id,
  name: 'Water',
  iconIndex: 0,
  goal: goal,
  unit: 'glasses',
  period: 0,
  colorValue: 0xFFE9E5F7,
  createdAt: 0,
);

void main() {
  test('dayKey zero-pads month and day', () {
    expect(dayKey(DateTime(2026, 1, 5)), '2026-01-05');
    expect(dayKey(DateTime(2026, 11, 25)), '2026-11-25');
  });

  test('lastDays returns n ascending days ending today', () {
    final days = lastDays(7);
    expect(days, hasLength(7));
    expect(DateUtils.isSameDay(days.last, DateTime.now()), isTrue);
    for (var i = 1; i < days.length; i++) {
      expect(days[i].difference(days[i - 1]), const Duration(days: 1));
    }
  });

  test('lastDays stays consecutive across month boundary', () {
    final days = lastDays(40);
    expect(days, hasLength(40));
    for (var i = 1; i < days.length; i++) {
      expect(days[i].difference(days[i - 1]), const Duration(days: 1));
    }
  });

  test('isValid rejects empty id and non-positive goal', () {
    expect(_habit().isValid, isTrue);
    expect(_habit(id: '').isValid, isFalse);
    expect(_habit(goal: 0).isValid, isFalse);
    expect(_habit(goal: -2).isValid, isFalse);
  });

  test('copyWith overrides only given fields', () {
    final updated = _habit().copyWith(name: 'Tea', goal: 3);
    expect(updated.name, 'Tea');
    expect(updated.goal, 3);
    expect(updated.id, 'h1'); // untouched
  });

  test('isDone is true exactly at and above goal', () {
    final habit = _habit(goal: 8);
    expect(HabitProgress(habit, 7).isDone, isFalse);
    expect(HabitProgress(habit, 8).isDone, isTrue);
    expect(HabitProgress(habit, 20).isDone, isTrue);
  });
}
