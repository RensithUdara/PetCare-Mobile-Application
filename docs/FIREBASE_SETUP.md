# Firebase Setup

PetCare uses Firebase for authentication, data storage, file storage, cloud messaging, cloud functions, hosting, and local emulators.

## Firebase Services

Enable these services in Firebase Console:

- Authentication.
- Cloud Firestore.
- Cloud Storage.
- Cloud Messaging.
- Cloud Functions.
- Firebase Hosting.

## Required Config Files

The app expects these files:

```text
lib/firebase_options.dart
android/app/google-services.json
ios/Runner/GoogleService-Info.plist
```

If you create a new Firebase project, regenerate the FlutterFire configuration:

```bash
firebase login
dart pub global activate flutterfire_cli
flutterfire configure
```

## Firebase Project Files

| File | Purpose |
| --- | --- |
| `firebase.json` | Firebase hosting, functions, rules, and emulator configuration |
| `.firebaserc` | Firebase project alias |
| `firestore.rules` | Firestore security rules |
| `firestore.indexes.json` | Firestore indexes |
| `storage.rules` | Storage security rules |
| `functions/` | Cloud Functions source |
| `public/` | Firebase Hosting static public files |

## Authentication

Enable the sign-in methods used by the app:

- Email/password.
- Google Sign-In if production Google login is enabled.

For Google Sign-In, make sure Android SHA fingerprints are configured in Firebase:

- Debug SHA-1/SHA-256 for development.
- Upload/release SHA-1/SHA-256 for production.

## Firestore

Deploy rules and indexes:

```bash
firebase deploy --only firestore:rules,firestore:indexes
```

Run rules tests:

```bash
cd web
npm run test:rules
```

## Storage

Deploy storage rules:

```bash
firebase deploy --only storage
```

Storage is used for pet photos, profile photos, and medical documents.

## Cloud Functions

Install dependencies:

```bash
cd functions
npm ci
```

Build:

```bash
npm run build
```

Test:

```bash
npm test
```

Deploy:

```bash
firebase deploy --only functions
```

Important functions include:

- `sendDueReminders`
- `bootstrapAdmin`
- `adminStats`
- `listUsers`
- `reviewDoctor`
- `setUserDisabled`
- `setUserRole`

## Hosting

Firebase Hosting serves:

- Public static files.
- Public emergency profiles.
- Web portal under `/app` when using Firebase Hosting.

The React portal can also be hosted separately on Vercel as `pet-care-web`.
See [Vercel Deployment](VERCEL_DEPLOYMENT.md).

Deploy hosting:

```bash
firebase deploy --only hosting
```

## Emulators

Start configured emulators:

```bash
firebase emulators:start
```

Configured ports:

| Service | Port |
| --- | ---: |
| Auth | `9099` |
| Firestore | `8085` |
| Functions | `5001` |
| Storage | `9199` |
| Hosting | `5005` |
| Emulator UI | `4005` |

Web emulator workflow:

```bash
cd web
npm run emulators
```

Seed local demo data:

```bash
cd web
npm run seed
```

## Production Checklist

- [ ] Firebase project is production project.
- [ ] Android package name is correct.
- [ ] SHA fingerprints are configured.
- [ ] Firestore rules deployed.
- [ ] Storage rules deployed.
- [ ] Firestore indexes deployed.
- [ ] Functions deployed.
- [ ] Hosting deployed.
- [ ] App Links files are present and valid.
- [ ] Test users can sign in.
- [ ] Push notifications work on a physical Android device.
