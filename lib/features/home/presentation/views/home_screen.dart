import 'package:bloom_habit_tracker/features/home/presentation/widgets/amount_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/data/habit_item.dart';
import '../../../../core/theme/responsive.dart';
import '../../../../core/widgets/calendar_header.dart';
import '../../../../core/widgets/custom_header.dart';
import '../../../../core/widgets/daily_summary.dart';
import '../../../habits/cubit/habits_cubit.dart';
import '../../cubit/home_cubit.dart';
import '../widgets/daily_habit.dart';
import '../widgets/habit_draft.dart';
import '../widgets/home_banner.dart';
import '../widgets/segmented_tabs.dart';
import '../widgets/title_and_count_widget.dart';

class HomeScreen extends StatelessWidget {
  final VoidCallback onMyHabitsTap;
  final VoidCallback onProgressTap;

  const HomeScreen({
    super.key,
    required this.onMyHabitsTap,
    required this.onProgressTap,
  });

  String _subtitle(HabitProgress e) {
    final h = e.habit;
    final status = e.isDone
        ? ' · Done'
        : e.done > 0
        ? ' · ${e.done}/${h.goal}'
        : '';
    return '${h.goal} ${h.unit} · ${safePeriod(h.period).label}$status';
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<HomeCubit>();
    final s = context.watch<HomeCubit>().state;
    final visible = s.visible;

    return Scaffold(
      body: CenteredContent(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const Gap(8),
              PageHeader.home(
                title: 'A good day to grow.',
                subtitle: s.username != null && s.username!.isNotEmpty
                    ? 'Hello, ${s.username}'
                    : 'Hello, friend',
                onActionPressed: () {
                  final habitsCubit = context.read<HabitsCubit>();
                  showHabitSheet(
                    context,
                    onSave: (habit) async {
                      await cubit.add(habit);
                      habitsCubit.reload();
                    },
                  );
                },
              ),
              const Gap(23),
              const HomeBanner(),
              const Gap(14),
              DailySummary(
                onTap: onProgressTap,
                done: s.doneCount,
                total: s.items.length,
                streakDays: s.streak,
              ),
              const Gap(24),
              WeekCalendar(
                selectedDate: s.date,
                onDateSelected: cubit.selectDate,
              ),
              const Gap(24),
              TitleAndCountWidget(
                count: visible.length,
                onPressed: onMyHabitsTap,
              ),
              const Gap(12),
              SegmentedTabs(
                labels: const ['All habits', 'Morning', 'Afternoon', 'Evening'],
                selectedIndex: s.tab,
                onChanged: cubit.selectTab,
              ),
              const Gap(15),
              if (visible.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 32),
                  child: Text('Nothing planted yet. Tap + to begin.'),
                ),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: visible.length,
                separatorBuilder: (_, _) => const Gap(10),
                itemBuilder: (context, i) {
                  final e = visible[i];
                  return HabitCard(
                    icon: safeHabitIcon(e.habit.iconIndex),
                    name: e.habit.name,
                    subtitle: _subtitle(e),
                    isDone: e.isDone,
                    onTap: () {
                      final habitsCubit = context.read<HabitsCubit>();
                      showAmountSheet(
                        context,
                        progress: e,
                        date: s.date,
                        onSave: (amount) async {
                          await cubit.setProgress(e, amount);
                          habitsCubit.reload();
                        },
                        onEdit: () {
                          showHabitSheet(
                            context,
                            initial: e.habit,
                            onSave: (habit) async {
                              await cubit.updateHabit(habit);
                              habitsCubit.reload();
                            },
                          );
                        },
                      );
                    },
                    onToggle: () => cubit.toggle(e),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
