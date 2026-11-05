import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petal_path/app.dart';
import 'package:petal_path/data/mock_data.dart';
import 'package:petal_path/models/models.dart';
import 'package:petal_path/state/providers.dart';

/// Pumps the app on a 393x852 phone and signs in with [tier] (or stays on
/// the welcome screen when null). Layout overflows fail the test.
Future<ProviderContainer> pumpApp(WidgetTester tester, {Tier? tier}) async {
  tester.view.physicalSize = const Size(1179, 2556);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  final container = ProviderContainer();
  addTearDown(container.dispose);
  await tester.pumpWidget(UncontrolledProviderScope(container: container, child: const PetalPathApp()));
  if (tier != null) {
    await tester.tap(find.byKey(Key('plan_${tier.name}')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('sign_in')));
    await tester.pumpAndSettle();
  }
  return container;
}

/// Scrolls [target] into the viewport (not just the cache extent) of the
/// list keyed [listKey].
Future<void> reveal(WidgetTester tester, Finder target, String listKey) async {
  await tester.scrollUntilVisible(target, 200,
      scrollable: find.descendant(of: find.byKey(Key(listKey)), matching: find.byType(Scrollable)));
  await tester.ensureVisible(target);
  await tester.pumpAndSettle();
}

Future<void> openTab(WidgetTester tester, String label) async {
  await tester.tap(find.byKey(Key('tab_${label.toLowerCase()}')));
  await tester.pumpAndSettle();
}

void main() {
  group('programme unlocks', () {
    test('1:1 client on day 44 is in week 7, block 2, week 8 opens Mon 16 Nov', () {
      final p = programmeFor(demoAccounts[Tier.oneToOne]!, demoToday);
      expect(p.currentWeek, 7);
      expect(p.dayOfWeek, 3);
      expect(p.block.number, 2);
      expect(p.isUnlocked(7), isTrue);
      expect(p.isUnlocked(8), isFalse);
      expect(p.nextUnlock, DateTime(2026, 11, 16));
    });

    test('membership unlocks all 24 weeks from day 1', () {
      final p = programmeFor(demoAccounts[Tier.membership]!, demoToday);
      expect(p.unlockedThrough, totalWeeks);
      expect(p.nextUnlock, isNull);
    });

    test('group client on first login is in week 1', () {
      final p = programmeFor(demoAccounts[Tier.group]!, demoToday);
      expect(p.currentWeek, 1);
      expect(p.unlockedThrough, 1);
    });
  });

  testWidgets('welcome screen shows plans and sign in', (tester) async {
    await pumpApp(tester);
    expect(find.text('Petal Path'), findsOneWidget);
    expect(find.text('Group programme'), findsOneWidget);
    expect(find.text('1:1 Coaching'), findsOneWidget);
    expect(find.text('Membership'), findsOneWidget);
    expect(find.byKey(const Key('sign_in')), findsOneWidget);
  });

  testWidgets('1:1 home shows this week, habits and new unlocks', (tester) async {
    await pumpApp(tester, tier: Tier.oneToOne);
    expect(find.text('Good morning, Maya'), findsOneWidget);
    expect(find.text('Week 7 of 24'), findsOneWidget);
    expect(find.text('Block 2: Energy'), findsOneWidget);
    expect(find.text('Drink 2L of water'), findsOneWidget);
    await reveal(tester, find.byKey(const Key('open_week')), 'home_list');
    expect(find.text('Block 2 check-in is open'), findsOneWidget);
  });

  testWidgets('group client on first login sees the empty state', (tester) async {
    await pumpApp(tester, tier: Tier.group);
    expect(find.text('Welcome, Maya'), findsOneWidget);
    expect(find.text('No habits yet'), findsOneWidget);
    expect(find.text('Week 2 unlocks in 7 days'), findsOneWidget);
  });

  testWidgets('learn tab locks future weeks for drip tiers', (tester) async {
    await pumpApp(tester, tier: Tier.oneToOne);
    await openTab(tester, 'Learn');
    expect(find.text('Week 8 unlocks Mon 16 Nov'), findsOneWidget);
    expect(find.text('Lesson 7: Routines that bend, not break'), findsOneWidget);
    expect(find.descendant(of: find.byKey(const Key('week_chip_8')), matching: find.byIcon(Icons.lock_outline_rounded)), findsOneWidget);
  });

  testWidgets('membership has no locked weeks', (tester) async {
    await pumpApp(tester, tier: Tier.membership);
    await openTab(tester, 'Learn');
    expect(find.textContaining('unlocks'), findsNothing);
    expect(find.textContaining('every week is open'), findsOneWidget);
  });

  testWidgets('lesson detail marks the lesson complete', (tester) async {
    await pumpApp(tester, tier: Tier.oneToOne);
    await openTab(tester, 'Learn');
    await tester.tap(find.byKey(const Key('lesson_card')));
    await tester.pumpAndSettle();
    expect(find.text('Routines that bend, not break'), findsOneWidget);
    await tester.tap(find.byKey(const Key('mark_complete')));
    await tester.pump();
    expect(find.text('Lesson complete'), findsOneWidget);
  });

  testWidgets('ticking a habit grows the flower and unticking never shrinks it', (tester) async {
    final c = await pumpApp(tester, tier: Tier.oneToOne);
    await openTab(tester, 'Habits');
    expect(find.text('3 of 5'), findsOneWidget);
    final before = c.read(flowerProvider);

    await tester.tap(find.byKey(const Key('habit_check_protein')));
    await tester.pumpAndSettle();
    expect(find.text('4 of 5'), findsOneWidget);
    final grown = c.read(flowerProvider);
    expect(grown.habitsDone, before.habitsDone + 1);
    expect(grown.petals[1], greaterThan(before.petals[1]));

    await tester.tap(find.byKey(const Key('habit_check_protein')));
    await tester.pumpAndSettle();
    expect(find.text('3 of 5'), findsOneWidget);
    expect(c.read(flowerProvider).petals, grown.petals);
    expect(c.read(flowerProvider).habitsDone, grown.habitsDone);
  });

  testWidgets('habit library adds a coach habit and a custom one', (tester) async {
    final c = await pumpApp(tester, tier: Tier.oneToOne);
    await openTab(tester, 'Habits');
    await tester.tap(find.byKey(const Key('add_habit')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('lib_add_outside')));
    await tester.pump();
    expect(c.read(habitsProvider).any((h) => h.id == 'outside'), isTrue);
    await tester.enterText(find.byKey(const Key('habit_name')), 'Fill my water bottle');
    await tester.pump();
    await tester.tap(find.byKey(const Key('save_habit')));
    await tester.pumpAndSettle();
    expect(c.read(habitsProvider).map((h) => h.title), contains('Fill my water bottle'));
    await reveal(tester, find.text('Fill my water bottle'), 'habits_list');
    expect(find.text('Mine'), findsWidgets);
  });

  testWidgets('progress shows the flower, activity syncs from the (simulated) health app', (tester) async {
    await pumpApp(tester, tier: Tier.oneToOne);
    await openTab(tester, 'Progress');
    expect(find.byKey(const Key('flower')), findsOneWidget);
    expect(find.text('Your flower only grows. Missed days never take a petal away.'), findsOneWidget);
    await tester.tap(find.byKey(const Key('seg_activity')));
    await tester.pumpAndSettle();
    expect(find.text('5,210'), findsOneWidget);
    await tester.tap(find.byKey(const Key('sync_health')));
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    expect(find.text('6,842'), findsOneWidget);
    expect(find.text('Yoga'), findsOneWidget);
    expect(find.text('Last synced 09:41'), findsOneWidget);
  });

  testWidgets('block check-in walks four steps and is sent', (tester) async {
    final c = await pumpApp(tester, tier: Tier.oneToOne);
    await reveal(tester, find.byKey(const Key('checkin_card')), 'home_list');
    await tester.tap(find.byKey(const Key('checkin_card')));
    await tester.pumpAndSettle();
    expect(find.text('Step 1 of 4'), findsOneWidget);
    await tester.tap(find.byKey(const Key('option_Steady')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('checkin_next')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('checkin_text')), 'School holidays and late nights.');
    await tester.tap(find.byKey(const Key('checkin_next')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('checkin_next')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('option_Water')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('checkin_next')));
    await tester.pumpAndSettle();
    expect(find.text('Sent to your coach'), findsOneWidget);
    expect(c.read(checkInsProvider), contains(2));
  });

  testWidgets('coach view filters clients and revokes access', (tester) async {
    await pumpApp(tester, tier: Tier.oneToOne);
    await openTab(tester, 'Me');
    expect(find.text('Nutrition targets'), findsOneWidget);
    await reveal(tester, find.byKey(const Key('open_coach_view')), 'profile_list');
    await tester.tap(find.byKey(const Key('open_coach_view')));
    await tester.pumpAndSettle();
    expect(find.text('1 client reaches month 5 this week'), findsOneWidget);
    await tester.tap(find.byKey(const Key('revoke_priya')));
    await tester.pump();
    expect(find.text('Access revoked'), findsOneWidget);
    await tester.tap(find.byKey(const Key('filter_quiet')));
    await tester.pumpAndSettle();
    expect(find.text('Hannah Lee'), findsOneWidget);
    expect(find.text('Priya Shah'), findsNothing);
  });

  testWidgets('coach edits notification wording and the client sees it', (tester) async {
    final c = await pumpApp(tester, tier: Tier.oneToOne);
    c.read(notificationCopyProvider.notifier).update('reminder', 'Tiny step: one habit is enough today.');
    await tester.tap(find.byKey(const Key('bell')).first);
    await tester.pumpAndSettle();
    expect(find.text('Tiny step: one habit is enough today.'), findsOneWidget);
    expect(find.text('Week 7 is open. One lesson, one idea, no rush.'), findsOneWidget);
  });

  testWidgets('group tier hides the 1:1 personal plan', (tester) async {
    await pumpApp(tester, tier: Tier.group);
    await openTab(tester, 'Me');
    expect(find.text('Nutrition targets'), findsNothing);
    expect(find.textContaining('come with 1:1 coaching'), findsOneWidget);
  });
}
