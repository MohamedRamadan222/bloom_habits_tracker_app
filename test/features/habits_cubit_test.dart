import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:bloom_habit_tracker/core/domain/entities/habit.dart';
import 'package:bloom_habit_tracker/core/domain/repositories/habits_repository.dart';
import 'package:bloom_habit_tracker/features/habits/cubit/habits_cubit.dart';

class _MockRepo extends Mock implements HabitsRepository {}

class _FakeHabit extends Fake implements HabitItem {}

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
    registerFallbackValue(DateTime(2026, 1, 1));
  });

  late _MockRepo repo;

  setUp(() {
    repo = _MockRepo();
    when(() => repo.weeks(any())).thenReturn(const []);
    when(() => repo.add(any())).thenAnswer((_) async {});
  });

  test('constructor load emits weeks from repository', () {
    final weeks = [HabitWeek(_habit(), [true])];
    when(() => repo.weeks(any())).thenReturn(weeks);

    final cubit = HabitsCubit(repo);
    expect(cubit.state, weeks);
    verify(() => repo.weeks(any())).called(1);
    cubit.close();
  });

  test('add delegates then reloads weeks', () async {
    final cubit = HabitsCubit(repo);
    await cubit.add(_habit());

    verify(() => repo.add(any(that: isA<HabitItem>()))).called(1);
    verify(() => repo.weeks(any())).called(2); // init load + reload
    await cubit.close();
  });

  test('reload re-queries weeks', () {
    final cubit = HabitsCubit(repo);
    cubit.reload();
    verify(() => repo.weeks(any())).called(2);
    cubit.close();
  });
}
