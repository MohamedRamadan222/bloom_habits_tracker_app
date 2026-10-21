import 'package:flutter/material.dart' show DateUtils;
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/domain/entities/habit.dart';
import '../../../../core/domain/usecases/add_habit.dart';
import '../../../../core/domain/usecases/get_day_habits.dart';
import '../../../../core/domain/usecases/get_streak.dart';
import '../../../../core/domain/usecases/get_weeks.dart';
import '../../../../core/domain/usecases/toggle_habit.dart';
import '../../../../core/domain/usecases/delete_habit.dart';
import '../../../../core/domain/usecases/update_habit.dart';
import '../../../../core/domain/usecases/get_username.dart'; // 👈
import '../../../../core/domain/usecases/save_username.dart';
import '../../../../core/domain/usecases/set_progress.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final AddHabit addHabitUseCase;
  final GetDayHabits getDayHabitsUseCase;
  final GetStreak getStreakUseCase;
  final GetWeeks getWeeksUseCase;
  final ToggleHabit toggleHabitUseCase;
  final UpdateHabit updateHabitUseCase;
  final DeleteHabit deleteHabitUseCase;
  final GetUsername getUsernameUseCase;
  final SaveUsername saveUsernameUseCase;
  final SetProgress setProgressUseCase;

  HomeCubit({
    required this.addHabitUseCase,
    required this.setProgressUseCase,
    required this.getDayHabitsUseCase,
    required this.getStreakUseCase,
    required this.getWeeksUseCase,
    required this.toggleHabitUseCase,
    required this.updateHabitUseCase,
    required this.deleteHabitUseCase,
    required this.getUsernameUseCase,
    required this.saveUsernameUseCase,
  }) : super(
         HomeState(
           date: DateUtils.dateOnly(DateTime.now()),
           tab: 0,
           items: const [],
           streak: 0,
           username: getUsernameUseCase(),
         ),
       ) {
    _refresh();
  }

  Future<void> _refresh([DateTime? date]) async {
    final d = date ?? state.date;
    emit(state.copyWith(status: HomeStatus.loading, date: d));

    try {
      final items = getDayHabitsUseCase(d);
      final streak = getStreakUseCase();
      emit(
        state.copyWith(
          status: HomeStatus.loaded,
          items: List.from(items),
          streak: streak,
        ),
      );
    } catch (e) {
      emit(state.copyWith(status: HomeStatus.error, errorMessage: e.toString()));
    }
  }

  void selectDate(DateTime d) => _refresh(DateUtils.dateOnly(d));

  void selectTab(int i) => emit(state.copyWith(tab: i));

  Future<void> add(HabitItem h) async {
    emit(state.copyWith(status: HomeStatus.loading));
    try {
      await addHabitUseCase(h);
      _refresh();
    } catch (e) {
      emit(
        state.copyWith(status: HomeStatus.error, errorMessage: e.toString()),
      );
    }
  }

  Future<void> toggle(HabitProgress e) async {
    try {
      await toggleHabitUseCase(e, state.date);
      _refresh();
    } catch (error) {
      emit(
        state.copyWith(
          status: HomeStatus.error,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  void reload() => _refresh();

  Future<void> updateHabit(HabitItem h) async {
    emit(state.copyWith(status: HomeStatus.loading));
    try {
      await updateHabitUseCase(h);
      _refresh();
    } catch (e) {
      emit(
        state.copyWith(status: HomeStatus.error, errorMessage: e.toString()),
      );
    }
  }

  Future<void> deleteHabit(String id) async {
    emit(state.copyWith(status: HomeStatus.loading));
    try {
      await deleteHabitUseCase(id);
      _refresh();
    } catch (e) {
      emit(
        state.copyWith(status: HomeStatus.error, errorMessage: e.toString()),
      );
    }
  }

  Future<void> saveName(String name) async {
    await saveUsernameUseCase(name);
    emit(state.copyWith(username: name));
  }

  Future<void> setProgress(HabitProgress e, int amount) async {
    try {
      await setProgressUseCase(e.habit.id, state.date, amount);
    } catch (e) {
      emit(
        state.copyWith(status: HomeStatus.error, errorMessage: e.toString()),
      );
    }
  }
}
