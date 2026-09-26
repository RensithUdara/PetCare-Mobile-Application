# Contributing

Thanks for improving PetCare. Keep changes focused, tested, and easy to review.

## Development Setup

Install Flutter dependencies:

```bash
flutter pub get
```

Install web dependencies:

```bash
cd web
npm ci
```

Install functions dependencies:

```bash
cd functions
npm ci
```

## Branch Naming

Use short, clear branch names:

```text
feature/pet-documents
fix/notification-reminders
docs/play-store-guide
```

## Code Style

- Follow the existing feature-first structure.
- Keep presentation, domain, and data layers separate.
- Prefer existing widgets, providers, and repository patterns.
- Add tests for business logic, controllers, and user-facing flows.
- Keep unrelated refactors out of feature changes.

## Code Generation

Run code generation after changing Freezed or JSON model files:

```bash
dart run build_runner build --delete-conflicting-outputs
```

## Checks Before Pull Request

```bash
flutter analyze
flutter test
```

For web changes:

```bash
cd web
npm test
npm run build
```

For Firebase rules:

```bash
cd web
npm run test:rules
```

For functions:

```bash
cd functions
npm test
```

## Pull Request Checklist

- [ ] The change has a clear purpose.
- [ ] Tests were added or updated when needed.
- [ ] Generated files are updated when models changed.
- [ ] Firebase rules or indexes are updated when data access changed.
- [ ] Screenshots are included for UI changes.
- [ ] Play Store or privacy docs are updated if data collection changed.
