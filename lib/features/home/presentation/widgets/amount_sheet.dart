import 'dart:math';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/domain/entities/habit.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/close_button_sheet.dart';

Future<void> showAmountSheet(
  BuildContext context, {
  required HabitProgress progress,
  required DateTime date,
  required ValueChanged<int> onSave,
  VoidCallback? onEdit,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: AppColors.scrim.withValues(alpha: 0.35),
    builder: (_) => ShowAmountSheet(
      progress: progress,
      date: date,
      onSave: onSave,
      onEdit: onEdit,
    ),
  );
}

class ShowAmountSheet extends StatefulWidget {
  const ShowAmountSheet({
    super.key,
    required this.progress,
    required this.date,
    required this.onSave,
    this.onEdit,
  });

  final HabitProgress progress;
  final DateTime date;
  final ValueChanged<int> onSave;
  final VoidCallback? onEdit;

  @override
  State<ShowAmountSheet> createState() => _ShowAmountSheetState();
}

class _ShowAmountSheetState extends State<ShowAmountSheet> {
  late int _amount;

  @override
  void initState() {
    super.initState();
    _amount = widget.progress.done;
  }

  void _increment() {
    setState(() {
      _amount = min(widget.progress.habit.goal, _amount + 1);
    });
  }

  void _decrement() {
    setState(() {
      _amount = max(0, _amount - 1);
    });
  }

  void _submit() {
    widget.onSave(_amount);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final habit = widget.progress.habit;
    final safeBottom = MediaQuery.paddingOf(context).bottom;

    final dateStr = DateFormat('MMMM d').format(widget.date);
    final periodStr = safePeriod(habit.period).label;

    final isGoalReached = _amount == habit.goal;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(24, 12, 24, 24 + safeBottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Handle
          Center(
            child: Container(
              width: 48,
              height: 6,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
          const Gap(16),

          // Header: Edit Button & Close Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  if (widget.onEdit != null) widget.onEdit!();
                },
                icon: const Icon(LucideIcons.pencil, size: 16),
                label: const Text('Edit habit'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primaryColor,
                  textStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              CloseButtonSheet(onTap: () => Navigator.of(context).pop()),
            ],
          ),
          const Gap(16),

          // Icon
          Center(
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: Color(habit.colorValue).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                safeHabitIcon(habit.iconIndex),
                size: 32,
                color: Color(habit.colorValue),
              ),
            ),
          ),
          const Gap(24),

          // Title & Subtitle
          Text(
            habit.name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
              color: AppColors.ink,
            ),
          ),
          const Gap(6),
          Text(
            '$periodStr · $dateStr',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, color: AppColors.muted),
          ),
          const Gap(32),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _StepperButton(
                icon: LucideIcons.minus,
                onTap: _amount > 0 ? _decrement : null,
              ),
              SizedBox(
                width: 80,
                child: Text(
                  '$_amount',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                    height: 1,
                  ),
                ),
              ),
              _StepperButton(
                icon: LucideIcons.plus,
                onTap: _amount < habit.goal ? _increment : null,
              ),
            ],
          ),
          const Gap(16),

          // Goal Text
          Text(
            'of ${habit.goal} ${habit.unit} today',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, color: AppColors.muted),
          ),
          const Gap(32),

          SizedBox(
            height: 56,
            child: FilledButton.icon(
              onPressed: _submit,
              icon: Icon(
                isGoalReached ? Icons.check_rounded : Icons.save_rounded,
                size: 20,
              ),
              label: Text(isGoalReached ? 'Mark as complete' : 'Save progress'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const Gap(12),

          TextButton(
            onPressed: () {
              // TODO: Implement Archive later
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.muted,
              textStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            child: const Text('Archive habit'),
          ),
        ],
      ),
    );
  }
}

class _StepperButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _StepperButton({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: onTap == null
                ? AppColors.border.withValues(alpha: 0.5)
                : AppColors.border,
          ),
        ),
        child: Icon(
          icon,
          color: onTap == null
              ? AppColors.muted.withValues(alpha: 0.5)
              : AppColors.ink,
          size: 20,
        ),
      ),
    );
  }
}
