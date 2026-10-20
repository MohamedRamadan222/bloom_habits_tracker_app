
import '../entities/habit.dart';

abstract class HabitsRepository {
  Future<void> add(HabitItem h);
  Future<void> delete(String id);
  Future<void> update(HabitItem h);
  Future<void> setProgress(String id, DateTime date, int amount);

  List<HabitProgress> forDay(DateTime date);
  int streak();
  List<HabitItem> all();
  List<HabitWeek> weeks(List<DateTime> days);
}