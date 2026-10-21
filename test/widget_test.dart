import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:bloom_habit_tracker/main.dart';
import 'package:bloom_habit_tracker/core/domain/repositories/habits_repository.dart';
import 'package:bloom_habit_tracker/features/habits/cubit/habits_cubit.dart';
import 'package:bloom_habit_tracker/features/home/cubit/home_cubit.dart';
import 'package:bloom_habit_tracker/features/progress/cubit/progress_cubit.dart';
import 'package:bloom_habit_tracker/core/di/injection.dart';

void main() {
  setUpAll(() async {
    final tempDir = await Directory.systemTemp.createTemp('hive_test');
    Hive.init(tempDir.path);

    // Open boxes directly: HabitsRepositoryImpl.init() calls
    // Hive.initFlutter() which needs path_provider (unavailable in tests).
    await Hive.openBox('habits');
    await Hive.openBox('logs');
    await Hive.openBox('settings');

    // تشغيل الـ Service Locator في الاختبار
    await configureDependencies();
  });

  tearDownAll(() async {
    await Hive.deleteFromDisk();
    await sl.reset();
  });

  testWidgets('App starts and renders its navigation', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<HomeCubit>(create: (_) => sl<HomeCubit>()),
          BlocProvider<HabitsCubit>(create: (_) => HabitsCubit(sl<HabitsRepository>())),
          BlocProvider<ProgressCubit>(create: (_) => sl<ProgressCubit>()),
        ],
        child: const MyApp(),
      ),
    );

    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.byType(NavigationDestination), findsNWidgets(4));

    expect(find.text('Today'), findsOneWidget);
    expect(find.text('My habits'), findsOneWidget);
    expect(find.text('Progress'), findsOneWidget);
    expect(find.text('Discover'), findsOneWidget);
  });
}