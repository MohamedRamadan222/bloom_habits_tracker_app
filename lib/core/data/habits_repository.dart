import 'package:hive_ce_flutter/hive_flutter.dart';

import '../domain/entities/habit.dart';
import '../domain/repositories/habits_repository.dart';
import 'models/habit_model.dart';

class HabitsRepositoryImpl implements HabitsRepository {
  HabitsRepositoryImpl._();

  factory HabitsRepositoryImpl() {
    if (!Hive.isBoxOpen('habits') || !Hive.isBoxOpen('logs')) {
      throw StateError('Call HabitsRepositoryImpl.init() first');
    }
    return HabitsRepositoryImpl._();
  }

  Box get _habits => Hive.box('habits');

  Box get _logs => Hive.box('logs');

  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox('habits');
    await Hive.openBox('logs');
  }

  String _k(String id, DateTime d) => '$id|${dayKey(d)}';

  @override
  Future<void> add(HabitItem h) async {
    final model = HabitModel.fromEntity(h);
    await _habits.put(model.id, model.toMap());
  }

  @override
  Future<void> delete(String id) async {
    await _habits.delete(id);
    final prefix = '$id|';
    final keys = _logs.keys.where((k) => (k as String).startsWith(prefix));
    await _logs.deleteAll(keys);
  }

  @override
  List<HabitProgress> forDay(DateTime date) {
    final endOfDay = DateTime(
      date.year,
      date.month,
      date.day + 1,
    ).millisecondsSinceEpoch;

    final list =
        _habits.values
            .map((e) => HabitModel.fromMap(e as Map))
            .where((h) => h.isValid && h.createdAt < endOfDay)
            .toList()
          ..sort(
            (a, b) => a.period != b.period
                ? a.period.compareTo(b.period)
                : a.id.compareTo(b.id),
          );

    return list.map((h) {
      final value = _logs.get(_k(h.id, date), defaultValue: 0);
      final int amount = value is int ? value : 0;
      return HabitProgress(h, amount);
    }).toList();
  }

  @override
  Future<void> setProgress(String id, DateTime date, int amount) async {
    await _logs.put(_k(id, date), amount < 0 ? 0 : amount);
  }

  @override
  int streak() {
    final goals = {for (final h in all()) h.id: h.goal};
    final doneDays = <String>{};

    for (final key in _logs.keys) {
      if (key is! String) continue;
      final parts = key.split('|');
      if (parts.length != 2) continue;

      final id = parts[0];
      final dateStr = parts[1];
      final goal = goals[id];
      if (goal == null) continue;

      final value = _logs.get(key);
      if (value is! int) continue;

      if (value >= goal) doneDays.add(dateStr);
    }

    final now = DateTime.now();
    var d = DateTime(now.year, now.month, now.day);
    if (!doneDays.contains(dayKey(d))) d = DateTime(d.year, d.month, d.day - 1);
    var n = 0;
    while (doneDays.contains(dayKey(d))) {
      n++;
      d = DateTime(d.year, d.month, d.day - 1);
    }
    return n;
  }

  @override
  List<HabitItem> all() =>
      _habits.values
          .map((e) => HabitModel.fromMap(e as Map))
          .where((h) => h.isValid)
          .toList()
        ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

  @override
  List<HabitWeek> weeks(List<DateTime> days) => [
    for (final h in all())
      HabitWeek(h, [
        for (final d in days)
          (_logs.get(_k(h.id, d), defaultValue: 0) is int
                  ? _logs.get(_k(h.id, d), defaultValue: 0) as int
                  : 0) >=
              h.goal,
      ]),
  ];

  @override
  Future<void> update(HabitItem h) async {
    final model = HabitModel.fromEntity(h);
    await _habits.put(model.id, model.toMap());
  }
}
