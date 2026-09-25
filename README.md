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

## Structure

```
lib/
├── app.dart                 # MaterialApp.router, themes
├── main.dart                # Firebase + SharedPreferences bootstrap
├── core/
│   ├── constants/
│   ├── errors/              # Failure type repositories throw
│   ├── routing/             # GoRouter, redirect rules, bottom-nav shell
│   ├── storage/             # SharedPreferences provider + keys
│   ├── theme/               # AppTheme, AppColors, StatusColors, ThemeModeController
│   ├── utils/
│   └── widgets/             # StatusBadge, EmptyState, LoadingView, ErrorView
└── features/<feature>/{data,domain,presentation}
```

## Progress

- [x] Phase 1 — project setup, architecture, theming (light/dark/system), routing, onboarding
- [ ] Phase 2 — authentication (email/password, Google, forgot password)
- [ ] Phase 3 — pet management
- [ ] Phase 4 — vaccinations
- [ ] Phase 5+ — appointments, medications, dashboard, notifications, …

## Tests

```bash
flutter test
```
