import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:petal_path/app.dart';

/// Real screenshots of the key screens. Run through test_driver/integration_test.dart,
/// which writes each PNG to screenshots/NN-name.png.
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Future<void> settle(WidgetTester tester, [int ms = 900]) async {
    for (var i = 0; i < ms ~/ 100; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  Future<void> tap(WidgetTester tester, String key) async {
    final f = find.byKey(Key(key)).first;
    await tester.ensureVisible(f);
    await settle(tester, 300);
    await tester.tap(f);
    await settle(tester);
  }

  Future<void> scrollTo(WidgetTester tester, String key, String listKey) async {
    await tester.scrollUntilVisible(find.byKey(Key(key)), 200,
        scrollable: find.descendant(of: find.byKey(Key(listKey)), matching: find.byType(Scrollable)));
    await settle(tester, 300);
  }

  testWidgets('capture key screens', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: PetalPathApp()));
    await binding.convertFlutterSurfaceToImage();
    await settle(tester, 1500);
    await binding.takeScreenshot('01-welcome');

    await tap(tester, 'plan_oneToOne');
    await tap(tester, 'sign_in');
    await settle(tester, 1200);
    await binding.takeScreenshot('02-home');

    await tap(tester, 'tab_learn');
    await binding.takeScreenshot('03-learn');

    await tap(tester, 'lesson_card');
    await binding.takeScreenshot('04-lesson');
    await tap(tester, 'back');

    await tap(tester, 'tab_habits');
    await binding.takeScreenshot('05-habits');

    await tap(tester, 'tab_progress');
    await binding.takeScreenshot('06-flower');

    await tap(tester, 'seg_activity');
    await tap(tester, 'sync_health');
    await settle(tester, 1500);
    await binding.takeScreenshot('07-activity');

    await tap(tester, 'tab_home');
    await scrollTo(tester, 'checkin_card', 'home_list');
    await tap(tester, 'checkin_card');
    await tap(tester, 'option_Steady');
    await binding.takeScreenshot('08-check-in');
    await tap(tester, 'back');

    await tap(tester, 'tab_me');
    await binding.takeScreenshot('09-me');
    await scrollTo(tester, 'open_coach_view', 'profile_list');
    await tap(tester, 'open_coach_view');
    await binding.takeScreenshot('10-coach');
    await tap(tester, 'back');

    await scrollTo(tester, 'sign_out', 'profile_list');
    await tap(tester, 'sign_out');
    await tap(tester, 'plan_group');
    await tap(tester, 'sign_in');
    await settle(tester, 1200);
    await binding.takeScreenshot('11-home-first-login');
  });
}
