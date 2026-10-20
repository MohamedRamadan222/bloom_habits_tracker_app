import 'package:bloom_habit_tracker/core/domain/entities/habit.dart';
import 'package:bloom_habit_tracker/core/domain/repositories/habits_repository.dart';

class AddHabit {
  final HabitsRepository repository;

  AddHabit(this.repository);

  Future<void> call(HabitItem habit) async {
    await repository.add(habit);
  }
}
