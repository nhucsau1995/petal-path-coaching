import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/mock_data.dart';
import '../models/models.dart';
import '../state/providers.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

/// Add a habit: from the coach's library, or a client's own habit.
class HabitLibraryScreen extends ConsumerStatefulWidget {
  const HabitLibraryScreen({super.key});

  @override
  ConsumerState<HabitLibraryScreen> createState() => _HabitLibraryScreenState();
}

class _HabitLibraryScreenState extends ConsumerState<HabitLibraryScreen> {
  HabitCategory _category = HabitCategory.movement;
  final _name = TextEditingController();
  final _days = {0, 1, 2, 3, 4};
  static const _dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _addFromLibrary(LibraryHabit l) {
    ref.read(habitsProvider.notifier).add(
          Habit(id: l.id, title: l.title, source: HabitSource.coach, category: l.category),
        );
    showMockSnack(context, 'Added "${l.title}"');
  }

  void _saveOwn() {
    final title = _name.text.trim();
    if (title.isEmpty) return;
    ref.read(habitsProvider.notifier).add(
          Habit(id: 'mine_${title.hashCode}', title: title, source: HabitSource.mine, category: _category),
        );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final added = ref.watch(habitsProvider).map((h) => h.id).toSet();
    final items = habitLibrary.where((l) => l.category == _category).toList();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 8, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('COACHING PLAN', style: AppText.caption()),
                        Text('Add a habit', style: AppText.display()),
                      ],
                    ),
                  ),
                  IconButton(
                    key: const Key('close_library'),
                    tooltip: 'Close',
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                children: [
                  Wrap(
                    spacing: 8,
                    children: [
                      for (final c in HabitCategory.values)
                        ChoiceChip(
                          key: Key('cat_${c.name}'),
                          label: Text(c.label),
                          selected: _category == c,
                          showCheckmark: false,
                          onSelected: (_) => setState(() => _category = c),
                          shape: const StadiumBorder(),
                          backgroundColor: Colors.white,
                          selectedColor: AppColors.accentTint,
                          side: BorderSide(color: _category == c ? AppColors.accentFill : AppColors.border),
                          labelStyle: AppText.label(color: _category == c ? AppColors.accentFill : AppColors.textSecondary),
                        ),
                    ],
                  ),
                  SectionHeader("From your coach's library", trailing: '${items.length} habits'),
                  for (final l in items) ...[
                    AppCard(
                      child: Row(
                        children: [
                          const IconBubble(Icons.spa_outlined),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(l.title, style: AppText.body().copyWith(fontWeight: FontWeight.w600)),
                                Text(l.hint, style: AppText.caption()),
                              ],
                            ),
                          ),
                          IconButton(
                            key: Key('lib_add_${l.id}'),
                            tooltip: added.contains(l.id) ? 'Added' : 'Add ${l.title}',
                            onPressed: added.contains(l.id) ? null : () => _addFromLibrary(l),
                            style: IconButton.styleFrom(
                              side: const BorderSide(color: AppColors.borderStrong, width: 1.5),
                              minimumSize: const Size(44, 44),
                            ),
                            icon: Icon(added.contains(l.id) ? Icons.check_rounded : Icons.add_rounded,
                                color: AppColors.accentFill),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Row(
                      children: [
                        const Expanded(child: Divider(color: AppColors.border)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text('OR CREATE YOUR OWN', style: AppText.caption()),
                        ),
                        const Expanded(child: Divider(color: AppColors.border)),
                      ],
                    ),
                  ),
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Habit name', style: AppText.label(color: AppColors.textSecondary)),
                        const SizedBox(height: 8),
                        TextField(
                          key: const Key('habit_name'),
                          controller: _name,
                          style: AppText.body(),
                          onChanged: (_) => setState(() {}),
                          decoration: InputDecoration(
                            hintText: 'e.g. Fill my water bottle',
                            hintStyle: AppText.body(color: AppColors.textTertiary),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(AppRadius.input),
                              borderSide: const BorderSide(color: AppColors.borderStrong, width: 1.5),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(AppRadius.input),
                              borderSide: const BorderSide(color: AppColors.accentFill, width: 2),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text('Frequency', style: AppText.label(color: AppColors.textSecondary)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            for (var i = 0; i < 7; i++)
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 2),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(10),
                                    onTap: () => setState(() => _days.contains(i) ? _days.remove(i) : _days.add(i)),
                                    child: Container(
                                      height: 44,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: _days.contains(i) ? AppColors.accentFill : AppColors.surfaceAlt,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(_dayNames[i],
                                          style: AppText.caption(
                                              color: _days.contains(i) ? Colors.white : AppColors.textSecondary)),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
              child: PrimaryButton(
                key: const Key('save_habit'),
                label: 'Save habit',
                icon: Icons.arrow_forward_rounded,
                onPressed: _name.text.trim().isEmpty ? null : _saveOwn,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
