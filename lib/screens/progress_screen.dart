import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/models.dart';
import '../state/providers.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import '../widgets/flower.dart';
import 'notifications_sheet.dart';

final progressSegmentProvider = StateProvider<int>((ref) => 0);

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final seg = ref.watch(progressSegmentProvider);
    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          BrandHeader(title: 'Progress', onBell: () => showNotifications(context)),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(color: AppColors.surfaceAlt, borderRadius: BorderRadius.circular(999)),
              child: Row(
                children: [
                  for (final (i, label) in ['Flower', 'Activity'].indexed)
                    Expanded(
                      child: InkWell(
                        key: Key('seg_${label.toLowerCase()}'),
                        borderRadius: BorderRadius.circular(999),
                        onTap: () => ref.read(progressSegmentProvider.notifier).state = i,
                        child: Container(
                          height: 44,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: seg == i ? AppColors.accentFill : Colors.transparent,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(label,
                              style: AppText.label(
                                  color: seg == i ? Colors.white : AppColors.textSecondary, weight: FontWeight.w600)),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          Expanded(child: seg == 0 ? const _FlowerView() : const _ActivityView()),
        ],
      ),
    );
  }
}

class _FlowerView extends ConsumerWidget {
  const _FlowerView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flower = ref.watch(flowerProvider);
    final programme = ref.watch(programmeProvider)!;
    final habits = ref.watch(habitsProvider);
    final checkIns = ref.watch(checkInsProvider).length + (programme.block.number - 1);
    const counts = [4, 5, 3, 2, 0, 0, 0];

    return ListView(
      key: const Key('flower_list'),
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      children: [
        AppCard(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
          child: Column(
            children: [
              Text('Your flower', style: AppText.display()),
              const SizedBox(height: 4),
              Text('Block ${programme.block.number}: ${programme.block.title}', style: AppText.caption()),
              const SizedBox(height: 12),
              PetalFlower(
                key: const Key('flower'),
                petals: flower.petals,
                size: 250,
                centerLabel: 'Block ${programme.block.number}',
                centerCaption: '${(flower.petals[programme.block.number - 1] * 100).round()}%',
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: AppColors.accentTint, borderRadius: BorderRadius.circular(AppRadius.control)),
                child: Row(
                  children: [
                    const Icon(Icons.favorite_border_rounded, color: AppColors.accentFill, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text('Your flower only grows. Missed days never take a petal away.',
                          style: AppText.label(color: AppColors.textPrimary)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _Stat(value: '${flower.habitsDone}', label: 'habits done', icon: Icons.check_rounded),
            const SizedBox(width: 10),
            _Stat(value: '${programme.currentWeek}', label: programme.currentWeek == 1 ? 'week' : 'weeks', icon: Icons.calendar_today_outlined),
            const SizedBox(width: 10),
            _Stat(value: '$checkIns', label: 'check-ins', icon: Icons.chat_bubble_outline_rounded),
          ],
        ),
        const SizedBox(height: 12),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Habits this week', style: AppText.title()),
              const SizedBox(height: 4),
              Text('Small and steady beats perfect', style: AppText.caption()),
              const SizedBox(height: 16),
              SizedBox(
                height: 120,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    for (var i = 0; i < 7; i++)
                      Expanded(
                        child: _Bar(
                          day: const ['M', 'T', 'W', 'T', 'F', 'S', 'S'][i],
                          value: i == 2 ? habits.where((h) => h.doneToday).length : (habits.isEmpty ? 0 : counts[i]),
                          max: 5,
                          today: i == 2,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label, required this.icon});
  final String value;
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: AppCard(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        child: Column(
          children: [
            IconBubble(icon, size: 30),
            const SizedBox(height: 6),
            Text(value, style: AppText.oswald(28, 700)),
            Text(label, style: AppText.caption()),
          ],
        ),
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({required this.day, required this.value, required this.max, required this.today});
  final String day;
  final int value;
  final int max;
  final bool today;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text('$value', style: AppText.caption()),
        const SizedBox(height: 4),
        Container(
          width: 18,
          height: 70 * (value / max).clamp(0.04, 1.0),
          decoration: BoxDecoration(
            color: today ? AppColors.accentFill : AppColors.accent,
            borderRadius: BorderRadius.circular(99),
          ),
        ),
        const SizedBox(height: 6),
        Text(day, style: AppText.caption(color: today ? AppColors.accentFill : AppColors.textSecondary)),
      ],
    );
  }
}

class _ActivityView extends ConsumerWidget {
  const _ActivityView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final a = ref.watch(activityProvider);
    final profile = ref.watch(sessionProvider)!;

    return ListView(
      key: const Key('activity_list'),
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      children: [
        AppCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(child: Text('DAILY STEPS', style: AppText.caption())),
                  TintChip('${_fmt(stepGoal)} goal'),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: 170,
                height: 170,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox.expand(
                      child: CircularProgressIndicator(
                        value: (a.steps / stepGoal).clamp(0, 1),
                        strokeWidth: 14,
                        strokeCap: StrokeCap.round,
                        backgroundColor: AppColors.surfaceAlt,
                        color: AppColors.accent,
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(_fmt(a.steps), key: const Key('steps_value'), style: AppText.oswald(36, 700)),
                        Text('steps', style: AppText.caption()),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Text('${_fmt((stepGoal - a.steps).clamp(0, stepGoal))} steps to your daily goal',
                  style: AppText.label(color: AppColors.textSecondary)),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            SecondaryButton(
              key: const Key('sync_health'),
              label: a.syncing ? 'Syncing...' : 'Sync health data',
              icon: Icons.favorite_border_rounded,
              onPressed: a.syncing ? null : () => ref.read(activityProvider.notifier).syncHealth(),
            ),
            const Spacer(),
            const Icon(Icons.schedule_rounded, size: 16, color: AppColors.textSecondary),
            const SizedBox(width: 4),
            Text('Last synced ${a.lastSynced}', style: AppText.caption()),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text('Demo only: sync is simulated, no Apple Health or Health Connect call.',
              style: AppText.caption(color: AppColors.textTertiary)),
        ),
        SectionHeader('Today', trailing: '${a.entries.length} logged'),
        AppCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              for (final (i, e) in a.entries.indexed) ...[
                if (i > 0) const Divider(height: 1, color: AppColors.border),
                ListTile(
                  minVerticalPadding: 12,
                  leading: IconBubble(_activityIcon(e.type)),
                  title: Text(e.type, style: AppText.body().copyWith(fontWeight: FontWeight.w600)),
                  subtitle: Text('${e.minutes} min${e.note.isEmpty ? '' : ', ${e.note}'}', style: AppText.caption()),
                  trailing: TintChip(e.source == ActivitySource.synced ? 'Synced' : 'Logged by hand',
                      tone: e.source == ActivitySource.synced ? ChipTone.info : ChipTone.neutral),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Body', style: AppText.title()),
                    const SizedBox(height: 8),
                    _kv('Weight', '${a.weightKg} kg'),
                    _kv('Waist', '${a.waistCm} cm'),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Food', style: AppText.title()),
                    const SizedBox(height: 8),
                    _kv('Protein', profile.tier.hasPersonalPlan ? '${a.proteinG} / 110 g' : '${a.proteinG} g'),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(99),
                      child: LinearProgressIndicator(
                        value: a.proteinG / 110,
                        minHeight: 8,
                        backgroundColor: AppColors.surfaceAlt,
                        color: AppColors.accentFill,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        PrimaryButton(
          key: const Key('log_activity'),
          label: 'Log activity',
          icon: Icons.add_rounded,
          onPressed: () => _showLogSheet(context, ref, workout: profile.tier.hasPersonalPlan),
        ),
      ],
    );
  }

  Widget _kv(String k, String v) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          children: [
            Expanded(child: Text(k, style: AppText.label(color: AppColors.textSecondary))),
            Text(v, style: AppText.oswald(16, 600)),
          ],
        ),
      );
}

IconData _activityIcon(String type) => switch (type) {
      'Walk' => Icons.directions_walk_rounded,
      'Yoga' => Icons.self_improvement_rounded,
      'Swim' => Icons.pool_rounded,
      _ => Icons.fitness_center_rounded,
    };

String _fmt(int n) => n >= 1000 ? '${n ~/ 1000},${(n % 1000).toString().padLeft(3, '0')}' : '$n';

void _showLogSheet(BuildContext context, WidgetRef ref, {required bool workout}) {
  final types = workout ? ['Strength session', 'Walk', 'Yoga', 'Swim'] : ['Walk', 'Yoga', 'Swim'];
  var type = types.first;
  var minutes = 30.0;
  showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    backgroundColor: AppColors.background,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setState) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(workout ? 'Log a workout' : 'Log activity', style: AppText.title()),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final t in types)
                    ChoiceChip(
                      key: Key('log_type_$t'),
                      label: Text(t),
                      selected: type == t,
                      showCheckmark: false,
                      onSelected: (_) => setState(() => type = t),
                      selectedColor: AppColors.accentTint,
                      backgroundColor: Colors.white,
                      shape: const StadiumBorder(),
                      side: BorderSide(color: type == t ? AppColors.accentFill : AppColors.border),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Text('${minutes.round()} minutes', style: AppText.oswald(24, 600)),
              Slider(
                value: minutes,
                min: 5,
                max: 90,
                divisions: 17,
                activeColor: AppColors.accentFill,
                onChanged: (v) => setState(() => minutes = v),
              ),
              const SizedBox(height: 8),
              PrimaryButton(
                key: const Key('save_activity'),
                label: 'Save',
                onPressed: () {
                  ref.read(activityProvider.notifier).log(ActivityEntry(type, minutes.round(), ActivitySource.manual));
                  Navigator.of(ctx).pop();
                },
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
