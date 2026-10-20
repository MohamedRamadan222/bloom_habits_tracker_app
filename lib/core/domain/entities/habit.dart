String dayKey(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

List<DateTime> lastDays(int n) {
  final now = DateTime.now();
  return List.generate(
    n,
    (i) => DateTime(now.year, now.month, now.day - (n - 1 - i)),
  );
}

class HabitItem {
  final String id;
  final String name;
  final int iconIndex;
  final int goal;
  final String unit;
  final int period;
  final int colorValue;
  final int createdAt;

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

  bool get isValid => id.isNotEmpty && goal > 0;

  HabitItem copyWith({
    String? id,
    String? name,
    int? iconIndex,
    int? goal,
    String? unit,
    int? period,
    int? colorValue,
    int? createdAt,
  }) {
    return HabitItem(
      id: id ?? this.id,
      name: name ?? this.name,
      iconIndex: iconIndex ?? this.iconIndex,
      goal: goal ?? this.goal,
      unit: unit ?? this.unit,
      period: period ?? this.period,
      colorValue: colorValue ?? this.colorValue,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class HabitProgress {
  final HabitItem habit;
  final int done;

  const HabitProgress(this.habit, this.done);

  bool get isDone => done >= habit.goal;
}

class HabitWeek {
  final HabitItem habit;
  final List<bool> done;

  const HabitWeek(this.habit, this.done);
}
