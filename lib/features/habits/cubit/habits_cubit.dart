import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/data/habit_item.dart';
import '../../../core/data/habits_repository.dart';

class HabitsCubit extends Cubit<List<HabitWeek>> {
  HabitsCubit(this._repo) : super(const []) {
    load();
  }

  final HabitsRepository _repo;
  final List<DateTime> days = lastDays(7);

  void load() => emit(_repo.weeks(days));

  Future<void> add(HabitItem habit) async {
    await _repo.add(habit);
    load();
  }
}