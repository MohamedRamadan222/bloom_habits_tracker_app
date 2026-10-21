import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:bloom_habit_tracker/core/domain/entities/habit.dart';
import 'package:bloom_habit_tracker/core/domain/repositories/habits_repository.dart';
import 'package:bloom_habit_tracker/features/progress/cubit/progress_cubit.dart';

class _MockRepo extends Mock implements HabitsRepository {}

HabitItem _habit({String id = 'h1', int goal = 1}) => HabitItem(
  id: id,
  name: 'Water',
  iconIndex: 0,
  goal: goal,
  unit: 'glasses',
  period: 0,
  colorValue: 0xFFE9E5F7,
  createdAt: 0,
);

void main() {
  late _MockRepo repo;

  setUp(() {
    repo = _MockRepo();
    when(() => repo.streak()).thenReturn(0);
    when(() => repo.forDay(any())).thenReturn(const []);
  });

  test('empty store loads zeros without dividing by zero', () {
    final cubit = ProgressCubit(repository: repo);
    final s = cubit.state;
    expect(s.isLoading, isFalse);
    expect(s.streak, 0);
    expect(s.consistency, 0);
    expect(s.littleWins, 0);
    expect(s.last7Days, hasLength(7));
    expect(s.last7Days.every((d) => d.percentage == 0), isTrue);
    cubit.close();
  });

  test('counts wins and streak from repository', () {
    when(() => repo.streak()).thenReturn(3);
    when(
      () => repo.forDay(any()),
    ).thenReturn([HabitProgress(_habit(), 1)]); // done every day

    final cubit = ProgressCubit(repository: repo);
    final s = cubit.state;
    expect(s.streak, 3);
    expect(s.littleWins, 30);
    expect(s.consistency, 100);
    expect(s.weekWins, 7);
    cubit.close();
  });

  test('partial days lower consistency', () {
    when(
      () => repo.forDay(any()),
    ).thenReturn([HabitProgress(_habit(goal: 2), 1)]); // never done

    final cubit = ProgressCubit(repository: repo);
    expect(cubit.state.consistency, 0);
    expect(cubit.state.littleWins, 0);
    cubit.close();
  });
}
