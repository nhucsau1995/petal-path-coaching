import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:petal_path/app.dart';

/// Paced ~22 s walkthrough with real taps, recorded for the demo GIF.
/// Prints PP_DEMO_START / PP_DEMO_END to logcat so the capture script can
/// trim the recording to exactly the walkthrough.
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

  /// Hold for [ms] of wall-clock time while frames keep rendering.
  Future<void> hold(WidgetTester tester, int ms) async {
    final sw = Stopwatch()..start();
    while (sw.elapsedMilliseconds < ms) {
      await tester.pump(const Duration(milliseconds: 50));
      await Future<void>.delayed(const Duration(milliseconds: 50));
    }
  }

  Future<void> tap(WidgetTester tester, String key, {int after = 1100}) async {
    final f = find.byKey(Key(key)).first;
    await tester.ensureVisible(f);
    await hold(tester, 250);
    await tester.tap(f);
    await hold(tester, after);
  }

  Future<void> scroll(WidgetTester tester, String listKey, double dy) async {
    await tester.drag(find.descendant(of: find.byKey(Key(listKey)), matching: find.byType(Scrollable)).first, Offset(0, -dy));
    await hold(tester, 700);
  }

  testWidgets('demo walkthrough', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: PetalPathApp()));
    await hold(tester, 800);
    debugPrint('PP_DEMO_START');
    await hold(tester, 1200);

    await tap(tester, 'plan_oneToOne', after: 500);
    await tap(tester, 'sign_in', after: 1800);
    await tap(tester, 'home_check_protein', after: 900);
    await scroll(tester, 'home_list', 380);

    await tap(tester, 'tab_learn', after: 1300);
    await tap(tester, 'lesson_card', after: 1200);
    await tap(tester, 'video_player', after: 900);
    await tap(tester, 'mark_complete', after: 1100);
    await tap(tester, 'back', after: 600);

    await tap(tester, 'tab_habits', after: 900);
    await tap(tester, 'habit_check_stretch', after: 900);

    await tap(tester, 'tab_progress', after: 1600);
    await tap(tester, 'seg_activity', after: 700);
    await tap(tester, 'sync_health', after: 1600);

    await tap(tester, 'tab_me', after: 900);
    await scroll(tester, 'profile_list', 420);
    await tap(tester, 'open_coach_view', after: 1300);
    await tap(tester, 'revoke_priya', after: 1500);

    debugPrint('PP_DEMO_END');
    await hold(tester, 500);
  });
}
