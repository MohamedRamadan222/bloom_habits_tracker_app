String dayKey(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

class HabitItem {
  final int id;
  final String name;
  final int iconIndex;
  final int goal;
  final String unit;
  final int period; // 0 morning, 1 afternoon, 2 evening
  final int colorValue;
  final int createdAt; // millis

  const HabitItem({
    required this.id,
    required this.name,
    required this.iconIndex,
    required this.goal,
    required this.unit,
    required this.period,
    required this.colorValue,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'iconIndex': iconIndex,
    'goal': goal,
    'unit': unit,
    'period': period,
    'colorValue': colorValue,
    'createdAt': createdAt,
  };

  factory HabitItem.fromMap(Map m) => HabitItem(
    id: m['id'],
    name: m['name'],
    iconIndex: m['iconIndex'],
    goal: m['goal'],
    unit: m['unit'],
    period: m['period'],
    colorValue: m['colorValue'],
    createdAt: m['createdAt'],
  );
}

class HabitProgress {
  final HabitItem habit;
  final int done;
  const HabitProgress(this.habit, this.done);
  bool get isDone => done >= habit.goal;
}

class HabitWeek {
  final HabitItem habit;
  final List<bool> done; // إنجاز كل يوم من الأيام السبعة
  const HabitWeek(this.habit, this.done);
}

/// آخر [n] أيام، الأقدم أولًا وينتهي باليوم الحالي.
List<DateTime> lastDays(int n) {
  final now = DateTime.now();
  return List.generate(
    n,
        (i) => DateTime(now.year, now.month, now.day - (n - 1 - i)),
  );
}