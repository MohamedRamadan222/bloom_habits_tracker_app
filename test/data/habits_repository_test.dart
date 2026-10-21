import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';

import 'package:bloom_habit_tracker/core/data/habits_repository.dart';
import 'package:bloom_habit_tracker/core/domain/entities/habit.dart';

HabitItem _habit(String id, {String name = 'Water', int goal = 8}) {
  return HabitItem(
    id: id,
    name: name,
    iconIndex: 0,
    goal: goal,
    unit: 'glasses',
    period: 0,
    colorValue: 0xFFE9E5F7,
    createdAt: DateTime.now().millisecondsSinceEpoch,
  );
}

void main() {
  late Directory tempDir;
  late HabitsRepositoryImpl repo;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    tempDir = await Directory.systemTemp.createTemp('habits_repo_test');
    Hive.init(tempDir.path);
    await Hive.openBox('habits');
    await Hive.openBox('logs');
    repo = HabitsRepositoryImpl(); // factory guards init order
  });

  tearDownAll(() async {
    await Hive.deleteFromDisk();
  });

  setUp(() async {
    await Hive.box('habits').clear();
    await Hive.box('logs').clear();
  });

  test('add + forDay round-trips data', () async {
    final today = DateTime.now();
    await repo.add(_habit('h1'));

    final items = repo.forDay(today);
    expect(items, hasLength(1));
    expect(items.first.habit.name, 'Water');
    expect(items.first.done, 0);
    expect(items.first.isDone, isFalse);
  });

  test('setProgress negative clamps to 0, toggle threshold is goal', () async {
    final today = DateTime.now();
    await repo.add(_habit('h1', goal: 8));

    await repo.setProgress('h1', today, -5);
    expect(repo.forDay(today).first.done, 0);

    await repo.setProgress('h1', today, 8);
    expect(repo.forDay(today).first.isDone, isTrue);
  });

  test('delete cascades logs so streak does not inflate', () async {
    final today = DateTime.now();
    await repo.add(_habit('h1', goal: 1));
    await repo.setProgress('h1', today, 1);
    expect(repo.streak(), 1);

    await repo.delete('h1');
    expect(repo.all(), isEmpty);
    expect(repo.streak(), 0);
  });

  test('streak ignores garbage log keys and orphan ids', () async {
    final today = DateTime.now();
    await repo.add(_habit('h1', goal: 1));
    await repo.setProgress('h1', today, 1);

    final logs = Hive.box('logs');
    await logs.put('badkey', 5);
    await logs.put('h1|not-a-date', 5);
    await logs.put('ghost|2026-01-01', 5); // deleted-habit id
    await logs.put('h1|2026-01-01', 'not-an-int');

    expect(() => repo.streak(), returnsNormally);
    expect(repo.streak(), 1);
  });

  test('streak counts consecutive days, resets on gap', () async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    await repo.add(_habit('h1', goal: 1));

    await repo.setProgress('h1', today, 1);
    expect(repo.streak(), 1);

    await repo.setProgress(
      'h1',
      today.subtract(const Duration(days: 1)),
      1,
    );
    expect(repo.streak(), 2);

    // Gap yesterday, done 3 days ago -> back to 1.
    await Hive.box('logs').clear();
    await repo.setProgress('h1', today, 1);
    await repo.setProgress(
      'h1',
      today.subtract(const Duration(days: 3)),
      1,
    );
    expect(repo.streak(), 1);
  });

  test('streak ignores future-only logs', () async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    await repo.add(_habit('h1', goal: 1));
    await repo.setProgress('h1', today.add(const Duration(days: 1)), 1);
    expect(repo.streak(), 0);
  });

  test('streak is 0 with no habits', () {
    expect(repo.streak(), 0);
  });

  test('weeks returns per-day done matrix', () async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    await repo.add(_habit('h1', goal: 2));
    await repo.setProgress('h1', today, 2); // done
    await repo.setProgress('h1', yesterday, 1); // partial

    final weeks = repo.weeks([yesterday, today]);
    expect(weeks, hasLength(1));
    expect(weeks.first.done, [false, true]);
  });

  test('forDay excludes habits created in the future', () async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrowStart = today.add(const Duration(days: 1));
    final future = HabitItem(
      id: 'future',
      name: 'Future',
      iconIndex: 0,
      goal: 1,
      unit: '',
      period: 0,
      colorValue: 0xFFE9E5F7,
      createdAt: tomorrowStart.millisecondsSinceEpoch + 1,
    );
    await repo.add(_habit('h1'));
    await repo.add(future);

    expect(repo.forDay(today).map((e) => e.habit.id), ['h1']);
    expect(
      repo.forDay(tomorrowStart).map((e) => e.habit.id),
      contains('future'),
    );
  });

  test('forDay sorts by period then id', () async {
    await repo.add(_habit('b', name: 'B'));
    await repo.add(
      HabitItem(
        id: 'a',
        name: 'A',
        iconIndex: 0,
        goal: 1,
        unit: '',
        period: 2,
        colorValue: 0xFFE9E5F7,
        createdAt: 0,
      ),
    );
    await repo.add(_habit('c', name: 'C'));

    final ids = repo.forDay(DateTime.now()).map((e) => e.habit.id);
    expect(ids, ['b', 'c', 'a']); // period 0 first (by id), then period 2
  });

  test('update overwrites habit fields', () async {
    await repo.add(_habit('h1', name: 'Water'));
    await repo.update(_habit('h1', name: 'Tea'));
    expect(repo.all().single.name, 'Tea');
  });

  test('legacy int ids migrate to strings on read', () async {
    await Hive.box('habits').put(42, {
      'id': 42,
      'name': 'Legacy',
      'iconIndex': 0,
      'goal': 1,
      'unit': '',
      'period': 0,
      'colorValue': 0xFF000000,
      'createdAt': 0,
    });
    final all = repo.all();
    expect(all, hasLength(1));
    expect(all.single.id, '42');
  });
}
