import '../entities/habit.dart';
import '../repositories/habits_repository.dart';

class GetDayHabits {
  final HabitsRepository repository;
  GetDayHabits(this.repository);

  List<HabitProgress> call(DateTime date) {
    return repository.forDay(date);
  }
}