import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/theme/app_colors.dart';

class WeekStrip extends StatelessWidget {
  final List<DateTime> days;
  final List<bool> done;

  const WeekStrip({super.key, required this.days, required this.done});

  static const _letters = 'MTWTFSS';

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        for (var i = 0; i < days.length; i++)
          Column(
            children: [
              Text(
                _letters[days[i].weekday - 1],
                style: TextStyle(fontSize: 10, color: AppColors.muted),
              ),
              const SizedBox(height: 8),
              _DayDot(done: done[i]),
            ],
          ),
      ],
    );
  }
}

class _DayDot extends StatelessWidget {
  final bool done;

  const _DayDot({required this.done});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30,
      height: 30,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: done ? AppColors.lavender : AppColors.surfaceSubtle,
      ),
      child: done
          ? Icon(LucideIcons.check, size: 14, color: AppColors.primaryColor)
          : Container(
        width: 3,
        height: 3,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.muted,
        ),
      ),
    );
  }
}