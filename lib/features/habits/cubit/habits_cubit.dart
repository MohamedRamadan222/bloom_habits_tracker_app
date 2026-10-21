import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/data/habit_item.dart';

import '../../../core/domain/repositories/habits_repository.dart';

class HabitsCubit extends Cubit<List<HabitWeek>> {
  HabitsCubit(this._repo) : super(const []) {
    load();
  }

  final HabitsRepository _repo;
  final List<DateTime> days = lastDays(7);
  
  void load() => emit(List.from(_repo.weeks(days)));

  void reload() => load();

  Future<void> add(HabitItem habit) async {
    await _repo.add(habit);
    load();
  }
}
