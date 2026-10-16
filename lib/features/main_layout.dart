import 'package:bloom_habit_tracker/core/theme/app_colors.dart';
import 'package:bloom_habit_tracker/features/discover/presentation/views/discover_screen.dart';
import 'package:bloom_habit_tracker/features/habits/presentation/views/habits_screen.dart';
import 'package:bloom_habit_tracker/features/home/presentation/views/home_screen.dart';
import 'package:bloom_habit_tracker/features/progress/presentation/views/progress_screen.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentPageIndex = 0;

  List<Widget> get _pages => [
    HomeScreen(
      onMyHabitsTap: () => setState(() => _currentPageIndex = 1),
      onProgressTap: () => setState(() => _currentPageIndex = 2),
    ),
    const HabitsScreen(),
    const ProgressScreen(),
    const DiscoverScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: false,
        titleSpacing: 26,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/icons/appBarIcon.png', height: 30),
            const Gap(12),
            const Text(
              'bloom.',

              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 26,

                letterSpacing: -1.3,
              ),
            ),
          ],
        ),
        actions: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.lavender,
              shape: BoxShape.circle,
            ),
            child: Icon(
              LucideIcons.user,
              size: 18,
              color: AppColors.secondaryColor,
            ),
          ),
          Gap(24),
        ],
      ),
      body: _pages[_currentPageIndex],
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          height: 80,
          elevation: 0,
          shadowColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          backgroundColor: Colors.white,
          indicatorColor: AppColors.lavender,
          indicatorShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          overlayColor: const WidgetStatePropertyAll(Colors.transparent),
          iconTheme: WidgetStateProperty.resolveWith(
            (states) => IconThemeData(
              size: 20,
              color: states.contains(WidgetState.selected)
                  ? AppColors.primaryColor
                  : AppColors.secondaryColor,
            ),
          ),
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            final selected = states.contains(WidgetState.selected);
            return TextStyle(
              fontSize: 10,
              fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
              color: selected
                  ? AppColors.primaryColor
                  : AppColors.secondaryColor,
            );
          }),
        ),
        child: NavigationBar(
          selectedIndex: _currentPageIndex,
          animationDuration: const Duration(milliseconds: 300),
          onDestinationSelected: (index) =>
              setState(() => _currentPageIndex = index),
          destinations: const [
            NavigationDestination(icon: Icon(LucideIcons.sun), label: 'Today'),
            NavigationDestination(
              icon: Icon(LucideIcons.layoutGrid),
              label: 'My habits',
            ),
            NavigationDestination(
              icon: Icon(LucideIcons.chartNoAxesColumn),
              label: 'Progress',
            ),
            NavigationDestination(
              icon: Icon(LucideIcons.sparkle),
              label: 'Discover',
            ),
          ],
        ),
      ),
    );
  }
}
