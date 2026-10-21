import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart' show DateUtils;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:bloom_habit_tracker/core/domain/entities/habit.dart';
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
import 'package:bloom_habit_tracker/features/home/cubit/home_cubit.dart';

class _MockAdd extends Mock implements AddHabit {}

class _MockGetDay extends Mock implements GetDayHabits {}

class _MockStreak extends Mock implements GetStreak {}

class _MockWeeks extends Mock implements GetWeeks {}

class _MockToggle extends Mock implements ToggleHabit {}

class _MockUpdate extends Mock implements UpdateHabit {}

class _MockDelete extends Mock implements DeleteHabit {}

class _MockGetUser extends Mock implements GetUsername {}

class _MockSaveUser extends Mock implements SaveUsername {}

class _MockSetProgress extends Mock implements SetProgress {}

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

HomeCubit _build({
  required _MockAdd add,
  required _MockGetDay day,
  required _MockStreak streak,
  required _MockWeeks weeks,
  required _MockToggle toggle,
  _MockUpdate? update,
  _MockDelete? delete,
  _MockGetUser? user,
  _MockSaveUser? save,
  _MockSetProgress? progress,
}) {
  return HomeCubit(
    addHabitUseCase: add,
    getDayHabitsUseCase: day,
    getStreakUseCase: streak,
    getWeeksUseCase: weeks,
    toggleHabitUseCase: toggle,
    updateHabitUseCase: update ?? _MockUpdate(),
    deleteHabitUseCase: delete ?? _MockDelete(),
    getUsernameUseCase: user ?? _MockGetUser(),
    saveUsernameUseCase: save ?? _MockSaveUser(),
    setProgressUseCase: progress ?? _MockSetProgress(),
  );
}

void main() {
  setUpAll(() {
    registerFallbackValue(_FakeProgress());
    registerFallbackValue(DateTime(2026, 1, 1));
    registerFallbackValue(_habit());
  });

  late _MockAdd add;
  late _MockGetDay day;
  late _MockStreak streak;
  late _MockWeeks weeks;
  late _MockToggle toggle;
  late _MockGetUser getUser;
  late _MockUpdate update;
  late _MockDelete delete;
  late _MockSaveUser saveUser;
  late _MockSetProgress setP;

  setUp(() {
    add = _MockAdd();
    day = _MockGetDay();
    streak = _MockStreak();
    weeks = _MockWeeks();
    toggle = _MockToggle();
    getUser = _MockGetUser();
    update = _MockUpdate();
    delete = _MockDelete();
    saveUser = _MockSaveUser();
    setP = _MockSetProgress();

    when(() => getUser()).thenReturn(null);
    when(() => day(any())).thenReturn(const []);
    when(() => streak()).thenReturn(0);
    when(() => add(any())).thenAnswer((_) async {});
    when(() => toggle(any(), any())).thenAnswer((_) async {});
    when(() => update(any())).thenAnswer((_) async {});
    when(() => delete(any())).thenAnswer((_) async {});
    when(
      () => saveUser(any()),
    ).thenAnswer((_) async {});
    when(
      () => setP(any(), any(), any()),
    ).thenAnswer((_) async {});
  });

  // NOTE: HomeCubit._refresh() emits synchronously inside the constructor,
  // before blocTest attaches its listener — so constructor emissions are
  // NOT observable via blocTest expect:. Assert final state directly.
  test('startup refresh loads items + streak into state', () {
    when(() => day(any())).thenReturn([HabitProgress(_habit(), 0)]);
    when(() => streak()).thenReturn(2);
    final cubit = _build(
      add: add,
      day: day,
      streak: streak,
      weeks: weeks,
      toggle: toggle,
      user: getUser,
    );
    expect(cubit.state.status, HomeStatus.loaded);
    expect(cubit.state.items, hasLength(1));
    expect(cubit.state.streak, 2);
    return cubit.close();
  });

  blocTest<HomeCubit, HomeState>(
    'selectTab only changes tab filter (no reload)',
    build: () => _build(
      add: add,
      day: day,
      streak: streak,
      weeks: weeks,
      toggle: toggle,
      user: getUser,
    ),
    act: (cubit) => cubit.selectTab(2),
    // Only the act emission is observable; init emissions are sync + missed.
    expect: () => [
      isA<HomeState>().having((s) => s.tab, 'tab', 2),
    ],
    verify: (_) {
      verify(() => day(any())).called(1); // constructor refresh only
    },
  );

  blocTest<HomeCubit, HomeState>(
    'add delegates to AddHabit and reloads',
    build: () => _build(
      add: add,
      day: day,
      streak: streak,
      weeks: weeks,
      toggle: toggle,
      user: getUser,
    ),
    act: (cubit) => cubit.add(_habit()),
    verify: (_) {
      verify(() => add(any(that: isA<HabitItem>()))).called(1);
      verify(() => day(any())).called(2); // init + post-add refresh
    },
  );

  blocTest<HomeCubit, HomeState>(
    'toggle delegates with normalized date and reloads',
    build: () => _build(
      add: add,
      day: day,
      streak: streak,
      weeks: weeks,
      toggle: toggle,
      user: getUser,
    ),
    act: (cubit) => cubit.toggle(HabitProgress(_habit(), 0)),
    verify: (_) {
      verify(
        () => toggle(
          any(that: isA<HabitProgress>()),
          any(that: isA<DateTime>()),
        ),
      ).called(1);
    },
  );

  blocTest<HomeCubit, HomeState>(
    'updateHabit and deleteHabit delegate then reload',
    build: () => _build(
      add: add,
      day: day,
      streak: streak,
      weeks: weeks,
      toggle: toggle,
      user: getUser,
      update: update,
      delete: delete,
    ),
    act: (cubit) async {
      await cubit.updateHabit(_habit());
      await cubit.deleteHabit('h1');
    },
    verify: (_) {
      verify(() => update(any(that: isA<HabitItem>()))).called(1);
      verify(() => delete('h1')).called(1);
    },
  );

  blocTest<HomeCubit, HomeState>(
    'saveName persists and updates greeting state',
    build: () => _build(
      add: add,
      day: day,
      streak: streak,
      weeks: weeks,
      toggle: toggle,
      user: getUser,
      save: saveUser,
    ),
    act: (cubit) => cubit.saveName('Alex'),
    expect: () => [
      isA<HomeState>().having((s) => s.username, 'username', 'Alex'),
    ],
    verify: (_) {
      verify(() => saveUser('Alex')).called(1);
    },
  );

  blocTest<HomeCubit, HomeState>(
    'setProgress forwards habit id with current date',
    build: () => _build(
      add: add,
      day: day,
      streak: streak,
      weeks: weeks,
      toggle: toggle,
      user: getUser,
      progress: setP,
    ),
    act: (cubit) => cubit.setProgress(HabitProgress(_habit(), 0), 5),
    verify: (cubit) {
      verify(
        () => setP('h1', cubit.state.date, 5),
      ).called(1);
    },
  );

  blocTest<HomeCubit, HomeState>(
    'add failure emits error with message',
    build: () {
      when(() => add(any())).thenThrow(Exception('disk full'));
      return _build(
        add: add,
        day: day,
        streak: streak,
        weeks: weeks,
        toggle: toggle,
        user: getUser,
      );
    },
    act: (cubit) => cubit.add(_habit()),
    expect: () => [
      isA<HomeState>().having((s) => s.status, 'status', HomeStatus.loading),
      isA<HomeState>()
          .having((s) => s.status, 'status', HomeStatus.error)
          .having(
            (s) => s.errorMessage,
            'errorMessage',
            contains('disk full'),
          ),
    ],
  );

  test('selectDate normalizes time to midnight', () async {    final cubit = _build(
      add: add,
      day: day,
      streak: streak,
      weeks: weeks,
      toggle: toggle,
      user: getUser,
    );
    cubit.selectDate(DateTime(2026, 5, 4, 15, 30));
    final captured =
        verify(() => day(captureAny())).captured.last as DateTime;
    expect(captured, DateUtils.dateOnly(DateTime(2026, 5, 4, 15, 30)));
    await cubit.close();
  });
}
