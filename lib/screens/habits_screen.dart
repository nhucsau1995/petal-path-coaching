import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/models.dart';
import '../state/providers.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import 'habit_library_screen.dart';
import 'notifications_sheet.dart';

class HabitsScreen extends ConsumerWidget {
  const HabitsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habits = ref.watch(habitsProvider);
    final today = ref.watch(clockProvider);
    final monday = today.subtract(Duration(days: today.weekday - 1));
    final done = habits.where((h) => h.doneToday).length;

    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          BrandHeader(onBell: () => showNotifications(context)),
          Expanded(
            child: ListView(
              key: const Key('habits_list'),
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              children: [
                Text('Habits', style: AppText.display()),
                const SizedBox(height: 16),
                AppCard(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      for (var i = 0; i < 7; i++)
                        _DayCell(date: monday.add(Duration(days: i)), today: i == today.weekday - 1),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                AppCard(
                  key: const Key('habit_counter'),
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('TODAY', style: AppText.caption()),
                            Text('$done of ${habits.length}', style: AppText.oswald(40, 700)),
                            Text('done today, every tick grows a petal', style: AppText.caption()),
                          ],
                        ),
                      ),
                      const IconBubble(Icons.local_florist_outlined, size: 56, color: AppColors.supportStrong, bg: Color(0xFFFFEAF3)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                if (habits.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Text('No habits yet. Add one from your coach\'s library or create your own.',
                        style: AppText.body(color: AppColors.textSecondary), textAlign: TextAlign.center),
                  ),
                for (final h in habits) ...[
                  _HabitCard(habit: h),
                  const SizedBox(height: 10),
                ],
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
            child: PrimaryButton(
              key: const Key('add_habit'),
              label: 'Add a habit',
              icon: Icons.add_rounded,
              onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const HabitLibraryScreen())),
            ),
          ),
        ],
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({required this.date, required this.today});
  final DateTime date;
  final bool today;

  static const _names = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];

  @override
  Widget build(BuildContext context) {
    final fg = today ? Colors.white : AppColors.textPrimary;
    return Container(
      width: 40,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: today ? AppColors.accentFill : Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadius.control),
      ),
      child: Column(
        children: [
          Text(_names[date.weekday - 1], style: AppText.caption(color: today ? Colors.white : AppColors.textSecondary)),
          const SizedBox(height: 2),
          Text('${date.day}', style: AppText.oswald(18, 600, color: fg)),
        ],
      ),
    );
  }
}

class _HabitCard extends ConsumerWidget {
  const _HabitCard({required this.habit});
  final Habit habit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          HabitCheckButton(
            key: Key('habit_check_${habit.id}'),
            done: habit.doneToday,
            label: habit.title,
            onTap: () => ref.read(habitsProvider.notifier).toggle(habit.id, todayIndex: ref.read(clockProvider).weekday - 1),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(habit.title, style: AppText.oswald(18, 500)),
                const SizedBox(height: 6),
                StreakDots(habit.week),
              ],
            ),
          ),
          TintChip(habit.source == HabitSource.coach ? 'From coach' : 'Mine',
              tone: habit.source == HabitSource.coach ? ChipTone.accent : ChipTone.neutral),
        ],
      ),
    );
  }
}
