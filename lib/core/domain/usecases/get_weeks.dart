import '../entities/habit.dart';
import '../repositories/habits_repository.dart';

class GetWeeks {
  final HabitsRepository repository;
  GetWeeks(this.repository);

  List<HabitWeek> call(List<DateTime> days) {
    return repository.weeks(days);
  }
}