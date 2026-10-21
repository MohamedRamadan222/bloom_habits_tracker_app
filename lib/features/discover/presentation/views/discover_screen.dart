import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/domain/entities/habit.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_header.dart';
import '../../../habits/cubit/habits_cubit.dart';
import '../../../home/cubit/home_cubit.dart';
import '../../../home/presentation/widgets/habit_draft.dart';

class DiscoverItem {
  final String label;
  final String title;
  final String description;
  final String durationText;
  final HabitItem habitPreset;

  DiscoverItem({
    required this.label,
    required this.title,
    required this.description,
    required this.durationText,
    required this.habitPreset,
  });
}

class DiscoverScreen extends StatelessWidget {
  const DiscoverScreen({super.key});

  List<DiscoverItem> get _discoverItems => [
    DiscoverItem(
      label: 'A little more calm',
      title: 'A moment of quiet',
      description:
          'Take a breath. Let your mind catch up with the rest of you.',
      durationText: '5 minutes a day',
      habitPreset: HabitItem(
        id: '',
        name: 'A moment of quiet',
        iconIndex: 12,
        colorValue: 0xFF81C784,
        goal: 5,
        unit: 'minutes',
        period: 0,
        // 0 = Any time
        createdAt: DateTime.now().millisecondsSinceEpoch,
      ),
    ),
    DiscoverItem(
      label: 'A little more wonder',
      title: 'Turn a few pages',
      description: 'A new idea, a different world. Make a little time to get lost in a book.',
      durationText: '10 pages a day',
      habitPreset: HabitItem(
        id: '',
        name: 'Turn a few pages',
        iconIndex: 4,
        colorValue: 0xFFFFB74D,
        goal: 10,
        unit: 'pages',
        period: 0,
        createdAt: DateTime.now().millisecondsSinceEpoch,
      ),
    ),
    DiscoverItem(
      label: 'A little more fresh',
      title: 'Stay hydrated',
      description:
          'A simple glass of water to keep your body and mind refreshed.',
      durationText: '8 glasses a day',
      habitPreset: HabitItem(
        id: '',
        name: 'Stay hydrated',
        iconIndex: 8,
        colorValue: 0xFF64B5F6,
        goal: 8,
        unit: 'glasses',
        period: 0,
        createdAt: DateTime.now().millisecondsSinceEpoch,
      ),
    ),
    DiscoverItem(
      label: 'A little more active',
      title: 'Stretch your body',
      description:
          'Release tension and wake up your muscles with simple stretches.',
      durationText: '15 minutes a day',
      habitPreset: HabitItem(
        id: '',
        name: 'Stretch your body',
        iconIndex: 15,
        colorValue: 0xFFBA68C8,
        goal: 15,
        unit: 'minutes',
        period: 0,
        createdAt: DateTime.now().millisecondsSinceEpoch,
      ),
    ),
  ];

  void _openHabitSheet(BuildContext context, HabitItem preset) {
    final habitsCubit = context.read<HabitsCubit>();
    final homeCubit = context.read<HomeCubit>();

    showHabitSheet(
      context,
      initial: preset,
      onSave: (habit) async {
        await homeCubit.add(habit);
        habitsCubit.reload();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                children: [
                  const Gap(8),
                  PageHeader.page(
                    title: 'Find your next\nlittle thing.',
                    subtitle: 'Simple ideas for a routine that feels good.',
                    onActionPressed: () => _openHabitSheet(
                      context,
                      HabitItem(
                        id: '',
                        name: '',
                        iconIndex: 0,
                        colorValue: AppColors.primaryColor.toARGB32(),
                        goal: 1,
                        unit: 'times',
                        period: 0,
                        createdAt: DateTime.now().millisecondsSinceEpoch,
                      ),
                    ),
                  ),
                  const Gap(24),
                  const _DiscoverBanner(),
                  const Gap(24),
                ],
              ),
            ),
            SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                mainAxisExtent: 290,
              ),
              delegate: SliverChildBuilderDelegate((context, index) {
                final item = _discoverItems[index];
                return _DiscoverCard(
                  item: item,
                  onTryPressed: () =>
                      _openHabitSheet(context, item.habitPreset),
                );
              }, childCount: _discoverItems.length),
            ),
            const SliverToBoxAdapter(child: Gap(32)),
          ],
        ),
      ),
    );
  }
}

class _DiscoverBanner extends StatelessWidget {
  const _DiscoverBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: const Color(0xFFEAF2EA),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          Positioned(
            right: -30,
            top: 0,
            bottom: 0,
            width: 165,
            child: Center(
              child: Icon(
                LucideIcons.asterisk,
                size: 150,
                color: const Color(0xFFC8DEC8),
              ),
            ),
          ),
          FractionallySizedBox(
            widthFactor: 0.6,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 0, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Good things\nstart small.',
                    style: TextStyle(
                      fontSize: 22,
                      height: 1.15,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                      color: Color(0xFF4A6856),
                    ),
                  ),
                  const Gap(6),
                  Text(
                    "You don't need to change everything. Just pick one thing that feels right.",
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.5,
                      color: const Color(0xFF4A6856).withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DiscoverCard extends StatelessWidget {
  final DiscoverItem item;
  final VoidCallback onTryPressed;

  const _DiscoverCard({required this.item, required this.onTryPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xffEEECF2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Color(item.habitPreset.colorValue).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              LucideIcons.leaf,
              size: 20,
              color: Color(item.habitPreset.colorValue),
            ),
          ),
          const Gap(12),
          Text(
            item.label,
            style: const TextStyle(fontSize: 10, color: AppColors.muted),
          ),
          const Gap(4),
          Text(
            item.title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
              color: AppColors.ink,
            ),
          ),
          const Gap(8),
          Expanded(
            child: Text(
              item.description,
              style: const TextStyle(
                fontSize: 12,
                height: 1.4,
                color: AppColors.muted,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const Gap(8),
          Row(
            children: [
              const Icon(LucideIcons.clock, size: 12, color: AppColors.muted),
              const Gap(6),
              Text(
                item.durationText,
                style: const TextStyle(fontSize: 10, color: AppColors.muted),
              ),
            ],
          ),
          const Gap(12),
          SizedBox(
            width: double.infinity,
            height: 40,
            child: TextButton.icon(
              onPressed: onTryPressed,
              icon: const Icon(LucideIcons.plus, size: 16),
              label: const Text('Try this habit',style: TextStyle(fontSize: 12),),
              style: TextButton.styleFrom(
                backgroundColor: AppColors.lavender,
                foregroundColor: AppColors.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                textStyle: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
