import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'screens/habits_screen.dart';
import 'screens/home_screen.dart';
import 'screens/learn_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/progress_screen.dart';
import 'screens/welcome_screen.dart';
import 'state/providers.dart';
import 'theme/app_theme.dart';

class PetalPathApp extends ConsumerWidget {
  const PetalPathApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final signedIn = ref.watch(sessionProvider.select((s) => s != null));
    return MaterialApp(
      title: 'Petal Path',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      home: signedIn ? const AppShell() : const WelcomeScreen(),
    );
  }
}

/// Tab shell with the shared five-tab bar from the design.
class AppShell extends ConsumerWidget {
  const AppShell({super.key});

  static const _tabs = [
    (Icons.home_outlined, Icons.home_rounded, 'Home'),
    (Icons.play_circle_outline_rounded, Icons.play_circle_rounded, 'Learn'),
    (Icons.check_circle_outline_rounded, Icons.check_circle_rounded, 'Habits'),
    (Icons.local_florist_outlined, Icons.local_florist_rounded, 'Progress'),
    (Icons.person_outline_rounded, Icons.person_rounded, 'Me'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index = ref.watch(tabIndexProvider);
    return Scaffold(
      body: IndexedStack(
        index: index,
        children: const [HomeScreen(), LearnScreen(), HabitsScreen(), ProgressScreen(), ProfileScreen()],
      ),
      bottomNavigationBar: DecoratedBox(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: NavigationBarTheme(
          data: NavigationBarThemeData(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.transparent,
            indicatorColor: AppColors.accentTint,
            height: 68,
            labelTextStyle: WidgetStateProperty.resolveWith(
              (s) => AppText.caption(
                color: s.contains(WidgetState.selected) ? AppColors.accentFill : AppColors.textSecondary,
              ),
            ),
          ),
          child: NavigationBar(
            selectedIndex: index,
            onDestinationSelected: (i) => ref.read(tabIndexProvider.notifier).state = i,
            destinations: [
              for (final (outline, filled, label) in _tabs)
                NavigationDestination(
                  key: Key('tab_${label.toLowerCase()}'),
                  icon: Icon(outline, color: AppColors.textSecondary),
                  selectedIcon: Icon(filled, color: AppColors.accentFill),
                  label: label,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
