import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/mock_data.dart';
import '../models/models.dart';
import '../state/providers.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import 'check_in_screen.dart';
import 'coach_screen.dart';
import 'learn_screen.dart';
import 'notifications_sheet.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = ref.watch(sessionProvider)!;
    final reminders = ref.watch(remindersProvider);
    final renews = shortDate(p.renewsOn).split(' ').skip(1).join(' ');

    return SafeArea(
      bottom: false,
      child: ListView(
        key: const Key('profile_list'),
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          BrandHeader(onBell: () => showNotifications(context)),
          const SizedBox(height: 8),
          Center(
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.accentTint),
              child: CircleAvatar(radius: 46, backgroundImage: AssetImage(p.avatar)),
            ),
          ),
          const SizedBox(height: 10),
          Center(child: Text(p.name, style: AppText.oswald(26, 600))),
          const SizedBox(height: 6),
          Center(child: TintChip('${p.tier.label}, renews $renews', icon: Icons.verified_outlined)),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (p.tier.hasPersonalPlan)
                  AppCard(
                    key: const Key('nutrition_card'),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.restaurant_outlined, color: AppColors.accentFill),
                            const SizedBox(width: 8),
                            Expanded(child: Text('Nutrition targets', style: AppText.title())),
                            const TintChip('Set by your coach'),
                          ],
                        ),
                        const SizedBox(height: 14),
                        const Row(
                          children: [
                            _Target('1,850', 'kcal / day'),
                            _Target('110 g', 'protein'),
                            _Target('25 g', 'fibre'),
                          ],
                        ),
                      ],
                    ),
                  )
                else
                  AppCard(
                    child: Row(
                      children: [
                        const IconBubble(Icons.workspace_premium_outlined),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text('Personal targets, workouts and a custom check-in come with 1:1 coaching.',
                              style: AppText.body(color: AppColors.textSecondary)),
                        ),
                      ],
                    ),
                  ),
                const SectionHeader('Account and programme'),
                AppCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      if (p.tier == Tier.oneToOne)
                        _Row(
                          icon: Icons.assignment_turned_in_outlined,
                          title: 'Onboarding form',
                          trailing: p.onboardingDone
                              ? const TintChip('Completed', tone: ChipTone.success)
                              : const TintChip('To do', tone: ChipTone.warning),
                          onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
                            builder: (_) => CheckInScreen(
                              title: '1:1 onboarding',
                              questions: onboardingForm,
                              onSubmit: (ref) => ref.read(sessionProvider.notifier).completeOnboarding(),
                            ),
                          )),
                        ),
                      _Row(
                        icon: Icons.notifications_active_outlined,
                        title: 'Reminders',
                        subtitle: '08:00 and 19:30',
                      ),
                      for (final e in reminders.entries)
                        Padding(
                          padding: const EdgeInsets.only(left: 68, right: 8),
                          child: SwitchListTile(
                            key: Key('toggle_${e.key}'),
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                            title: Text(e.key, style: AppText.label()),
                            value: e.value,
                            onChanged: (v) => ref.read(remindersProvider.notifier).state = {...reminders, e.key: v},
                          ),
                        ),
                      _Row(
                        icon: Icons.monitor_heart_outlined,
                        title: 'Health data',
                        trailing: const TintChip('Connected (demo)', tone: ChipTone.info),
                        onTap: () => showMockSnack(context, 'Health sync is simulated in this demo'),
                      ),
                      _Row(
                        icon: Icons.lock_outline_rounded,
                        title: 'Privacy and my data',
                        onTap: () => _privacy(context),
                      ),
                      _Row(
                        key: const Key('open_coach_view'),
                        icon: Icons.shield_outlined,
                        title: 'Coach view',
                        subtitle: 'Demo: open the coach dashboard',
                        onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const CoachScreen())),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                SecondaryButton(
                  key: const Key('sign_out'),
                  label: 'Sign out',
                  expand: true,
                  icon: Icons.logout_rounded,
                  onPressed: () {
                    ref.read(tabIndexProvider.notifier).state = 0;
                    ref.read(selectedWeekProvider.notifier).state = null;
                    ref.read(sessionProvider.notifier).signOut();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _privacy(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: AppColors.background,
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Privacy and my data', style: AppText.title()),
              const SizedBox(height: 12),
              for (final line in [
                'Health data is only read after you allow it, and only the types you pick.',
                'Your check-ins and body data are visible to you and your coach only.',
                'You can download or delete your data at any time.',
                'This demo stores nothing: every value is sample data.',
              ])
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.check_rounded, size: 18, color: AppColors.accentFill),
                      const SizedBox(width: 8),
                      Expanded(child: Text(line, style: AppText.label())),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Target extends StatelessWidget {
  const _Target(this.value, this.label);
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(value, style: AppText.oswald(24, 700, color: AppColors.accentFill)),
          Text(label, style: AppText.caption()),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({super.key, required this.icon, required this.title, this.subtitle, this.trailing, this.onTap});
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      minVerticalPadding: 12,
      leading: IconBubble(icon),
      title: Text(title, style: AppText.body().copyWith(fontWeight: FontWeight.w600)),
      subtitle: subtitle == null ? null : Text(subtitle!, style: AppText.caption()),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ?trailing,
          if (onTap != null) const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
        ],
      ),
    );
  }
}
