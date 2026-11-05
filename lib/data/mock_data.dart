import '../models/models.dart';

/// Fixed demo "today" so screenshots and tests are deterministic:
/// Wednesday 11 Nov 2026.
final DateTime demoToday = DateTime(2026, 11, 11);

const totalWeeks = 24;
const weeksPerBlock = 4;

const blocks = [
  Block(1, 'Foundations'),
  Block(2, 'Energy'),
  Block(3, 'Fuel'),
  Block(4, 'Strength'),
  Block(5, 'Rest'),
  Block(6, 'Growing on your terms'),
];

/// One demo account per tier. Picking a plan on the welcome screen signs in
/// as that account.
final demoAccounts = <Tier, ClientProfile>{
  Tier.oneToOne: ClientProfile(
    name: 'Maya Collins',
    firstName: 'Maya',
    tier: Tier.oneToOne,
    firstLogin: DateTime(2026, 9, 28),
    renewsOn: DateTime(2027, 1, 12),
    avatar: 'assets/images/avatar-maya.jpg',
    onboardingDone: true,
  ),
  Tier.group: ClientProfile(
    name: 'Maya Collins',
    firstName: 'Maya',
    tier: Tier.group,
    firstLogin: DateTime(2026, 11, 11),
    renewsOn: DateTime(2027, 4, 28),
    avatar: 'assets/images/avatar-maya.jpg',
  ),
  Tier.membership: ClientProfile(
    name: 'Maya Collins',
    firstName: 'Maya',
    tier: Tier.membership,
    firstLogin: DateTime(2026, 10, 21),
    renewsOn: DateTime(2026, 12, 21),
    avatar: 'assets/images/avatar-maya.jpg',
  ),
};

const _weekTitles = [
  'Why small steps work',
  'Your energy map',
  'Habits that fit your brain',
  'Kind self-talk',
  'Morning anchors',
  'Movement you enjoy',
  'Routines that bend, not break',
  'Planning meals when your brain is busy',
  'Protein made simple',
  'Snacks without the guilt',
  'Hydration hacks',
  'Eating out calmly',
  'Strength basics at home',
  'Progress over perfect',
  'Walking as a reset',
  'Building your own plan',
  'Sleep and your cycle',
  'Wind-down routines',
  'Screens and sleep',
  'Rest days count',
  'Your next 12 weeks',
  'Handling setbacks',
  'Celebrating wins',
  'Keep growing',
];

const _images = [
  'assets/images/lesson-journaling.jpg',
  'assets/images/lesson-meal-planning.jpg',
  'assets/images/coach-video.jpg',
  'assets/images/hero-stretch.jpg',
];

final lessons = List<Lesson>.generate(totalWeeks, (i) {
  final week = i + 1;
  return Lesson(
    week: week,
    title: _weekTitles[i],
    summary: week == 7
        ? 'Busy weeks happen. This lesson shows you how to keep one small routine going when everything else slips.'
        : 'A short, practical lesson with one idea to try this week. Watch it in one go or in two-minute pieces.',
    minutes: 8 + (week * 5) % 9,
    image: week == 7 ? 'assets/images/lesson-journaling.jpg' : _images[i % _images.length],
    tasks: week == 7
        ? const ['Write your 3 non-negotiables', 'Set one phone reminder']
        : const ['Watch the lesson', 'Pick one idea to try'],
    resources: week == 7
        ? const [
            Resource('Week 7 workbook', 'PDF, 4 pages'),
            Resource('Easy protein swaps', 'PDF, 2 pages'),
          ]
        : [Resource('Week $week workbook', 'PDF, 3 pages')],
  );
});

const coachHabits = [
  Habit(
    id: 'water',
    title: 'Drink 2L of water',
    source: HabitSource.coach,
    category: HabitCategory.food,
    doneToday: true,
    week: [true, true, true, false, false, false, false],
  ),
  Habit(
    id: 'walk',
    title: '10 minute walk',
    source: HabitSource.coach,
    category: HabitCategory.movement,
    doneToday: true,
    week: [true, false, true, false, false, false, false],
  ),
  Habit(
    id: 'protein',
    title: 'Protein at breakfast',
    source: HabitSource.coach,
    category: HabitCategory.food,
    week: [true, true, false, false, false, false, false],
  ),
];

const myHabits = [
  Habit(
    id: 'lights',
    title: 'Lights out by 10:30',
    source: HabitSource.mine,
    category: HabitCategory.sleep,
    doneToday: true,
    week: [false, true, true, false, false, false, false],
  ),
  Habit(
    id: 'stretch',
    title: 'Stretch 5 minutes',
    source: HabitSource.mine,
    category: HabitCategory.calm,
    week: [true, false, false, false, false, false, false],
  ),
];

const habitLibrary = [
  LibraryHabit('veg', 'Eat a portion of veg with lunch', 'Food, once daily', HabitCategory.food),
  LibraryHabit('outside', 'Step outside before 10am', 'Movement, morning', HabitCategory.movement),
  LibraryHabit('phone', 'Phone out of the bedroom', 'Sleep, evening', HabitCategory.sleep),
  LibraryHabit('breathe', 'Two-minute breathing break', 'Calm, anytime', HabitCategory.calm),
  LibraryHabit('stairs', 'Take the stairs once', 'Movement, anytime', HabitCategory.movement),
  LibraryHabit('fruit', 'Fruit with breakfast', 'Food, morning', HabitCategory.food),
];

const seedActivity = [
  ActivityEntry('Walk', 32, ActivitySource.synced, note: 'Morning loop'),
  ActivityEntry('Strength session', 40, ActivitySource.manual, note: 'Lower body'),
];

/// What the simulated health-app sync adds (no real HealthKit / Health Connect).
const syncedFromHealth = [
  ActivityEntry('Yoga', 20, ActivitySource.synced, note: 'From health app'),
];

const blockCheckIn = [
  CheckInQuestion.choice('How has your energy been this block?', ['Very low', 'Low', 'Steady', 'Good', 'Great']),
  CheckInQuestion.text('What got in the way?', hint: 'A sentence is plenty'),
  CheckInQuestion.scale('Sleep quality'),
  CheckInQuestion.choice('Which habit felt easiest?', ['Water', 'Walking', 'Protein', 'Sleep']),
];

const onboardingForm = [
  CheckInQuestion.choice('What do you most want help with?', ['Energy', 'Food', 'Movement', 'Sleep']),
  CheckInQuestion.text('Anything your coach should know?', hint: 'Routines, work hours, sensory needs'),
  CheckInQuestion.scale('How confident do you feel today?'),
];

const coachClients = [
  CoachClient(
    id: 'maya',
    name: 'Maya Collins',
    tier: Tier.oneToOne,
    week: 7,
    avatar: 'assets/images/avatar-maya.jpg',
    flag: ClientFlag.checkInSubmitted,
    status: 'Check-in submitted',
    flowerProgress: 0.29,
  ),
  CoachClient(
    id: 'priya',
    name: 'Priya Shah',
    tier: Tier.group,
    week: 19,
    avatar: 'assets/images/avatar-priya.jpg',
    flag: ClientFlag.month5,
    status: 'Month 5, renews 2 Dec',
    renews: '2 Dec',
    flowerProgress: 0.74,
  ),
  CoachClient(
    id: 'hannah',
    name: 'Hannah Lee',
    tier: Tier.group,
    week: 4,
    avatar: 'assets/images/avatar-hannah.jpg',
    flag: ClientFlag.quiet,
    status: 'Quiet 9 days',
    daysQuiet: 9,
    flowerProgress: 0.12,
  ),
  CoachClient(
    id: 'zoe',
    name: 'Zoe Martin',
    tier: Tier.membership,
    week: 11,
    avatar: 'assets/images/avatar-zoe.jpg',
    flag: ClientFlag.checkInDue,
    status: 'Check-in due',
    flowerProgress: 0.45,
  ),
];

/// Notification wording the coach can edit from the content screen.
const defaultNotificationCopy = {
  'reminder': 'Small step time: your habits for today are ready.',
  'unlock': 'Week {week} is open. One lesson, one idea, no rush.',
  'checkin': 'Your block check-in is open. Five minutes, then you are done.',
};
