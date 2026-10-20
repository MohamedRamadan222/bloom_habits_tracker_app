import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/data/habit_item.dart';
import '../../../../core/theme/app_colors.dart';
import 'week_strip.dart';

class HabitOverviewCard extends StatelessWidget {
  final HabitWeek week;
  final List<DateTime> days;
  final VoidCallback? onEdit;
  final VoidCallback? onView;

  const HabitOverviewCard({
    super.key,
    required this.week,
    required this.days,
    this.onEdit,
    this.onView,
  });

  @override
  Widget build(BuildContext context) {
    final habit = week.habit;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xffEEECF2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: Color(habit.colorValue),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  safeHabitIcon(habit.iconIndex),
                  size: 22,
                  color: const Color(0xff9B82C0),
                ),
              ),
              _EditButton(onTap: onEdit),
            ],
          ),
          const Gap(14),
          Text(
            habit.name,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.ink,
            ),
          ),
          const Gap(4),
          Text(
            '${habit.goal} ${habit.unit} every day',
            style: TextStyle(fontSize: 12, color: AppColors.muted),
          ),
          const Gap(16),
          WeekStrip(days: days, done: week.done),
          const Gap(16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _PeriodChip(label: safePeriod(habit.period).label),
              TextButton(
                onPressed: onView,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  foregroundColor: AppColors.primaryColor,
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('View habit', style: TextStyle(fontSize: 12)),
                    Gap(4),
                    Icon(LucideIcons.chevronRight, size: 14),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EditButton extends StatelessWidget {
  final VoidCallback? onTap;

  const _EditButton({this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      customBorder: const CircleBorder(),
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xffEEECF2)),
        ),
        child: Icon(LucideIcons.pencil, size: 15, color: AppColors.muted),
      ),
    );
  }
}

class _PeriodChip extends StatelessWidget {
  final String label;

  const _PeriodChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xffF4F2F8),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 11, color: AppColors.muted),
      ),
    );
  }
}