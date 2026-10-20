import '../entities/habit.dart';
import '../repositories/habits_repository.dart';

class ToggleHabit {
  final HabitsRepository repository;

  ToggleHabit(this.repository);

  Future<void> call(HabitProgress progress, DateTime date) async {
    final int newAmount = progress.isDone ? 0 : progress.habit.goal;
    await repository.setProgress(progress.habit.id, date, newAmount);
  }
}
