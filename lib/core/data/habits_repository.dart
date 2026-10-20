import 'package:hive_ce_flutter/hive_flutter.dart';

import 'habit_item.dart';

class HabitsRepository {
  final Box _habits = Hive.box('habits');
  final Box _logs = Hive.box('logs'); // المفتاح: "id|yyyy-MM-dd" → amount

  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox('habits');
    await Hive.openBox('logs');
  }

  String _k(int id, DateTime d) => '$id|${dayKey(d)}';

  Future<void> add(HabitItem h) => _habits.put(h.id.toString(), h.toMap());

  Future<void> delete(int id) async {
    await _habits.delete(id.toString());
    final prefix = '$id|';
    final keys = _logs.keys.where((k) => (k as String).startsWith(prefix));
    await _logs.deleteAll(keys);
  }

  List<HabitProgress> forDay(DateTime date) {
    final endOfDay = DateTime(
      date.year,
      date.month,
      date.day + 1,
    ).millisecondsSinceEpoch;
    final list =
        _habits.values
            .map((e) => HabitItem.fromMap(e as Map))
            .where((h) => h.createdAt < endOfDay)
            .toList()
          ..sort(
            (a, b) => a.period != b.period
                ? a.period.compareTo(b.period)
                : a.id.compareTo(b.id),
          );
    return list
        .map(
          (h) => HabitProgress(h, _logs.get(_k(h.id, date), defaultValue: 0)),
        )
        .toList();
  }

  Future<void> setProgress(int id, DateTime date, int amount) =>
      _logs.put(_k(id, date), amount < 0 ? 0 : amount);

  int streak() {
    final goals = {
      for (final e in _habits.values) (e as Map)['id'] as int: e['goal'] as int,
    };
    final doneDays = <String>{};
    for (final key in _logs.keys) {
      final parts = (key as String).split('|');
      final goal = goals[int.parse(parts[0])];
      if (goal != null && (_logs.get(key) as int) >= goal) {
        doneDays.add(parts[1]);
      }
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
  List<HabitItem> all() => _habits.values
      .map((e) => HabitItem.fromMap(e as Map))
      .toList()
    ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

  List<HabitWeek> weeks(List<DateTime> days) => [
    for (final h in all())
      HabitWeek(h, [
        for (final d in days)
          (_logs.get(_k(h.id, d), defaultValue: 0) as int) >= h.goal,
      ]),
  ];
  Future<void> update(HabitItem h) => _habits.put(h.id.toString(), h.toMap());
}
