import 'dart:ui';

class Habit {
  const Habit({
    required this.name,
    required this.icon,
    required this.goal,
    required this.unit,
    required this.period,
    required this.color,
  });

  final String name;
  final int icon; // index in habitIcons
  final int goal;
  final String unit;
  final int period; // 0 morning, 1 afternoon, 2 evening
  final Color color;
}
