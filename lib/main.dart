import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/di/injection.dart';
import 'core/data/habits_repository.dart';
import 'features/home/cubit/home_cubit.dart';
import 'features/main_layout.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await HabitsRepositoryImpl.init();

  await configureDependencies();

  runApp(
    BlocProvider(
      create: (_) => sl<HomeCubit>(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          scrolledUnderElevation: 0,
          surfaceTintColor: Colors.transparent,
        ),
        fontFamily: 'Manrope',
      ),
      debugShowCheckedModeBanner: false,
      title: 'bloom habit tracker',
      home: const MainLayout(),
    );
  }
}