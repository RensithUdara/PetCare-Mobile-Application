# 🐾 PetCare

A Flutter app for tracking pet vaccinations, vet appointments, medications and medical records.

**Stack:** Flutter · Riverpod 3 · GoRouter · Firebase (Auth, Firestore, Storage, FCM, Functions) · Dio · flutter_map · fl_chart · Material 3

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

Documents live at `users/{uid}/documents/{id}` (keyed by `petId`, optional `vaccinationId` for
certificates) with files at `users/{uid}/pets/{petId}/documents/{id}/{fileName}` in Storage
(images or PDFs, max 10 MB — enforced in the `AddDocument` use case and `storage.rules`).
If writing the record fails after upload, the file is deleted again.

Deleting a pet deletes its vaccinations, appointments, medications and documents (records + files).

Weigh-ins live at `users/{uid}/weights/{id}` (keyed by `petId`). The weight history is the source
of truth: `Pet.weightKg` is a denormalised copy of the latest entry, kept in sync by the
`SyncPetCurrentWeight` use case; changing the weight in the pet form logs a weigh-in.

Clinics live at `users/{uid}/clinics/{id}` (with optional `latitude`/`longitude`) and
veterinarians at `users/{uid}/veterinarians/{id}` (optional `clinicId`). Deleting a clinic keeps
its vets but unlinks them.

### Maps & nearby clinics

- Maps use **flutter_map + OpenStreetMap tiles** — no API key or billing needed. Please respect the
  [OSM tile usage policy](https://operations.osmfoundation.org/policies/tiles/) (the app sends a
  `User-Agent`; for a production release consider a commercial tile provider).
- **Find vets near me** queries the public Overpass API over **Dio** (`core/network/dio_client.dart`)
  for `amenity=veterinary` within 5 km. Results can be saved to your clinics.
- **Directions** open Google Maps / Apple Maps via a URL (no key).
- Saved clinic and vet names autocomplete in appointment, vaccination and medication forms.

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

## QR Pet ID & emergency profile

- Private settings: `users/{uid}/emergencyProfiles/{petId}` (what to share, contact, warnings).
- Public snapshot: `publicProfiles/{publicId}` — **world-readable, owner-writable** (see
  `firestore.rules`). It is built by the pure `buildPublicProfile()` and contains *only* the fields
  the owner opted into; it is republished when the pet's details change and deleted with the pet.
- IDs look like `PC-8A72F9K` (no 0/O/1/I/L) and never change, so printed tags keep working;
  turning the profile off just withdraws the page.
- QR codes encode `https://<projectId>.web.app/p/<publicId>`:
  - **Without the app:** Firebase Hosting serves `public/p.html`, which reads the snapshot through
    the Firestore REST API (no login, no SDK; values rendered with `textContent`).
  - **With the app (Android):** an `autoVerify` App Link opens the in-app `/p/:publicId` screen,
    which is reachable without signing in (see `redirect.dart`).

### Setup

1. `firebase deploy --only hosting,firestore:rules`
2. **Android App Links:** put your signing certificate's SHA-256 (`cd android && ./gradlew signingReport`,
   plus the Play App Signing key for releases) into `public/.well-known/assetlinks.json` and redeploy.
3. **iOS Universal Links:** replace `REPLACE_WITH_TEAM_ID` in
   `public/.well-known/apple-app-site-association`, and add the *Associated Domains* capability
   `applinks:<projectId>.web.app` in Xcode.

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
- [x] Phase 9 — medical documents (upload photo/PDF, viewer, type filter, vaccination certificates)
- [x] Phase 10a — clinics & veterinarians, maps, nearby search (REST/Dio), directions
- [x] Phase 10b — weight tracking (log, fl_chart trend, ranges, history, pet profile sync)
- [x] Phase 10c — QR pet ID, emergency profile (public web page + App Links), deep links
- [ ] Phase 10d — offline mode & sync status

## Tests

```bash
flutter test
```

`test/` mirrors `lib/` (`domain` → use case & logic tests, `data` → model mapping,
`presentation` → controllers & widgets). Fakes for repositories live in `test/helpers/`.
