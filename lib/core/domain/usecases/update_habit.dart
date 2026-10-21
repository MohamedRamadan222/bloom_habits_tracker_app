import 'package:bloom_habit_tracker/core/domain/entities/habit.dart';
import 'package:bloom_habit_tracker/core/domain/repositories/habits_repository.dart';

class UpdateHabit {
  final HabitsRepository repository;

  UpdateHabit(this.repository);

  Future<void> call(HabitItem habit) async {
    await repository.update(habit);
  }
}
