import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/domain/repositories/habits_repository.dart';

class DailyStat {
  final DateTime date;
  final int percentage;

  DailyStat({required this.date, required this.percentage});
}

class ProgressState {
  final bool isLoading;
  final int streak;
  final int littleWins;
  final int consistency;
  final int weekWins;
  final List<DailyStat> last7Days;

  ProgressState({
    this.isLoading = true,
    this.streak = 0,
    this.littleWins = 0,
    this.consistency = 0,
    this.weekWins = 0,
    this.last7Days = const [],
  });
}

class ProgressCubit extends Cubit<ProgressState> {
  final HabitsRepository repository;

  ProgressCubit({required this.repository}) : super(ProgressState()) {
    loadStats();
  }

  void loadStats() {
    emit(ProgressState(isLoading: true));

    final streak = repository.streak();

    int totalWins = 0;
    int totalExpected = 0;
    int weekWins = 0;
    List<DailyStat> last7 = [];

    final now = DateTime.now();

    for (int i = 29; i >= 0; i--) {
      final d = now.subtract(Duration(days: i));
      final progressList = repository.forDay(d);

      int dayWins = progressList.where((p) => p.isDone).length;
      int dayExpected = progressList.length;

      totalWins += dayWins;
      totalExpected += dayExpected;

      if (i < 7) {
        weekWins += dayWins;
        int pct = dayExpected == 0
            ? 0
            : ((dayWins / dayExpected) * 100).round();
        last7.add(DailyStat(date: d, percentage: pct));
      }
    }

    int consistency = totalExpected == 0
        ? 0
        : ((totalWins / totalExpected) * 100).round();

    emit(
      ProgressState(
        isLoading: false,
        streak: streak,
        littleWins: totalWins,
        consistency: consistency,
        weekWins: weekWins,
        last7Days: last7,
      ),
    );
  }
}
