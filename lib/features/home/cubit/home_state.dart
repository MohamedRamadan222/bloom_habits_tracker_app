part of 'home_cubit.dart';

enum HomeStatus { initial, loading, loaded, error }

class HomeState {
  final HomeStatus status;
  final String? errorMessage;
  final DateTime date;
  final int tab;
  final List<HabitProgress> items;
  final int streak;
  final String? username;

  const HomeState({
    this.status = HomeStatus.initial,
    this.errorMessage,
    required this.date,
    required this.tab,
    required this.items,
    required this.streak,
    this.username, // 👈
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
    String? username,
  }) => HomeState(
    status: status ?? this.status,
    errorMessage: errorMessage ?? this.errorMessage,
    date: date ?? this.date,
    tab: tab ?? this.tab,
    items: items ?? this.items,
    streak: streak ?? this.streak,
    username: username ?? this.username,
  );
}
