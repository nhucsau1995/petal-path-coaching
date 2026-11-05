/// Plain data models for the Petal Path POC. All data is local mock data.
library;

enum Tier { group, oneToOne, membership }

extension TierLabel on Tier {
  String get label => switch (this) {
        Tier.group => 'Group programme',
        Tier.oneToOne => '1:1 Coaching',
        Tier.membership => 'Membership',
      };

  /// Membership unlocks everything from day 1, the other tiers drip weekly.
  bool get dripsWeekly => this != Tier.membership;

  /// Only 1:1 clients get a personalised plan (nutrition targets, workout log,
  /// custom check-in form).
  bool get hasPersonalPlan => this == Tier.oneToOne;
}

class ClientProfile {
  const ClientProfile({
    required this.name,
    required this.firstName,
    required this.tier,
    required this.firstLogin,
    required this.renewsOn,
    required this.avatar,
    this.onboardingDone = false,
  });

  final String name;
  final String firstName;
  final Tier tier;
  final DateTime firstLogin;
  final DateTime renewsOn;
  final String avatar;
  final bool onboardingDone;
}

class Block {
  const Block(this.number, this.title);
  final int number;
  final String title;
}

class Lesson {
  const Lesson({
    required this.week,
    required this.title,
    required this.summary,
    required this.minutes,
    required this.image,
    required this.tasks,
    required this.resources,
  });

  final int week;
  final String title;
  final String summary;
  final int minutes;
  final String image;
  final List<String> tasks;
  final List<Resource> resources;
}

class Resource {
  const Resource(this.title, this.meta);
  final String title;
  final String meta;
}

enum HabitSource { coach, mine }

enum HabitCategory { movement, food, sleep, calm }

extension HabitCategoryLabel on HabitCategory {
  String get label => switch (this) {
        HabitCategory.movement => 'Movement',
        HabitCategory.food => 'Food',
        HabitCategory.sleep => 'Sleep',
        HabitCategory.calm => 'Calm',
      };
}

class Habit {
  const Habit({
    required this.id,
    required this.title,
    required this.source,
    required this.category,
    this.doneToday = false,
    this.week = const [false, false, false, false, false, false, false],
  });

  final String id;
  final String title;
  final HabitSource source;
  final HabitCategory category;
  final bool doneToday;

  /// Mon..Sun completion for the current week (today included).
  final List<bool> week;

  Habit copyWith({bool? doneToday, List<bool>? week}) => Habit(
        id: id,
        title: title,
        source: source,
        category: category,
        doneToday: doneToday ?? this.doneToday,
        week: week ?? this.week,
      );
}

class LibraryHabit {
  const LibraryHabit(this.id, this.title, this.hint, this.category);
  final String id;
  final String title;
  final String hint;
  final HabitCategory category;
}

enum ActivitySource { synced, manual }

class ActivityEntry {
  const ActivityEntry(this.type, this.minutes, this.source, {this.note = ''});
  final String type;
  final int minutes;
  final ActivitySource source;
  final String note;
}

class CheckInQuestion {
  const CheckInQuestion.choice(this.prompt, this.options)
      : kind = QuestionKind.choice,
        hint = '';
  const CheckInQuestion.text(this.prompt, {this.hint = ''})
      : kind = QuestionKind.text,
        options = const [];
  const CheckInQuestion.scale(this.prompt)
      : kind = QuestionKind.scale,
        options = const [],
        hint = '';

  final String prompt;
  final QuestionKind kind;
  final List<String> options;
  final String hint;
}

enum QuestionKind { choice, text, scale }

enum ClientFlag { none, quiet, month5, checkInDue, checkInSubmitted }

class CoachClient {
  const CoachClient({
    required this.id,
    required this.name,
    required this.tier,
    required this.week,
    required this.avatar,
    required this.flag,
    required this.status,
    required this.flowerProgress,
    this.renews = '',
    this.daysQuiet = 0,
    this.access = true,
  });

  final String id;
  final String name;
  final Tier tier;
  final int week;
  final String avatar;
  final ClientFlag flag;
  final String status;
  final double flowerProgress;
  final String renews;
  final int daysQuiet;
  final bool access;

  CoachClient copyWith({bool? access, String? status}) => CoachClient(
        id: id,
        name: name,
        tier: tier,
        week: week,
        avatar: avatar,
        flag: flag,
        status: status ?? this.status,
        flowerProgress: flowerProgress,
        renews: renews,
        daysQuiet: daysQuiet,
        access: access ?? this.access,
      );
}

class AppNotification {
  const AppNotification(this.kind, this.title, this.body, this.when);
  final String kind;
  final String title;
  final String body;
  final String when;
}
