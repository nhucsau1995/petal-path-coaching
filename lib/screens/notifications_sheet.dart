import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/providers.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

/// In-app preview of the push notifications (reminders, unlocks, check-ins).
/// Wording comes from the coach-editable copy.
void showNotifications(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppColors.background,
    showDragHandle: true,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.card))),
    builder: (_) => const _NotificationsSheet(),
  );
}

class _NotificationsSheet extends ConsumerWidget {
  const _NotificationsSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(notificationsProvider);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Notifications', style: AppText.title()),
            const SizedBox(height: 12),
            if (items.isEmpty) Text('All reminders are off.', style: AppText.body(color: AppColors.textSecondary)),
            for (final n in items) ...[
              AppCard(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconBubble(switch (n.kind) {
                      'unlock' => Icons.lock_open_rounded,
                      'checkin' => Icons.assignment_outlined,
                      _ => Icons.notifications_active_outlined,
                    }),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(child: Text(n.title, style: AppText.label(weight: FontWeight.w600))),
                              Text(n.when, style: AppText.caption()),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(n.body, style: AppText.body(color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
            ],
          ],
        ),
      ),
    );
  }
}
