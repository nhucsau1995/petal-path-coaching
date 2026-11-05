import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/mock_data.dart';
import '../models/models.dart';
import '../state/providers.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import '../widgets/flower.dart';

/// Coach view: every client with progress and flags, retain / revoke access,
/// plus a content tab where the coach edits notification wording.
class CoachScreen extends ConsumerStatefulWidget {
  const CoachScreen({super.key});

  @override
  ConsumerState<CoachScreen> createState() => _CoachScreenState();
}

class _CoachScreenState extends ConsumerState<CoachScreen> {
  String? _expanded = 'priya';
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            BackHeader(
              title: 'Coach view',
              trailing: IconButton(
                tooltip: 'Search clients',
                onPressed: () => showMockSnack(context, 'Search is not part of the demo'),
                icon: const Icon(Icons.search_rounded),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: SegmentedButton<int>(
                showSelectedIcon: false,
                segments: const [
                  ButtonSegment(value: 0, label: Text('Clients', key: Key('coach_tab_clients'))),
                  ButtonSegment(value: 1, label: Text('Content', key: Key('coach_tab_content'))),
                ],
                selected: {_tab},
                onSelectionChanged: (s) => setState(() => _tab = s.first),
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.resolveWith(
                      (s) => s.contains(WidgetState.selected) ? AppColors.accentFill : Colors.white),
                  foregroundColor: WidgetStateProperty.resolveWith(
                      (s) => s.contains(WidgetState.selected) ? Colors.white : AppColors.textSecondary),
                ),
              ),
            ),
            Expanded(child: _tab == 0 ? _clients(context) : const _ContentEditor()),
          ],
        ),
      ),
    );
  }

  Widget _clients(BuildContext context) {
    final filter = ref.watch(coachFilterProvider);
    final all = ref.watch(coachClientsProvider);
    final shown = ref.watch(filteredClientsProvider);
    int count(ClientFlag f) => all.where((c) => c.flag == f).length;
    final month5 = count(ClientFlag.month5);

    return ListView(
      key: const Key('coach_list'),
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
      children: [
        SizedBox(
          height: 40,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              for (final (f, label) in [
                (CoachFilter.all, 'All ${all.length}'),
                (CoachFilter.quiet, 'Quiet ${count(ClientFlag.quiet)}'),
                (CoachFilter.month5, 'Month 5 $month5'),
                (CoachFilter.checkInDue, 'Check-ins due ${count(ClientFlag.checkInDue)}'),
              ])
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    key: Key('filter_${f.name}'),
                    label: Text(label),
                    selected: filter == f,
                    showCheckmark: false,
                    onSelected: (_) => ref.read(coachFilterProvider.notifier).state = f,
                    selectedColor: AppColors.accentFill,
                    backgroundColor: Colors.white,
                    shape: const StadiumBorder(),
                    side: BorderSide(color: filter == f ? AppColors.accentFill : AppColors.border),
                    labelStyle: AppText.label(color: filter == f ? Colors.white : AppColors.textSecondary),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        AppCard(
          color: AppColors.warningTint,
          onTap: () => ref.read(coachFilterProvider.notifier).state = CoachFilter.month5,
          child: Row(
            children: [
              const IconBubble(Icons.error_outline_rounded, color: AppColors.warning, bg: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(month5 == 1 ? '1 client reaches month 5 this week' : '$month5 clients reach month 5 this week',
                        style: AppText.body().copyWith(fontWeight: FontWeight.w600)),
                    Text('Plan renewals before they finish', style: AppText.caption(color: AppColors.warning)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: AppColors.warning),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text('ACTIVE ROSTER (${shown.length})', style: AppText.caption()),
        const SizedBox(height: 8),
        for (final c in shown) ...[
          _ClientCard(
            client: c,
            expanded: _expanded == c.id,
            onTap: () => setState(() => _expanded = _expanded == c.id ? null : c.id),
          ),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _ClientCard extends ConsumerWidget {
  const _ClientCard({required this.client, required this.expanded, required this.onTap});
  final CoachClient client;
  final bool expanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tone = switch (client.flag) {
      ClientFlag.checkInSubmitted => ChipTone.success,
      ClientFlag.month5 || ClientFlag.quiet => ChipTone.warning,
      _ => ChipTone.info,
    };
    return AppCard(
      key: Key('client_${client.id}'),
      onTap: onTap,
      child: Column(
        children: [
          Row(
            children: [
              Opacity(
                opacity: client.access ? 1 : 0.5,
                child: CircleAvatar(radius: 24, backgroundImage: AssetImage(client.avatar)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(client.name, style: AppText.oswald(18, 600)),
                    Text('${client.tier == Tier.oneToOne ? '1:1' : client.tier.label.split(' ').first}, week ${client.week}',
                        style: AppText.caption()),
                    const SizedBox(height: 6),
                    TintChip(client.status, tone: client.access ? tone : ChipTone.danger),
                  ],
                ),
              ),
              PetalFlower(petals: _petals(client.flowerProgress), size: 36),
              const SizedBox(width: 4),
              Icon(expanded ? Icons.expand_less_rounded : Icons.chevron_right_rounded, color: AppColors.textSecondary),
            ],
          ),
          if (expanded) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: PrimaryButton(
                    key: Key('retain_${client.id}'),
                    label: 'Retain',
                    onPressed: () => ref.read(coachClientsProvider.notifier).retain(client.id),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: SecondaryButton(
                    key: Key('revoke_${client.id}'),
                    label: 'Revoke',
                    expand: true,
                    icon: Icons.person_off_outlined,
                    onPressed: () => ref.read(coachClientsProvider.notifier).revoke(client.id),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  List<double> _petals(double p) => List.generate(6, (i) => (p * 6 - i).clamp(0.0, 1.0));
}

class _ContentEditor extends ConsumerWidget {
  const _ContentEditor();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final copy = ref.watch(notificationCopyProvider);
    const labels = {'reminder': 'Habit reminder', 'unlock': 'Week unlocked', 'checkin': 'Check-in open'};
    return ListView(
      key: const Key('content_list'),
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
      children: [
        Text('Edit content without a new app release.', style: AppText.body(color: AppColors.textSecondary)),
        const SectionHeader('Library'),
        for (final (icon, title, meta) in [
          (Icons.play_circle_outline_rounded, 'Lessons', '${lessons.length} weeks, 6 blocks'),
          (Icons.spa_outlined, 'Habit library', '${habitLibrary.length} habits'),
          (Icons.picture_as_pdf_outlined, 'Resources', '25 PDFs'),
          (Icons.assignment_outlined, 'Check-in questions', '${blockCheckIn.length} per block'),
        ]) ...[
          AppCard(
            onTap: () => showMockSnack(context, '$title editor is mocked in this demo'),
            child: Row(
              children: [
                IconBubble(icon),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: AppText.body().copyWith(fontWeight: FontWeight.w600)),
                      Text(meta, style: AppText.caption()),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
              ],
            ),
          ),
          const SizedBox(height: 10),
        ],
        const SectionHeader('Notification wording'),
        for (final e in copy.entries) ...[
          AppCard(
            key: Key('copy_${e.key}'),
            onTap: () => _edit(context, ref, e.key, labels[e.key]!, e.value),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(labels[e.key]!, style: AppText.label(weight: FontWeight.w600)),
                      const SizedBox(height: 2),
                      Text(e.value, style: AppText.body(color: AppColors.textSecondary)),
                    ],
                  ),
                ),
                const Icon(Icons.edit_outlined, color: AppColors.accentFill),
              ],
            ),
          ),
          const SizedBox(height: 10),
        ],
      ],
    );
  }

  void _edit(BuildContext context, WidgetRef ref, String key, String label, String value) {
    final ctrl = TextEditingController(text: value);
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(label, style: AppText.title()),
        content: TextField(key: const Key('copy_field'), controller: ctrl, maxLines: 3),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
          FilledButton(
            key: const Key('copy_save'),
            onPressed: () {
              ref.read(notificationCopyProvider.notifier).update(key, ctrl.text.trim());
              Navigator.of(ctx).pop();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    ).whenComplete(ctrl.dispose);
  }
}
