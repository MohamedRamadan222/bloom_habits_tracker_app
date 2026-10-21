import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

import '../theme/app_colors.dart';

class WeekCalendar extends StatefulWidget {
  final String title;
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;

  final bool Function(DateTime day)? hasActivity;

  const WeekCalendar({
    super.key,
    this.title = 'A little, every day',
    required this.selectedDate,
    required this.onDateSelected,
    this.hasActivity,
  });

  @override
  State<WeekCalendar> createState() => _WeekCalendarState();
}

class _WeekCalendarState extends State<WeekCalendar> {
  static const _daysBefore = 3;

  late DateTime _center;

  DateTime get _today => DateUtils.dateOnly(DateTime.now());

  List<DateTime> get _days => List.generate(
    7,
    (i) => DateTime(_center.year, _center.month, _center.day - _daysBefore + i),
  );

  bool get _canGoNext => _days.last.isBefore(_today);

  @override
  void initState() {
    super.initState();
    _center = DateUtils.dateOnly(widget.selectedDate);
  }

  @override
  void didUpdateWidget(WeekCalendar oldWidget) {
    super.didUpdateWidget(oldWidget);
    final visible = _days.any(
      (d) => DateUtils.isSameDay(d, widget.selectedDate),
    );
    if (!visible) _center = DateUtils.dateOnly(widget.selectedDate);
  }

  void _shiftWeek(int weeks) {
    setState(() {
      _center = DateTime(_center.year, _center.month, _center.day + 7 * weeks);
    });
  }

  @override
  Widget build(BuildContext context) {
    final days = _days;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                widget.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.ink,
                ),
              ),
            ),
            Text(
              DateFormat.yMMMM().format(_center),
              style: TextStyle(fontSize: 10, color: AppColors.muted),
            ),
            const Gap(6),
            _NavButton(icon: CupertinoIcons.back, onTap: () => _shiftWeek(-1)),
            const Gap(6),
            _NavButton(
              icon: CupertinoIcons.forward,
              onTap: _canGoNext ? () => _shiftWeek(1) : null,
            ),
          ],
        ),
        const Gap(14),
        Row(
          children: [
            for (var i = 0; i < days.length; i++) ...[
              if (i > 0) const Gap(6),
              Expanded(
                child: _DayCell(
                  date: days[i],
                  isSelected: DateUtils.isSameDay(days[i], widget.selectedDate),
                  isFuture: days[i].isAfter(_today),
                  hasActivity: widget.hasActivity?.call(days[i]) ?? false,
                  onTap: () => widget.onDateSelected(days[i]),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class _DayCell extends StatelessWidget {
  final DateTime date;
  final bool isSelected;
  final bool isFuture;
  final bool hasActivity;
  final VoidCallback onTap;

  const _DayCell({
    required this.date,
    required this.isSelected,
    required this.isFuture,
    required this.hasActivity,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color background;
    final Color labelColor;
    final Color numberColor;
    final Color dotColor;

    if (isSelected) {
      background = AppColors.primaryColor;
      labelColor = Colors.white.withValues(alpha: 0.8);
      numberColor = Colors.white;
      dotColor = Colors.white;
    } else if (isFuture) {
      background = AppColors.futureBg;
      labelColor = AppColors.muted.withValues(alpha: 0.5);
      numberColor = AppColors.muted;
      dotColor = AppColors.dotFuture;
    } else {
      background = Colors.white;
      labelColor = AppColors.muted;
      numberColor = AppColors.ink;
      dotColor = hasActivity ? AppColors.primaryColor : AppColors.dotIdle;
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: isFuture ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        // Min-height + padding instead of a fixed height: the content
        // defines the size, so tall fonts can never overflow the cell.
        constraints: const BoxConstraints(minHeight: 72),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.transparent : AppColors.cardBorder,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              DateFormat.E().format(date),
              style: TextStyle(fontSize: 10, color: labelColor),
            ),
            const Gap(6),
            Text(
              '${date.day}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: numberColor,
              ),
            ),
            const Gap(6),
            Container(
              width: 4,
              height: 4,
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _NavButton({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;

    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: AppColors.cardBorder),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          width: 30,
          height: 30,
          child: Icon(
            icon,
            size: 16,
            color: enabled
                ? AppColors.secondaryColor
                : AppColors.secondaryColor.withValues(alpha: 0.3),
          ),
        ),
      ),
    );
  }
}
