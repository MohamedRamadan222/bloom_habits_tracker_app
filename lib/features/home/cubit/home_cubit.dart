import 'package:flutter/material.dart' show DateUtils;
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/domain/entities/habit.dart';
import '../../../../core/domain/usecases/add_habit.dart';
import '../../../../core/domain/usecases/get_day_habits.dart';
import '../../../../core/domain/usecases/get_streak.dart';
import '../../../../core/domain/usecases/get_weeks.dart';
import '../../../../core/domain/usecases/toggle_habit.dart';

enum HomeStatus { initial, loading, loaded, error }

class HomeState {
  final HomeStatus status;
  final String? errorMessage;
  final DateTime date;
  final int tab;
  final List<HabitProgress> items;
  final int streak;

  const HomeState({
    this.status = HomeStatus.initial,
    this.errorMessage,
    required this.date,
    required this.tab,
    required this.items,
    required this.streak,
  });

  List<HabitProgress> get visible =>
      tab == 0 ? items : items.where((e) => e.habit.period == tab - 1).toList();

  int get doneCount => items.where((e) => e.isDone).length;

  HomeState copyWith({
    HomeStatus? status,
    String? errorMessage,
    DateTime? date,
    int? tab,
    List<HabitProgress>? items,
    int? streak,
  }) => HomeState(
    status: status ?? this.status,
    errorMessage: errorMessage ?? this.errorMessage,
    date: date ?? this.date,
    tab: tab ?? this.tab,
    items: items ?? this.items,
    streak: streak ?? this.streak,
  );
}

class HomeCubit extends Cubit<HomeState> {
  final AddHabit addHabitUseCase;
  final GetDayHabits getDayHabitsUseCase;
  final GetStreak getStreakUseCase;
  final GetWeeks getWeeksUseCase;
  final ToggleHabit toggleHabitUseCase;

  HomeCubit({
    required this.addHabitUseCase,
    required this.getDayHabitsUseCase,
    required this.getStreakUseCase,
    required this.getWeeksUseCase,
    required this.toggleHabitUseCase,
  }) : super(
         HomeState(
           date: DateUtils.dateOnly(DateTime.now()),
           tab: 0,
           items: const [],
           streak: 0,
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
        state.copyWith(status: HomeStatus.loaded, items: items, streak: streak),
      );
    } catch (e) {
      emit(
        state.copyWith(status: HomeStatus.error, errorMessage: e.toString()),
      );
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
}
