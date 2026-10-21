import 'package:hive_ce/hive.dart';

import '../../features/progress/cubit/progress_cubit.dart';
import '../domain/usecases/set_progress.dart';
import '../domain/usecases/update_habit.dart';
import '../domain/usecases/delete_habit.dart';

import 'package:get_it/get_it.dart';

import '../../features/home/cubit/home_cubit.dart';
import '../data/habits_repository.dart';
import '../domain/repositories/habits_repository.dart';
import '../data/settings_datasource.dart';
import '../domain/usecases/save_username.dart';
import '../domain/usecases/get_username.dart';
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
  sl.registerLazySingleton(() => UpdateHabit(sl()));
  sl.registerLazySingleton(() => DeleteHabit(sl()));
  sl.registerLazySingleton(() => SetProgress(sl()));
  sl.registerFactory(() => ProgressCubit(repository: sl()));

  // Settings
  sl.registerLazySingleton(() => SettingsDatasource(Hive.box('settings')));
  sl.registerLazySingleton(() => SaveUsername(sl()));
  sl.registerLazySingleton(() => GetUsername(sl()));

  sl.registerFactory(
    () => HomeCubit(
      addHabitUseCase: sl(),
      getDayHabitsUseCase: sl(),
      getStreakUseCase: sl(),
      getWeeksUseCase: sl(),
      toggleHabitUseCase: sl(),
      updateHabitUseCase: sl(),
      deleteHabitUseCase: sl(),
      getUsernameUseCase: sl(),
      saveUsernameUseCase: sl(),
      setProgressUseCase: sl(),
    ),
  );
}
