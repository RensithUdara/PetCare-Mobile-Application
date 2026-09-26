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

## Code generation

Models use Freezed + json_serializable. After changing a model:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

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
- [x] Phase 2 — authentication (email/password, Google, forgot password, logout)
- [x] Phase 3 — pet management (CRUD, photos, multiple pets)
- [ ] Phase 4 — vaccinations
- [ ] Phase 5+ — appointments, medications, dashboard, notifications, …

## Tests

```bash
flutter test
```
