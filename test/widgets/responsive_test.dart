import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:bloom_habit_tracker/main.dart';
import 'package:bloom_habit_tracker/core/domain/repositories/habits_repository.dart';
import 'package:bloom_habit_tracker/features/habits/cubit/habits_cubit.dart';
import 'package:bloom_habit_tracker/features/home/cubit/home_cubit.dart';
import 'package:bloom_habit_tracker/features/progress/cubit/progress_cubit.dart';
import 'package:bloom_habit_tracker/core/di/injection.dart';

// Phase A guard: the whole app + habit sheet must lay out with zero
// overflow on a 320dp-wide phone (the smallest we support).
void main() {
  setUpAll(() async {
    final tempDir = await Directory.systemTemp.createTemp('responsive_test');
    Hive.init(tempDir.path);
    await Hive.openBox('habits');
    await Hive.openBox('logs');
    await Hive.openBox('settings');
    await configureDependencies();
  });

  tearDownAll(() async {
    await Hive.deleteFromDisk();
    await sl.reset();
  });

  testWidgets('no overflow at 320dp across tabs + habit sheet', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<HomeCubit>(create: (_) => sl<HomeCubit>()),
          BlocProvider<HabitsCubit>(
            create: (_) => HabitsCubit(sl<HabitsRepository>()),
          ),
          BlocProvider<ProgressCubit>(create: (_) => sl<ProgressCubit>()),
        ],
        child: const MyApp(),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    for (final label in ['My habits', 'Progress', 'Discover', 'Today']) {
      await tester.tap(find.text(label));
      await tester.pumpAndSettle();
      expect(
        tester.takeException(),
        isNull,
        reason: 'overflow on tab $label at 320dp',
      );
    }

    // Habit sheet: icon picker row + description row used to overflow.
    await tester.tap(find.byIcon(LucideIcons.plus).first);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('no overflow at 360dp with large system fonts (1.3x)', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 740);
    tester.view.devicePixelRatio = 1.0;
    tester.platformDispatcher.textScaleFactorTestValue = 1.3;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
      tester.platformDispatcher.clearTextScaleFactorTestValue();
    });

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<HomeCubit>(create: (_) => sl<HomeCubit>()),
          BlocProvider<HabitsCubit>(
            create: (_) => HabitsCubit(sl<HabitsRepository>()),
          ),
          BlocProvider<ProgressCubit>(create: (_) => sl<ProgressCubit>()),
        ],
        child: const MyApp(),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    for (final label in ['My habits', 'Progress', 'Discover', 'Today']) {
      await tester.tap(find.text(label));
      await tester.pumpAndSettle();
      expect(
        tester.takeException(),
        isNull,
        reason: 'overflow on tab $label at 1.3x fonts',
      );
    }
  });
}
