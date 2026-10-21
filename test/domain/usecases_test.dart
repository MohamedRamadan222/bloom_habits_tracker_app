import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:bloom_habit_tracker/core/data/settings_datasource.dart';
import 'package:bloom_habit_tracker/core/domain/entities/habit.dart';
import 'package:bloom_habit_tracker/core/domain/repositories/habits_repository.dart';
import 'package:bloom_habit_tracker/core/domain/usecases/add_habit.dart';
import 'package:bloom_habit_tracker/core/domain/usecases/delete_habit.dart';
import 'package:bloom_habit_tracker/core/domain/usecases/get_day_habits.dart';
import 'package:bloom_habit_tracker/core/domain/usecases/get_streak.dart';
import 'package:bloom_habit_tracker/core/domain/usecases/get_username.dart';
import 'package:bloom_habit_tracker/core/domain/usecases/get_weeks.dart';
import 'package:bloom_habit_tracker/core/domain/usecases/save_username.dart';
import 'package:bloom_habit_tracker/core/domain/usecases/set_progress.dart';
import 'package:bloom_habit_tracker/core/domain/usecases/toggle_habit.dart';
import 'package:bloom_habit_tracker/core/domain/usecases/update_habit.dart';

class _MockRepo extends Mock implements HabitsRepository {}

class _MockSettings extends Mock implements SettingsDatasource {}

class _FakeHabit extends Fake implements HabitItem {}

class _FakeProgress extends Fake implements HabitProgress {}

HabitItem _habit() => HabitItem(
  id: 'h1',
  name: 'Water',
  iconIndex: 0,
  goal: 8,
  unit: 'glasses',
  period: 0,
  colorValue: 0xFFE9E5F7,
  createdAt: 0,
);

void main() {
  setUpAll(() {
    registerFallbackValue(_FakeHabit());
    registerFallbackValue(_FakeProgress());
    registerFallbackValue(DateTime(2026, 1, 1));
  });

  late _MockRepo repo;
  late _MockSettings settings;

  setUp(() {
    repo = _MockRepo();
    settings = _MockSettings();
    when(() => repo.add(any())).thenAnswer((_) async {});
    when(() => repo.update(any())).thenAnswer((_) async {});
    when(() => repo.delete(any())).thenAnswer((_) async {});
    when(() => repo.setProgress(any(), any(), any())).thenAnswer((_) async {});
  });

  test('AddHabit / UpdateHabit / DeleteHabit delegate to repository', () async {
    final habit = _habit();
    await AddHabit(repo)(habit);
    await UpdateHabit(repo)(habit);
    await DeleteHabit(repo)('h1');
    verify(() => repo.add(habit)).called(1);
    verify(() => repo.update(habit)).called(1);
    verify(() => repo.delete('h1')).called(1);
  });

  test('ToggleHabit writes 0 when done, goal when not done', () async {
    final date = DateTime(2026, 5, 4);
    await ToggleHabit(repo)(HabitProgress(_habit(), 8), date); // done
    await ToggleHabit(repo)(HabitProgress(_habit(), 3), date); // partial
    verify(() => repo.setProgress('h1', date, 0)).called(1);
    verify(() => repo.setProgress('h1', date, 8)).called(1);
  });

  test('SetProgress passes id/date/amount through', () async {
    final date = DateTime(2026, 5, 4);
    await SetProgress(repo)('h1', date, 5);
    verify(() => repo.setProgress('h1', date, 5)).called(1);
  });

  test('GetDayHabits / GetWeeks / GetStreak return repository data', () {
    final date = DateTime(2026, 5, 4);
    when(() => repo.forDay(date)).thenReturn([HabitProgress(_habit(), 2)]);
    when(() => repo.weeks(any())).thenReturn(const []);
    when(() => repo.streak()).thenReturn(4);

    expect(GetDayHabits(repo)(date), hasLength(1));
    expect(GetWeeks(repo)([date]), isEmpty);
    expect(GetStreak(repo)(), 4);
  });

  test('GetUsername / SaveUsername delegate to settings datasource', () async {
    when(() => settings.getUsername()).thenReturn('Alex');
    when(() => settings.saveUsername(any())).thenAnswer((_) async {});

    expect(GetUsername(settings)(), 'Alex');
    await SaveUsername(settings)('Alex');
    verify(() => settings.saveUsername('Alex')).called(1);
  });
}
