# Petal Path - Source Brief

## Title
Petal Path

## Description
Petal Path is a calm coaching app for women who want one simple place to act on their health and fitness goals. A 24-week programme opens week by week from the client's first login, with a short lesson, a couple of tasks and printable PDFs each week. Daily habits feed a six-petal flower, one petal per 4-week block, that only ever grows. Clients log activity by hand or sync it from their phone's health app, send a check-in at the end of each block, and get gentle reminders. A coach view shows every client's progress and flags quiet clients and upcoming renewals, and lets the coach keep or remove access and edit the reminder wording.

## Store links
Not yet published. This is a proof of concept.

## Platform
Android demo, iOS-ready codebase (Flutter).

## Category
Health and Fitness, coaching and habit tracking.

## Features
- Three plans: group programme (weekly drip), 1:1 coaching (group content plus a personal plan) and a rolling membership with everything open from day 1
- Date-based unlocks: 24 weeks in six 4-week blocks, counted from the first login
- Home dashboard: this week, today's habits, new unlocks and the open check-in
- Weekly lesson video, tasks and a PDF resource library
- Habit tracker with a coach habit library and client-created habits
- Six-petal progress flower that fills as habits are done and never goes backwards
- Block check-in form and a 1:1 onboarding form
- Activity log by hand plus a simulated health-app sync; body and food tracking with nutrition targets for 1:1 clients
- Notification preview for reminders, unlocks and check-ins, with reminder toggles
- Coach view: client roster with progress, check-in status, renewal dates, quiet-client and month-5 flags, retain or revoke access, and editable notification wording
- Calm, low-clutter design: big buttons and one main action per screen

## Tech stack
- Flutter 3.35 (Dart 3.9), Material 3
- Riverpod 3 (Notifier providers) for state
- Bundled Barlow Condensed and Oswald fonts
- flutter_test widget tests, integration_test + flutter_driver for on-device screenshots
- GitHub Actions Android emulator for screenshot and demo capture
- Design made first in Google Stitch (source screens in `design/`)

## Industry
Health and wellness coaching.

## Metrics
Unpublished POC: no users, downloads or ratings. 16 automated tests (3 unit tests for the unlock rules, 13 widget tests) pass on every change.

## Research notes
- Verified: the unlock rules (week, block, next unlock date, membership open from day 1), the flower never shrinking when a habit is unticked, and every screen rendering without layout overflow on a 393x852 phone, all by automated tests.
- Mocked: all people, lessons, PDFs, activity numbers and clients are sample data; there is no backend, sign-in is a demo account per plan.
- Simulated: the health sync makes no Apple Health or Health Connect call; push notifications are shown as an in-app preview, not sent.
- Assumed: a production version would add a backend for accounts, content and the coach dashboard, real video hosting, payments, and health-data handling under the applicable data-protection rules.
