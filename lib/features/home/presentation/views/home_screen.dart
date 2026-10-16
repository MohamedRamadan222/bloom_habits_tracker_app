import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/mock/mock_data.dart';
import '../../../../core/widgets/calender_header.dart';
import '../../../../core/widgets/custom_header.dart';
import '../../../../core/widgets/daily_summary.dart';

import '../widgets/daily_habit.dart';
import '../widgets/home_banner.dart';
import '../widgets/segmented_tabs.dart';
import '../widgets/title_and_count_widget.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback onMyHabitsTap;
  final VoidCallback onProgressTap;

  const HomeScreen({
    super.key,
    required this.onMyHabitsTap,
    required this.onProgressTap,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedTab = 0;
  DateTime _selectedDate = DateUtils.dateOnly(DateTime.now());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Gap(8),
              // Header
              PageHeader.home(
                title: 'A good day to grow.',
                subtitle: 'Hello, Alex',
              ),
              Gap(23),
              // Banner Encouragement
              HomeBanner(),
              Gap(14),
              // Daily summary
              DailySummary(
                onTap: widget.onProgressTap,
                done: 6,
                total: 20,
                streakDays: 7,
              ),
              Gap(24),
              // Calendar toolbar
              WeekCalendar(
                selectedDate: _selectedDate,
                onDateSelected: (day) => setState(() => _selectedDate = day),
              ),
              Gap(24),
              // Title and count
              TitleAndCountWidget(
                onPressed: widget.onMyHabitsTap,
                count: MockData.habitsTotal,
              ),
              Gap(12),
              // SegmentedTabs
              SegmentedTabs(
                labels: const ['All habits', 'Morning', 'Afternoon', 'Evening'],
                selectedIndex: _selectedTab,
                onChanged: (i) => setState(() => _selectedTab = i),
              ),
              Gap(15),
              // Daily habit list
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 10,
                separatorBuilder: (_, __) => const Gap(10),
                itemBuilder: (context, index) {
                  return HabitCard(
                    icon: LucideIcons.personStanding,
                    name: 'Morning stretch',
                    subtitle: '10 minutes · Morning · Done',
                    isDone: true,
                    onTap: () {},
                    onToggle: () {},
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
