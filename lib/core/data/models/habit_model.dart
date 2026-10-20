import 'package:uuid/uuid.dart';

import '../../domain/entities/habit.dart';

class HabitModel extends HabitItem {
  const HabitModel({
    required super.id,
    required super.name,
    required super.iconIndex,
    required super.goal,
    required super.unit,
    required super.period,
    required super.colorValue,
    required super.createdAt,
  });

  factory HabitModel.fromMap(Map m) => HabitModel(
    id: m['id'] is int
        ? m['id'].toString()
        : m['id'] as String? ?? const Uuid().v4(),
    name: m['name'] as String? ?? 'Untitled',
    iconIndex: m['iconIndex'] as int? ?? 0,
    goal: m['goal'] as int? ?? 1,
    unit: m['unit'] as String? ?? '',
    period: m['period'] as int? ?? 0,
    colorValue: m['colorValue'] as int? ?? 0xFF000000,
    createdAt: m['createdAt'] as int? ?? 0,
  );

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

  factory HabitModel.fromEntity(HabitItem entity) => HabitModel(
    id: entity.id,
    name: entity.name,
    iconIndex: entity.iconIndex,
    goal: entity.goal,
    unit: entity.unit,
    period: entity.period,
    colorValue: entity.colorValue,
    createdAt: entity.createdAt,
  );
}
