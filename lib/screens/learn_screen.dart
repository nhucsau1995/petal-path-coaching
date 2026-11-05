import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/mock_data.dart';
import '../models/models.dart';
import '../state/providers.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import 'lesson_detail_screen.dart';
import 'notifications_sheet.dart';

const _months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
const _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

String shortDate(DateTime d) => '${_days[d.weekday - 1]} ${d.day} ${_months[d.month - 1]}';

class LearnScreen extends ConsumerWidget {
  const LearnScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final programme = ref.watch(programmeProvider)!;
    final profile = ref.watch(sessionProvider)!;
    final week = ref.watch(selectedWeekProvider) ?? programme.currentWeek;
    final lesson = lessons[week - 1];
    final progress = ref.watch(lessonProgressProvider);
    final firstChip = (programme.currentWeek - 2).clamp(1, totalWeeks - 5);

    return SafeArea(
      bottom: false,
      child: ListView(
        key: const Key('learn_list'),
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          BrandHeader(onBell: () => showNotifications(context)),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Learn', style: AppText.display()),
                const SizedBox(height: 4),
                Text(
                  profile.tier.dripsWeekly
                      ? 'A new week opens every Monday from your start date.'
                      : 'Membership: every week is open from day 1.',
                  style: AppText.body(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                for (var w = firstChip; w < firstChip + 6 && w <= totalWeeks; w++)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _WeekChip(
                      week: w,
                      selected: w == week,
                      locked: !programme.isUnlocked(w),
                      done: progress.completedWeeks.contains(w) || w < programme.currentWeek,
                      onTap: () {
                        if (programme.isUnlocked(w)) {
                          ref.read(selectedWeekProvider.notifier).state = w;
                        } else {
                          showMockSnack(context, 'Week $w unlocks ${shortDate(profile.firstLogin.add(Duration(days: (w - 1) * 7)))}');
                        }
                      },
                    ),
                  ),
              ],
            ),
          ),
          if (programme.nextUnlock != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
              child: Row(
                children: [
                  const Icon(Icons.schedule_rounded, size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: 6),
                  Text('Week ${programme.currentWeek + 1} unlocks ${shortDate(programme.nextUnlock!)}',
                      style: AppText.caption()),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _LessonHeroCard(lesson: lesson, done: progress.completedWeeks.contains(week)),
                SectionHeader('Tasks',
                    trailing:
                        '${lesson.tasks.where((t) => progress.doneTasks.contains('$week:$t')).length} of ${lesson.tasks.length} done'),
                AppCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      for (final (i, t) in lesson.tasks.indexed) ...[
                        if (i > 0) const Divider(height: 1, color: AppColors.border),
                        TaskTile(week: week, task: t),
                      ],
                    ],
                  ),
                ),
                const SectionHeader('Resources'),
                for (final r in lesson.resources) ...[
                  ResourceTile(resource: r),
                  const SizedBox(height: 10),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WeekChip extends StatelessWidget {
  const _WeekChip({required this.week, required this.selected, required this.locked, required this.done, required this.onTap});

  final int week;
  final bool selected;
  final bool locked;
  final bool done;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fg = selected ? Colors.white : (locked ? AppColors.textTertiary : AppColors.textPrimary);
    return Semantics(
      button: true,
      selected: selected,
      label: locked ? 'Week $week, locked' : 'Week $week',
      child: InkWell(
        key: Key('week_chip_$week'),
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? AppColors.accentFill : (locked ? AppColors.surfaceAlt : Colors.white),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: selected ? AppColors.accentFill : AppColors.border),
          ),
          child: Row(
            children: [
              Text('Week $week', style: AppText.label(color: fg, weight: FontWeight.w600)),
              if (locked || (done && !selected)) ...[
                const SizedBox(width: 6),
                Icon(locked ? Icons.lock_outline_rounded : Icons.check_circle_outline_rounded, size: 16, color: fg),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _LessonHeroCard extends StatelessWidget {
  const _LessonHeroCard({required this.lesson, required this.done});
  final Lesson lesson;
  final bool done;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      key: const Key('lesson_card'),
      padding: EdgeInsets.zero,
      onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => LessonDetailScreen(week: lesson.week))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.card)),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Image.asset(lesson.image, height: 190, width: double.infinity, fit: BoxFit.cover),
                const Positioned.fill(child: PhotoScrim()),
                Container(
                  width: 56,
                  height: 56,
                  decoration: const BoxDecoration(color: AppColors.accentFill, shape: BoxShape.circle),
                  child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 34),
                ),
                Positioned(
                  right: 12,
                  bottom: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(999)),
                    child: Text('${lesson.minutes} min', style: AppText.caption(color: AppColors.textPrimary)),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TintChip(done ? 'Completed' : 'Lesson ${lesson.week}', tone: done ? ChipTone.success : ChipTone.accent),
                const SizedBox(height: 8),
                Text('Lesson ${lesson.week}: ${lesson.title}', style: AppText.title()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class TaskTile extends ConsumerWidget {
  const TaskTile({super.key, required this.week, required this.task});
  final int week;
  final String task;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final done = ref.watch(lessonProgressProvider).doneTasks.contains('$week:$task');
    return InkWell(
      key: Key('task_${week}_${task.hashCode}'),
      onTap: () => ref.read(lessonProgressProvider.notifier).toggleTask(week, task),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(done ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                color: done ? AppColors.accentFill : AppColors.borderStrong, size: 26),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                task,
                style: AppText.body(color: done ? AppColors.textSecondary : AppColors.textPrimary).copyWith(
                  decoration: done ? TextDecoration.lineThrough : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ResourceTile extends StatelessWidget {
  const ResourceTile({super.key, required this.resource});
  final Resource resource;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: () => showMockSnack(context, 'Opening "${resource.title}" (sample PDF)'),
      child: Row(
        children: [
          const IconBubble(Icons.picture_as_pdf_outlined),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(resource.title, style: AppText.body().copyWith(fontWeight: FontWeight.w600)),
                Text(resource.meta, style: AppText.caption()),
              ],
            ),
          ),
          const Icon(Icons.download_rounded, color: AppColors.accentFill),
        ],
      ),
    );
  }
}
