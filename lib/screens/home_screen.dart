import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/mock_data.dart';
import '../models/models.dart';
import '../state/providers.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import 'check_in_screen.dart';
import 'habit_library_screen.dart';
import 'lesson_detail_screen.dart';
import 'notifications_sheet.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(sessionProvider)!;
    final programme = ref.watch(programmeProvider)!;
    final habits = ref.watch(habitsProvider);
    final greeting = habits.isEmpty ? 'Welcome, ${profile.firstName}' : 'Good morning, ${profile.firstName}';

    return SafeArea(
      bottom: false,
      child: ListView(
        key: const Key('home_list'),
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          BrandHeader(onBell: () => showNotifications(context)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TintChip(profile.tier.label),
                          const SizedBox(height: 8),
                          Text(greeting, style: AppText.display()),
                        ],
                      ),
                    ),
                    CircleAvatar(radius: 24, backgroundImage: AssetImage(profile.avatar)),
                  ],
                ),
                const SizedBox(height: 20),
                if (habits.isEmpty) _FirstWeekCard(programme: programme) else _WeekHero(programme: programme),
                if (habits.isEmpty) ...[
                  const SectionHeader("Today's habits", trailing: '0 set'),
                  _EmptyHabits(),
                  const SizedBox(height: 20),
                  PrimaryButton(
                    key: const Key('choose_first_habit'),
                    label: 'Choose my first habit',
                    icon: Icons.arrow_forward_rounded,
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(builder: (_) => const HabitLibraryScreen()),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.schedule_rounded, size: 16, color: AppColors.textSecondary),
                        const SizedBox(width: 6),
                        Text(
                          'Week ${programme.currentWeek + 1} unlocks in '
                          '${programme.nextUnlock!.difference(ref.watch(clockProvider)).inDays} days',
                          style: AppText.caption(),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  SectionHeader("Today's habits",
                      trailing: '${habits.take(3).where((h) => h.doneToday).length} of ${habits.take(3).length} done'),
                  for (final h in habits.take(3)) _HabitRow(habit: h),
                  const SectionHeader('New this week'),
                  _UnlockLessonCard(week: programme.currentWeek),
                  const SizedBox(height: 12),
                  _CheckInCard(block: programme.block),
                  const SizedBox(height: 24),
                  PrimaryButton(
                    key: const Key('open_week'),
                    label: 'Open this week',
                    icon: Icons.arrow_forward_rounded,
                    onPressed: () => ref.read(tabIndexProvider.notifier).state = 1,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WeekHero extends StatelessWidget {
  const _WeekHero({required this.programme});
  final ProgrammeState programme;

  @override
  Widget build(BuildContext context) {
    final days = programme.dayOfWeek;
    return Container(
      key: const Key('week_hero'),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.heroGradient,
        borderRadius: BorderRadius.circular(AppRadius.card),
        boxShadow: cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: const Color(0x33000000), borderRadius: BorderRadius.circular(999)),
            child: Text('Week ${programme.currentWeek} of $totalWeeks', style: AppText.caption(color: Colors.white)),
          ),
          const SizedBox(height: 14),
          Text('CURRENT BLOCK', style: AppText.caption(color: Colors.white)),
          const SizedBox(height: 2),
          Text('Block ${programme.block.number}: ${programme.block.title}', style: AppText.oswald(24, 600, color: Colors.white)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: Text('$days of 7 days', style: AppText.label(color: Colors.white))),
              Text('${(days / 7 * 100).round()}%', style: AppText.caption(color: Colors.white)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: days / 7,
              minHeight: 8,
              backgroundColor: const Color(0x40FFFFFF),
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _FirstWeekCard extends StatelessWidget {
  const _FirstWeekCard({required this.programme});
  final ProgrammeState programme;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.asset('assets/images/seedling.jpg', height: 170, width: double.infinity, fit: BoxFit.cover),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 14, 8, 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Week ${programme.currentWeek} starts today', style: AppText.title()),
                const SizedBox(height: 4),
                Text('One small step is enough.', style: AppText.body(color: AppColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyHabits extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.borderStrong, width: 1.2),
      ),
      child: Column(
        children: [
          const IconBubble(Icons.spa_outlined, size: 44, bg: Colors.white),
          const SizedBox(height: 12),
          Text('No habits yet', style: AppText.title()),
          const SizedBox(height: 4),
          Text('Pick your first habit to start your flower.',
              style: AppText.body(color: AppColors.textSecondary), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _HabitRow extends ConsumerWidget {
  const _HabitRow({required this.habit});
  final Habit habit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AppCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            IconBubble(_iconFor(habit.category)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(habit.title, style: AppText.body().copyWith(fontWeight: FontWeight.w600)),
                  Text(habit.doneToday ? 'Done today' : 'Not yet today', style: AppText.caption()),
                ],
              ),
            ),
            HabitCheckButton(
              key: Key('home_check_${habit.id}'),
              done: habit.doneToday,
              label: habit.title,
              onTap: () => ref.read(habitsProvider.notifier).toggle(habit.id),
            ),
          ],
        ),
      ),
    );
  }
}

IconData _iconFor(HabitCategory c) => switch (c) {
      HabitCategory.food => Icons.water_drop_outlined,
      HabitCategory.movement => Icons.directions_walk_rounded,
      HabitCategory.sleep => Icons.bedtime_outlined,
      HabitCategory.calm => Icons.self_improvement_rounded,
    };

class _UnlockLessonCard extends StatelessWidget {
  const _UnlockLessonCard({required this.week});
  final int week;

  @override
  Widget build(BuildContext context) {
    final lesson = lessons[week - 1];
    return AppCard(
      key: const Key('unlock_lesson'),
      padding: const EdgeInsets.all(12),
      onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => LessonDetailScreen(week: week))),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.asset('assets/images/lesson-meal-planning.jpg', width: 84, height: 84, fit: BoxFit.cover),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('NEW LESSON, ${lesson.minutes} MIN', style: AppText.caption(color: AppColors.accentFill)),
                const SizedBox(height: 4),
                Text(lesson.title, style: AppText.body().copyWith(fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
        ],
      ),
    );
  }
}

class _CheckInCard extends ConsumerWidget {
  const _CheckInCard({required this.block});
  final Block block;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final submitted = ref.watch(checkInsProvider).contains(block.number);
    return AppCard(
      key: const Key('checkin_card'),
      onTap: submitted
          ? null
          : () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => CheckInScreen(
                    title: 'Block ${block.number} check-in',
                    questions: blockCheckIn,
                    onSubmit: (ref) => ref.read(checkInsProvider.notifier).submit(block.number),
                  ),
                ),
              ),
      child: Row(
        children: [
          const IconBubble(Icons.assignment_outlined),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(submitted ? 'Block ${block.number} check-in sent' : 'Block ${block.number} check-in is open',
                    style: AppText.body().copyWith(fontWeight: FontWeight.w600)),
                Text(submitted ? 'Your coach will reply this week' : 'Four short questions, about 5 minutes',
                    style: AppText.caption()),
              ],
            ),
          ),
          submitted
              ? const TintChip('Done', tone: ChipTone.success)
              : const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
        ],
      ),
    );
  }
}
