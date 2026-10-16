import 'package:bloom_habit_tracker/core/widgets/progress_ring.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../theme/app_colors.dart';

class DailySummary extends StatefulWidget {
  final VoidCallback onTap;
  final int done;
  final int total;
  final int streakDays;

  const DailySummary({
    super.key,
    required this.done,
    required this.total,
    required this.streakDays,
    required this.onTap,
  });

  @override
  State<DailySummary> createState() => _DailySummaryState();
}

class _DailySummaryState extends State<DailySummary> {
  double get _progress {
    if (widget.total <= 0) return 0;
    return (widget.done / widget.total).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 70),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: Color(0xffEEECF2), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                ProgressRing(
                  progress: _progress,
                  color: Color(0xffAC99D3),
                  size: 38,
                ),
                Gap(10),
                Column(
                  children: [
                    Text(
                      '${widget.done} of ${widget.total} habits done',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.ink,
                      ),
                    ),
                    Gap(2),
                    Text(
                      'Every little bit counts.',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            GestureDetector(
              onTap: widget.onTap,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10),
                width: 102,
                height: 30,
                decoration: BoxDecoration(
                  color: Color(0xffF5ECDF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(LucideIcons.flame, color: Color(0xff80633F), size: 15),
                    Text(
                      '${widget.streakDays} day streak',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Color(0xff80633F),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
