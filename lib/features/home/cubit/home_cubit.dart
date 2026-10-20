import 'package:flutter/material.dart' show DateUtils;
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/data/habit_item.dart';
import '../../../../core/data/habits_repository.dart';

class HomeState {
  final DateTime date;
  final int tab;
  final List<HabitProgress> items;
  final int streak;

  const HomeState({
    required this.date,
    required this.tab,
    required this.items,
    required this.streak,
  });

  List<HabitProgress> get visible =>
      tab == 0 ? items : items.where((e) => e.habit.period == tab - 1).toList();

  int get doneCount => items.where((e) => e.isDone).length;

  HomeState copyWith({
    DateTime? date,
    int? tab,
    List<HabitProgress>? items,
    int? streak,
  }) =>
      HomeState(
        date: date ?? this.date,
        tab: tab ?? this.tab,
        items: items ?? this.items,
        streak: streak ?? this.streak,
      );
}

class HomeCubit extends Cubit<HomeState> {
  HomeCubit(this._repo)
      : super(HomeState(
    date: DateUtils.dateOnly(DateTime.now()),
    tab: 0,
    items: const [],
    streak: 0,
  )) {
    _refresh();
  }

  final HabitsRepository _repo;

  void _refresh([DateTime? date]) {
    final d = date ?? state.date;
    emit(state.copyWith(date: d, items: _repo.forDay(d), streak: _repo.streak()));
  }

  void selectDate(DateTime d) => _refresh(DateUtils.dateOnly(d));

  void selectTab(int i) => emit(state.copyWith(tab: i));

  Future<void> add(HabitItem h) async {
    await _repo.add(h);
    _refresh();
  }

  Future<void> toggle(HabitProgress e) async {
    await _repo.setProgress(e.habit.id, state.date, e.isDone ? 0 : e.habit.goal);
    _refresh();
  }
  void reload() => _refresh();
}