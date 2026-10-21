import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/responsive.dart';
import '../../../../core/widgets/custom_header.dart';
import '../../../habits/cubit/habits_cubit.dart';
import '../../../home/cubit/home_cubit.dart';
import '../../../home/presentation/widgets/habit_draft.dart';
import '../../cubit/progress_cubit.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  void _openAddHabit(BuildContext context) {
    final homeCubit = context.read<HomeCubit>();
    final habitsCubit = context.read<HabitsCubit>();
    final progressCubit = context.read<ProgressCubit>();
    showHabitSheet(
      context,
      onSave: (habit) async {
        await homeCubit.add(habit);
        habitsCubit.reload();
        progressCubit.loadStats();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<ProgressCubit, ProgressState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return CenteredContent(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Gap(8),
                      // الهيدر زي الديزاين[cite: 4]
                      PageHeader.page(
                        title: "Look how far\nyou've grown.",
                        subtitle: "Every little effort adds up. Here's your story so far.",
                        onActionPressed: () => _openAddHabit(context),
                      ),
                      const Gap(24),

                      // كروت الإحصائيات الـ 3[cite: 4]
                      IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: _StatCard(
                                icon: LucideIcons.flame,
                                title: 'Current streak',
                                value: '${state.streak} days',
                                subtitle: 'Days with a\ncompleted habit',
                              ),
                            ),
                            const Gap(12),
                            Expanded(
                              child: _StatCard(
                                icon: LucideIcons.check,
                                title: 'Little wins',
                                value: '${state.littleWins}',
                                subtitle: 'Habits done in 30\ndays',
                              ),
                            ),
                            const Gap(12),
                            Expanded(
                              child: _StatCard(
                                icon: LucideIcons.barChart2,
                                title: 'Consistency',
                                value: '${state.consistency}%',
                                subtitle: 'Completion over 30\ndays',
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Gap(24),

                      // الرسم البياني للأسبوع[cite: 4]
                      _WeekAtGlanceChart(
                        last7Days: state.last7Days,
                        weekWins: state.weekWins,
                      ),
                      const Gap(24),

                      // حديقة الإنجازات (شكل مبدئي يطابق الديزاين)[cite: 4]
                      _GardenOfWins(days: state.last7Days),
                      const Gap(32),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String subtitle;

  const _StatCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 10, color: AppColors.primaryColor),
              const Gap(3),
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    title,
                    maxLines: 1,
                    style: const TextStyle(fontSize: 10, color: AppColors.muted),
                  ),
                ),
              ),
            ],
          ),
          const Gap(10),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              maxLines: 1,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.ink,
                letterSpacing: -0.5,
              ),
            ),
          ),
          const Gap(6),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 9, color: AppColors.muted, height: 1.35),
          ),
        ],
      ),
    );
  }
}

class _WeekAtGlanceChart extends StatelessWidget {
  final List<DailyStat> last7Days;
  final int weekWins;

  const _WeekAtGlanceChart({required this.last7Days, required this.weekWins});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Text(
                  'Your week at a glance',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                ),
              ),
              Text(
                'Last 7 days',
                style: TextStyle(fontSize: 11, color: AppColors.muted),
              ),
            ],
          ),
          const Gap(24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Expanded: each bar gets an equal share, so wide '%'
              // labels ellipsize instead of overflowing the row.
              for (var i = 0; i < last7Days.length; i++)
                Expanded(
                  child: _Bar(
                    stat: last7Days[i],
                    isToday: i == last7Days.length - 1,
                  ),
                ),
            ],
          ),
          const Gap(24),
          const Divider(color: AppColors.cardBorder, height: 1),
          const Gap(16),
          Text(
            '$weekWins little wins. A week of making time for you.',
            style: TextStyle(fontSize: 12, color: AppColors.muted),
          ),
        ],
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  final DailyStat stat;
  final bool isToday;
  const _Bar({required this.stat, this.isToday = false});

  @override
  Widget build(BuildContext context) {
    final dayName = DateFormat('E').format(stat.date);
    const double maxHeight = 120;
    final double filledHeight = (stat.percentage / 100) * maxHeight;
    final Color fillColor = isToday || stat.percentage == 100
        ? AppColors.primaryColor
        : AppColors.chartBar;

    return Column(
      children: [
        Text(
          '${stat.percentage}%',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 10, color: AppColors.muted),
        ),
        const Gap(8),
        Container(
          width: 28,
          height: maxHeight,
          decoration: BoxDecoration(
            color: AppColors.chartTrack,
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.bottomCenter,
          child: stat.percentage > 0
              ? Container(
            width: 28,
            height: filledHeight.clamp(8.0, maxHeight),
            decoration: BoxDecoration(
              color: fillColor,
              borderRadius: BorderRadius.circular(8),
            ),
          )
              : const SizedBox.shrink(),
        ),
        const Gap(12),
        Text(
          dayName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isToday ? FontWeight.w800 : FontWeight.w400,
            color: isToday ? AppColors.primaryColor : AppColors.muted,
          ),
        ),
      ],
    );
  }
}

class _GardenOfWins extends StatelessWidget {
  final List<DailyStat> days;
  const _GardenOfWins({required this.days});

  Color _domeColor(int pct, bool isToday) {
    if (pct == 100 || isToday && pct > 0) return AppColors.primaryColor;
    if (pct > 0) return AppColors.chartBar;
    return AppColors.lavender;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Text(
                  'A garden of little wins',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                ),
              ),
              Icon(LucideIcons.sprout, size: 16, color: AppColors.primaryColor),
            ],
          ),
          const Gap(24),
          // Dome width adapts: fixed 36px overflowed below ~340dp.
          LayoutBuilder(
            builder: (context, constraints) {
              final dome = (constraints.maxWidth / 7).clamp(24.0, 36.0);
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  for (var i = 0; i < days.length; i++)
                    Column(
                      children: [
                        Text(
                          DateFormat('E').format(days[i].date)[0],
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: i == days.length - 1
                                ? FontWeight.w800
                                : FontWeight.w400,
                            color: i == days.length - 1
                                ? AppColors.primaryColor
                                : AppColors.muted,
                          ),
                        ),
                        const Gap(12),
                        Container(
                          width: dome,
                          height: 18,
                          decoration: BoxDecoration(
                            color: _domeColor(
                              days[i].percentage,
                              i == days.length - 1,
                            ),
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(36),
                            ),
                            border: i == days.length - 1
                                ? Border.all(
                                    color: AppColors.primaryColor,
                                    width: 1.5,
                                  )
                                : null,
                          ),
                        ),
                      ],
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}