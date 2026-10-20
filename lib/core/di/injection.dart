import 'package:get_it/get_it.dart';

import '../../features/home/cubit/home_cubit.dart';
import '../data/habits_repository.dart';
import '../domain/repositories/habits_repository.dart';


import '../domain/usecases/add_habit.dart';
import '../domain/usecases/get_day_habits.dart';
import '../domain/usecases/get_streak.dart';
import '../domain/usecases/get_weeks.dart';
import '../domain/usecases/toggle_habit.dart';

final sl = GetIt.instance;

Future<void> configureDependencies() async {
  sl.registerLazySingleton<HabitsRepository>(() => HabitsRepositoryImpl());

  sl.registerLazySingleton(() => AddHabit(sl()));
  sl.registerLazySingleton(() => GetDayHabits(sl()));
  sl.registerLazySingleton(() => GetStreak(sl()));
  sl.registerLazySingleton(() => GetWeeks(sl()));
  sl.registerLazySingleton(() => ToggleHabit(sl()));

  sl.registerFactory(
        () => HomeCubit(
      addHabit: sl(),
      getDayHabits: sl(),
      getStreak: sl(),
      getWeeks: sl(),
      toggleHabit: sl(),
    ),
  );
}