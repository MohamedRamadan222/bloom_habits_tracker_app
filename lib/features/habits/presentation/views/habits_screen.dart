import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

import '../../../../core/data/habits_repository.dart';
import '../../../../core/widgets/custom_header.dart';
import '../../../home/cubit/home_cubit.dart';
import '../../../home/presentation/widgets/habit_draft.dart';
import '../../cubit/habits_cubit.dart';
import '../widgets/habit_overview_card.dart';

class HabitsScreen extends StatelessWidget {
  const HabitsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => HabitsCubit(HabitsRepository()),
      child: const _HabitsView(),
    );
  }
}

class _HabitsView extends StatelessWidget {
  const _HabitsView();

  Future<void> _addHabit(BuildContext context) {
    final habits = context.read<HabitsCubit>();
    final home = context.read<HomeCubit>();
    return showHabitSheet(
      context,
      onSave: (habit) async {
        await habits.add(habit);
        home.reload();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<HabitsCubit>();
    final weeks = context.watch<HabitsCubit>().state;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const Gap(8),
            PageHeader.page(
              title: 'Little things,\nbig changes.',
              subtitle: '${weeks.length} habits to help you feel more like you.',
              onActionPressed: () => _addHabit(context),
            ),
            const Gap(20),
            Expanded(
              child: weeks.isEmpty
                  ? const Center(child: Text('Nothing planted yet. Tap + to begin.'))
                  : ListView.separated(
                padding: const EdgeInsets.only(bottom: 16),
                itemCount: weeks.length,
                separatorBuilder: (_, _) => const Gap(14),
                itemBuilder: (_, i) => HabitOverviewCard(
                  week: weeks[i],
                  days: cubit.days,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}