# 🐾 PetCare

A Flutter app for tracking pet vaccinations, vet appointments, medications and medical records.

**Stack:** Flutter · Riverpod 3 · GoRouter · Firebase (Auth, Firestore) · Material 3

## Getting started

```bash
flutter pub get
dart pub global activate flutterfire_cli
flutterfire configure      # generates lib/firebase_options.dart + native config
flutter run
```

Until `flutterfire configure` runs, the app shows a "Firebase is not configured" screen.

### Firebase console setup

1. **Authentication → Sign-in method:** enable *Email/Password* and *Google*.
2. **Firestore Database & Storage:** create both, then deploy the rules in `firestore.rules` and
   `storage.rules` (`firebase init firestore storage` → keep the existing files →
   `firebase deploy --only firestore:rules,storage`).
3. **Google Sign-In on Android:** add your debug SHA-1 to the Android app in Project settings
   (`cd android && ./gradlew signingReport`), then re-run `flutterfire configure`.
4. **Google Sign-In on iOS:** add the `REVERSED_CLIENT_ID` from `ios/Runner/GoogleService-Info.plist`
   as a URL scheme in `ios/Runner/Info.plist` (`CFBundleURLTypes`).

### Data model

Registration creates `users/{uid}` with `fullName`, `email`, `phone`, `photoUrl`, `createdAt`.
Pets live at `users/{uid}/pets/{petId}`; their photos at `users/{uid}/pets/{petId}/photo_<ms>.jpg`
in Storage (downscaled to 1080px, JPEG quality 80 before upload).

Vaccinations live at `users/{uid}/vaccinations/{id}` with a `petId` field (so dashboard and calendar
can query across pets). Each record stores `reminderDaysBefore` plus a denormalized `reminderAt`
timestamp for the upcoming Cloud Functions reminder job.

Appointments live at `users/{uid}/appointments/{id}` (also keyed by `petId`) with `dateTime`,
`type`, `status` (`scheduled` / `completed` / `cancelled`) and the same `reminderAt` field
(cleared once an appointment is no longer scheduled).

Medications live at `users/{uid}/medications/{id}` with `frequency`, `startDate`, optional
`endDate` (inclusive; `null` = ongoing), `doseTimes` as `"HH:mm"` strings and `remindersEnabled`.
Individual doses are **not** stored — they are computed from the schedule
(`medications/domain/logic/medication_schedule.dart`), and the calendar expands them lazily per day.

Deleting a pet deletes its vaccinations, appointments and medications.

## Reminders & notifications

- **Local notifications (primary).** `features/notifications/domain/logic/reminder_planner.dart`
  turns records into the reminders that should be pending on this device — vaccination due dates,
  appointments and medication doses (next 3 days), capped at 60 (iOS allows 64). A
  `ReminderSyncController` re-plans and replaces the device schedule whenever data or settings
  change. Works offline and needs no paid Firebase plan. Android uses inexact alarms, so a
  reminder may arrive a few minutes late while the phone is idle.
- **Push fallback (optional).** Each device registers `users/{uid}/devices/{fcmToken}` with
  `lastSyncedAt`. The Cloud Function `sendDueReminders` (`functions/`, every 15 min) pushes
  vaccination/appointment reminders **only** to users with no device synced in the last 7 days,
  so active devices never get duplicates. Medication doses are local-only.
- Tapping a notification opens the record in the Home tab (also from a cold start).
- Settings: Profile → Notifications (master switch, per-category switches, test notification).

### Setup for push (optional)

1. **iOS:** enable *Push Notifications* and *Background Modes → Remote notifications* in Xcode, and
   upload an APNs key in Firebase console → Project settings → Cloud Messaging.
2. **Functions** (requires the Blaze plan):
   `cd functions && npm install && cd .. && firebase deploy --only functions,firestore:indexes`
   (the collection-group indexes on `reminderAt` live in `firestore.indexes.json`).

## Code generation

Models use Freezed + json_serializable. After changing a model:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

## Architecture

Clean Architecture, organised by feature. Dependencies point inwards only:

```text
presentation ──▶ domain ◀── data
 (widgets,        (entities,    (models/DTOs,
  controllers,     repository    data sources,
  providers)       interfaces,   repository
                   use cases)    implementations)
```

```
lib/
├── app.dart / main.dart
├── core/                      # cross-cutting, feature-agnostic
│   ├── domain/                # shared pure-Dart types (ReminderOffset)
│   ├── errors/                # Failure + Firebase error mapping
│   ├── routing/               # GoRouter, redirect rules, bottom-nav shell
│   ├── storage/               # SharedPreferences, Firestore JSON helpers
│   ├── theme/                 # AppTheme, StatusColors, ThemeModeController
│   ├── utils/                 # validators, date utils, clock
│   └── widgets/               # StatusBadge, EmptyState, DateField, …
└── features/<feature>/
    ├── domain/
    │   ├── entities/          # Freezed, no JSON, no Flutter
    │   ├── repositories/      # abstract interfaces
    │   ├── usecases/          # one class per action, exposes call()
    │   └── logic/             # pure business rules (e.g. vaccination status)
    ├── data/
    │   ├── models/            # json_serializable DTOs with toEntity()/fromEntity()
    │   ├── datasources/       # raw Firebase calls; throw SDK exceptions
    │   └── repositories/      # implement domain interfaces; map errors → Failure
    └── presentation/
        ├── providers/         # Riverpod DI wiring (data → use cases → state)
        ├── controllers/       # Notifiers holding UI state; call use cases only
        ├── screens/
        └── widgets/
```

**Rules** (enforced by `test/architecture_test.dart`):

- `domain` is pure Dart: no Flutter, Firebase or Riverpod; from `core` it may only use
  `core/domain`, `core/errors/failure.dart` and `core/utils/date_utils.dart`.
- `data` never imports `presentation`.
- A feature never imports another feature's `data` layer — go through its domain interfaces
  (e.g. `VaccinationRepository` implements the pets domain's `PetRecordsCleaner`).
- Presentation talks to the domain **only through use cases**, never repositories directly.
- Repositories throw `Failure` (user-presentable message); SDK exceptions never leave `data`.
- Time-dependent logic takes a clock (`clockProvider`) so it is testable.
- Features that aggregate others (**calendar**, **home dashboard**) depend on their *domain* repositories and
  logic, combining streams with the pure `combineLatest` helper.

### Navigation

- Tabs (`/home`, `/pets`, `/calendar`, …) keep their own stacks; details pages live inside the
  tab that opened them (`/pets/:petId/appointments/:id`, `/calendar/appointment/:id`).
- All forms are full-screen top-level routes under `/edit/...` so any tab can open them.
- `test/core/app_router_test.dart` checks that every `AppRoutes` path resolves.

## Progress

- [x] Phase 1 — project setup, architecture, theming (light/dark/system), routing, onboarding
- [x] Phase 2 — authentication (email/password, Google, forgot password, logout)
- [x] Phase 3 — pet management (CRUD, photos, multiple pets)
- [x] Phase 4 — vaccinations (records, status, reminders config, history timeline)
- [x] Phase 5 — appointments (schedule, complete, cancel, history) and calendar
- [x] Phase 6 — medications (dosage, frequency, course dates, dose times, stop) + calendar doses
- [x] Phase 7 — home dashboard (alerts, pet summaries, today's doses, upcoming, recent activity)
- [x] Phase 8 — notifications (local reminders, FCM, settings, Cloud Functions fallback)
- [ ] Phase 9+ — medical documents, …

## Tests

```bash
flutter test
```

`test/` mirrors `lib/` (`domain` → use case & logic tests, `data` → model mapping,
`presentation` → controllers & widgets). Fakes for repositories live in `test/helpers/`.
