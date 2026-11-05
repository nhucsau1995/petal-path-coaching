import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../data/mock_data.dart';
import '../models/models.dart';

/// The demo clock. Tests and captures override nothing: the date is fixed.
final clockProvider = Provider<DateTime>((ref) => demoToday);

// ---------------------------------------------------------------------------
// Session + tier

class SessionNotifier extends Notifier<ClientProfile?> {
  @override
  ClientProfile? build() => null;

  void signIn(Tier tier) {
    final account = demoAccounts[tier]!;
    state = account;
    ref.read(habitsProvider.notifier).loadFor(account);
    ref.read(flowerProvider.notifier).loadFor(account);
    ref.read(activityProvider.notifier).reset();
    ref.read(lessonProgressProvider.notifier).reset();
  }

  void completeOnboarding() {
    final s = state;
    if (s == null) return;
    state = ClientProfile(
      name: s.name,
      firstName: s.firstName,
      tier: s.tier,
      firstLogin: s.firstLogin,
      renewsOn: s.renewsOn,
      avatar: s.avatar,
      onboardingDone: true,
    );
  }

  void signOut() => state = null;
}

final sessionProvider = NotifierProvider<SessionNotifier, ClientProfile?>(SessionNotifier.new);

// ---------------------------------------------------------------------------
// Programme: date-based weekly unlocks counted from the first login.

class ProgrammeState {
  const ProgrammeState({
    required this.currentWeek,
    required this.dayOfWeek,
    required this.unlockedThrough,
    required this.nextUnlock,
  });

  /// 1-based programme week (1..24).
  final int currentWeek;

  /// 1-based day within the current programme week (1..7).
  final int dayOfWeek;

  /// Highest unlocked week. Membership: all 24 from day 1.
  final int unlockedThrough;

  /// When the next week opens, or null if everything is open.
  final DateTime? nextUnlock;

  Block get block => blocks[((currentWeek - 1) ~/ weeksPerBlock).clamp(0, blocks.length - 1)];
  bool isUnlocked(int week) => week <= unlockedThrough;
}

ProgrammeState programmeFor(ClientProfile profile, DateTime today) {
  final days = today.difference(profile.firstLogin).inDays.clamp(0, totalWeeks * 7 - 1);
  final week = days ~/ 7 + 1;
  final day = days % 7 + 1;
  if (!profile.tier.dripsWeekly) {
    return ProgrammeState(currentWeek: week, dayOfWeek: day, unlockedThrough: totalWeeks, nextUnlock: null);
  }
  final next = week < totalWeeks ? profile.firstLogin.add(Duration(days: week * 7)) : null;
  return ProgrammeState(currentWeek: week, dayOfWeek: day, unlockedThrough: week, nextUnlock: next);
}

final programmeProvider = Provider<ProgrammeState?>((ref) {
  final profile = ref.watch(sessionProvider);
  if (profile == null) return null;
  return programmeFor(profile, ref.watch(clockProvider));
});

/// Week the Learn tab is showing (defaults to the current week).
final selectedWeekProvider = StateProvider<int?>((ref) => null);

// ---------------------------------------------------------------------------
// Habits

class HabitsNotifier extends Notifier<List<Habit>> {
  @override
  List<Habit> build() => const [];

  void loadFor(ClientProfile p) {
    state = switch (p.tier) {
      Tier.oneToOne => [...coachHabits, ...myHabits],
      Tier.membership => [...coachHabits],
      Tier.group => const [],
    };
  }

  /// Tick or untick today's habit. Ticking feeds the flower; unticking never
  /// takes a petal away.
  void toggle(String id, {int todayIndex = 2}) {
    Habit? ticked;
    state = [
      for (final h in state)
        if (h.id == id)
          () {
            final done = !h.doneToday;
            final week = [...h.week]..[todayIndex] = done;
            final updated = h.copyWith(doneToday: done, week: week);
            if (done) ticked = updated;
            return updated;
          }()
        else
          h,
    ];
    if (ticked != null) ref.read(flowerProvider.notifier).credit(ticked!.id);
  }

  void add(Habit habit) {
    if (state.any((h) => h.id == habit.id)) return;
    state = [...state, habit];
  }
}

final habitsProvider = NotifierProvider<HabitsNotifier, List<Habit>>(HabitsNotifier.new);

// ---------------------------------------------------------------------------
// Flower: six petals, one per block. Fill only ever goes up.

class FlowerState {
  const FlowerState({required this.petals, required this.habitsDone, required this.creditedToday});

  final List<double> petals;
  final int habitsDone;

  /// Habit ids already credited today, so tick/untick/tick cannot farm petals.
  final Set<String> creditedToday;
}

const habitsPerPetal = 40;

class FlowerNotifier extends Notifier<FlowerState> {
  @override
  FlowerState build() => const FlowerState(petals: [0, 0, 0, 0, 0, 0], habitsDone: 0, creditedToday: {});

  void loadFor(ClientProfile p) {
    state = switch (p.tier) {
      Tier.oneToOne => const FlowerState(petals: [1, 0.6, 0, 0, 0, 0], habitsDone: 41, creditedToday: {'water', 'walk', 'lights'}),
      Tier.membership => const FlowerState(petals: [0.7, 0, 0, 0, 0, 0], habitsDone: 28, creditedToday: {'water', 'walk'}),
      Tier.group => const FlowerState(petals: [0, 0, 0, 0, 0, 0], habitsDone: 0, creditedToday: {}),
    };
  }

  void credit(String habitId) {
    if (state.creditedToday.contains(habitId)) return;
    final programme = ref.read(programmeProvider);
    final petal = programme == null ? 0 : (programme.currentWeek - 1) ~/ weeksPerBlock;
    final petals = [...state.petals];
    petals[petal] = (petals[petal] + 1 / habitsPerPetal).clamp(0.0, 1.0);
    state = FlowerState(
      petals: petals,
      habitsDone: state.habitsDone + 1,
      creditedToday: {...state.creditedToday, habitId},
    );
  }
}

final flowerProvider = NotifierProvider<FlowerNotifier, FlowerState>(FlowerNotifier.new);

// ---------------------------------------------------------------------------
// Lessons: completed lessons + ticked tasks.

class LessonProgress {
  const LessonProgress({this.completedWeeks = const {}, this.doneTasks = const {}});
  final Set<int> completedWeeks;
  final Set<String> doneTasks;
}

class LessonProgressNotifier extends Notifier<LessonProgress> {
  @override
  LessonProgress build() => const LessonProgress();

  void reset() => state = const LessonProgress();

  void toggleTask(int week, String task) {
    final key = '$week:$task';
    final tasks = {...state.doneTasks};
    tasks.contains(key) ? tasks.remove(key) : tasks.add(key);
    state = LessonProgress(completedWeeks: state.completedWeeks, doneTasks: tasks);
  }

  void complete(int week) =>
      state = LessonProgress(completedWeeks: {...state.completedWeeks, week}, doneTasks: state.doneTasks);
}

final lessonProgressProvider = NotifierProvider<LessonProgressNotifier, LessonProgress>(LessonProgressNotifier.new);

// ---------------------------------------------------------------------------
// Activity: manual logging + a simulated health-app sync.

class ActivityState {
  const ActivityState({
    required this.entries,
    required this.steps,
    required this.lastSynced,
    this.syncing = false,
    this.weightKg = 68.4,
    this.waistCm = 78,
    this.proteinG = 92,
  });

  final List<ActivityEntry> entries;
  final int steps;
  final String lastSynced;
  final bool syncing;
  final double weightKg;
  final int waistCm;
  final int proteinG;

  ActivityState copyWith({List<ActivityEntry>? entries, int? steps, String? lastSynced, bool? syncing, int? proteinG}) =>
      ActivityState(
        entries: entries ?? this.entries,
        steps: steps ?? this.steps,
        lastSynced: lastSynced ?? this.lastSynced,
        syncing: syncing ?? this.syncing,
        weightKg: weightKg,
        waistCm: waistCm,
        proteinG: proteinG ?? this.proteinG,
      );
}

const stepGoal = 8000;

class ActivityNotifier extends Notifier<ActivityState> {
  @override
  ActivityState build() => const ActivityState(entries: seedActivity, steps: 5210, lastSynced: '08:12');

  void reset() => state = build();

  /// Stand-in for Apple Health / Health Connect: no platform call, just a
  /// short delay and a fixed payload.
  Future<void> syncHealth({Duration delay = const Duration(milliseconds: 900)}) async {
    if (state.syncing) return;
    state = state.copyWith(syncing: true);
    await Future<void>.delayed(delay);
    final fresh = syncedFromHealth.where((e) => !state.entries.any((x) => x.type == e.type)).toList();
    state = state.copyWith(syncing: false, entries: [...state.entries, ...fresh], steps: 6842, lastSynced: '09:41');
  }

  void log(ActivityEntry entry) => state = state.copyWith(entries: [...state.entries, entry]);
}

final activityProvider = NotifierProvider<ActivityNotifier, ActivityState>(ActivityNotifier.new);

// ---------------------------------------------------------------------------
// Check-ins

class CheckInsNotifier extends Notifier<Set<int>> {
  @override
  Set<int> build() => const {};
  void submit(int block) => state = {...state, block};
}

final checkInsProvider = NotifierProvider<CheckInsNotifier, Set<int>>(CheckInsNotifier.new);

// ---------------------------------------------------------------------------
// Reminders + notification wording (editable by the coach).

final remindersProvider = StateProvider<Map<String, bool>>(
  (ref) => {'Habit reminders': true, 'New unlocks': true, 'Check-ins': true},
);

class NotificationCopyNotifier extends Notifier<Map<String, String>> {
  @override
  Map<String, String> build() => defaultNotificationCopy;
  void update(String key, String text) => state = {...state, key: text};
}

final notificationCopyProvider =
    NotifierProvider<NotificationCopyNotifier, Map<String, String>>(NotificationCopyNotifier.new);

final notificationsProvider = Provider<List<AppNotification>>((ref) {
  final copy = ref.watch(notificationCopyProvider);
  final p = ref.watch(programmeProvider);
  final on = ref.watch(remindersProvider);
  final week = p?.currentWeek ?? 1;
  return [
    if (on['New unlocks'] ?? true) AppNotification('unlock', 'New week unlocked', copy['unlock']!.replaceAll('{week}', '$week'), 'Mon 07:00'),
    if (on['Habit reminders'] ?? true) AppNotification('reminder', 'Habit reminder', copy['reminder']!, 'Today 08:00'),
    if (on['Check-ins'] ?? true) AppNotification('checkin', 'Check-in open', copy['checkin']!, 'Today 19:30'),
  ];
});

// ---------------------------------------------------------------------------
// Coach view

enum CoachFilter { all, quiet, month5, checkInDue }

final coachFilterProvider = StateProvider<CoachFilter>((ref) => CoachFilter.all);

class CoachClientsNotifier extends Notifier<List<CoachClient>> {
  @override
  List<CoachClient> build() => coachClients;

  void retain(String id) => _set(id, access: true, status: 'Access retained');
  void revoke(String id) => _set(id, access: false, status: 'Access revoked');

  void _set(String id, {required bool access, required String status}) =>
      state = [for (final c in state) c.id == id ? c.copyWith(access: access, status: status) : c];
}

final coachClientsProvider = NotifierProvider<CoachClientsNotifier, List<CoachClient>>(CoachClientsNotifier.new);

final filteredClientsProvider = Provider<List<CoachClient>>((ref) {
  final f = ref.watch(coachFilterProvider);
  final all = ref.watch(coachClientsProvider);
  return switch (f) {
    CoachFilter.all => all,
    CoachFilter.quiet => all.where((c) => c.flag == ClientFlag.quiet).toList(),
    CoachFilter.month5 => all.where((c) => c.flag == ClientFlag.month5).toList(),
    CoachFilter.checkInDue => all.where((c) => c.flag == ClientFlag.checkInDue).toList(),
  };
});

/// Bottom tab index for the shell.
final tabIndexProvider = StateProvider<int>((ref) => 0);
