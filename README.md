<div align="center">
  <img src="assets/images/app_logo.png" alt="PetCare logo" width="150" />

  # 🐾 PetCare

  **A complete pet health companion for owners, veterinarians, and administrators.**

  PetCare helps pet owners manage profiles, appointments, vaccinations, medications,
  medical documents, weight tracking, emergency QR profiles, reminders, and clinic
  information from one modern Flutter app, with a Firebase-powered web portal for
  owners, doctors, and admins.

  ![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)
  ![Dart](https://img.shields.io/badge/Dart-3.9+-0175C2?logo=dart&logoColor=white)
  ![Firebase](https://img.shields.io/badge/Firebase-Auth%20%7C%20Firestore%20%7C%20Storage%20%7C%20Functions-FFCA28?logo=firebase&logoColor=black)
  ![React](https://img.shields.io/badge/Web-React%20%2B%20Vite-61DAFB?logo=react&logoColor=black)
</div>

---

## ✨ Highlights

- 🐶 **Pet profiles** - store pet details, photos, age, records, and care history.
- 📅 **Appointments** - create, update, track, and review veterinary appointments.
- 💉 **Vaccinations** - record vaccines, due dates, statuses, and attached documents.
- 💊 **Medications** - manage active medication schedules and dose timing.
- ⚖️ **Weight tracking** - monitor pet weight history and trends.
- 📄 **Medical documents** - upload, view, and organize pet documents, including PDFs.
- 🚨 **Emergency QR profile** - share public emergency information through `/p/{publicId}` links.
- 🔔 **Smart reminders** - local reminders on devices with server push fallback.
- 🏥 **Clinics and vets** - manage nearby clinics, vets, maps, and clinic details.
- 🤝 **Pet sharing** - securely share pet access with doctors using doctor codes.
- 👤 **User profile** - edit profile, password, notification settings, FAQ, and account options.
- 🌐 **Web portal** - separate owner, doctor, and admin dashboards built with React + Vite.
- 🛡️ **Firebase security rules** - tested Firestore rules for access control and emergency profiles.

---

## 🧩 Project Structure

```text
PetCare/
├── android/                 # Android native project
├── ios/                     # iOS native project
├── assets/                  # Flutter app logos, icons, onboarding images
├── lib/                     # Flutter application source
│   ├── app.dart             # App bootstrap
│   ├── main.dart            # Flutter entrypoint
│   ├── core/                # Routing, theme, widgets, networking, utilities
│   └── features/            # Feature-first modules
├── test/                    # Flutter unit, widget, feature, and domain tests
├── web/                     # React + TypeScript + Vite web portal
│   ├── src/
│   ├── tests/
│   └── package.json
├── functions/               # Firebase Cloud Functions
├── public/                  # Firebase Hosting static files and public profile pages
├── firestore.rules          # Firestore security rules
├── firestore.indexes.json   # Firestore indexes
├── storage.rules            # Firebase Storage security rules
├── firebase.json            # Firebase hosting, functions, emulator config
└── pubspec.yaml             # Flutter dependencies and assets
```

---

## 📚 Project Documents

| Document | Purpose |
| --- | --- |
| [Play Store Release Guide](docs/PLAY_STORE_RELEASE.md) | Full Google Play publishing checklist and store listing draft |
| [Vercel Deployment](docs/VERCEL_DEPLOYMENT.md) | Deploy the React web portal as `pet-care-web` on Vercel |
| [Privacy Policy Draft](docs/PRIVACY_POLICY.md) | Draft privacy policy to review before publishing |
| [Testing Checklist](docs/TESTING_CHECKLIST.md) | Manual and automated testing checklist |
| [Firebase Setup](docs/FIREBASE_SETUP.md) | Firebase services, emulators, deployment, and production setup |
| [Release Checklist](docs/RELEASE_CHECKLIST.md) | Repeatable checklist for each app release |
| [Security](docs/SECURITY.md) | Security notes, sensitive data, and reporting guidance |
| [Contributing](docs/CONTRIBUTING.md) | Development workflow and PR checklist |
| [Changelog](docs/CHANGELOG.md) | Version history and release notes |

---

## 🏗️ Architecture

PetCare follows a **feature-first clean architecture** style:

- **Presentation** - screens, widgets, controllers, providers.
- **Domain** - entities, repositories, use cases, business logic.
- **Data** - Firebase data sources, models, repository implementations.
- **Core** - app-wide routing, theme, validation, shared widgets, networking, and utilities.

State management is handled with **Riverpod**, navigation with **GoRouter**, and backend
data with **Firebase Auth, Cloud Firestore, Cloud Storage, Cloud Messaging, and Functions**.

---

## 🛠️ Tech Stack

| Layer | Tools |
| --- | --- |
| Mobile app | Flutter, Dart, Material, Riverpod, GoRouter |
| Backend | Firebase Auth, Firestore, Storage, Cloud Messaging, Cloud Functions |
| Web portal | React, TypeScript, Vite, Tailwind CSS, Recharts, Lucide React |
| Maps/location | Flutter Map, LatLng, Geolocator, Overpass API |
| Files/documents | File Picker, PDFX, Firebase Storage, cache manager |
| Testing | Flutter Test, Mocktail, Vitest, Firebase Rules Unit Testing, Node test |

---

## 🚀 Getting Started

### ✅ Prerequisites

Install these tools before running the project:

- Flutter SDK with Dart `^3.9.0`
- Android Studio or Xcode for mobile builds
- Node.js `22` for Firebase Functions
- Firebase CLI
- A Firebase project with Auth, Firestore, Storage, Messaging, Functions, and Hosting enabled

Check Flutter setup:

```bash
flutter doctor
```

Install Firebase CLI if needed:

```bash
npm install -g firebase-tools
```

---

## 📦 Install Dependencies

### Flutter app

```bash
flutter pub get
```

### Web portal

```bash
cd web
npm ci
cd ..
```

### Cloud Functions

```bash
cd functions
npm ci
cd ..
```

---

## 🔥 Firebase Setup

This repository is already configured for the Firebase project shown in `firebase.json`.
For a different Firebase project, configure FlutterFire again:

```bash
firebase login
dart pub global activate flutterfire_cli
flutterfire configure
```

Required Firebase files:

- `lib/firebase_options.dart`
- `android/app/google-services.json`
- `ios/Runner/GoogleService-Info.plist`

Firebase services used:

- 🔐 Authentication
- 🗃️ Cloud Firestore
- 🗂️ Cloud Storage
- 🔔 Firebase Cloud Messaging
- ⚙️ Cloud Functions
- 🌍 Firebase Hosting

---

## ▶️ Run The Flutter App

### Android

```bash
flutter run -d android
```

### iOS

```bash
flutter run -d ios
```

### Web/debug target

```bash
flutter run -d chrome
```

---

## 🌐 Run The Web Portal

The web portal lives in `web/` and supports owner, doctor, and admin dashboards.
It can be deployed to Vercel as `pet-care-web`, while Firebase continues to provide
authentication, Firestore, Functions, Storage, and public emergency profile hosting.

```bash
cd web
npm run dev
```

For local emulator mode:

```bash
cd web
npm run dev:local
```

Local demo accounts are available only when the portal is running against Firebase emulators:

| Role | Email | Password |
| --- | --- | --- |
| Pet owner | `owner@petcare.test` | `demo1234` |
| Veterinarian | `vet@petcare.test` | `demo1234` |
| Pending vet | `pending.vet@petcare.test` | `demo1234` |
| Admin | `admin@petcare.test` | Emulator Google sign-in |

Seed emulator data:

```bash
cd web
npm run seed
```

---

## 🧪 Testing

### Flutter tests

```bash
flutter test
```

### Web tests

```bash
cd web
npm test
```

### Firestore rules tests

```bash
cd web
npm run test:rules
```

### Web emulator integration tests

```bash
cd web
npm run test:e2e
```

### Cloud Functions tests

```bash
cd functions
npm test
```

---

## 🧬 Code Generation

The app uses `freezed`, `json_serializable`, and generated model files.
After changing entities or models, run:

```bash
dart run build_runner build --delete-conflicting-outputs
```

---

## 🧯 Local Firebase Emulators

Start Auth, Firestore, Functions, Storage, Hosting, and Emulator UI:

```bash
firebase emulators:start
```

Or start the web-focused emulator stack:

```bash
cd web
npm run emulators
```

Configured emulator ports:

| Service | Port |
| --- | ---: |
| Auth | `9099` |
| Firestore | `8085` |
| Functions | `5001` |
| Storage | `9199` |
| Hosting | `5005` |
| Emulator UI | `4005` |

---

## 📱 Main Mobile Features

### 🏠 Home Dashboard

The home screen summarizes upcoming appointments, vaccinations, medications, and alerts
so pet owners can see what needs attention quickly.

### 🐕 Pets

Owners can create and manage pet profiles with photos, basic information, medical history,
linked appointments, medications, vaccinations, documents, and emergency settings.

### 💉 Vaccinations

Vaccination records include vaccine names, due dates, status tracking, reminders, and
document attachment support.

### 💊 Medications

Medication schedules support active treatment tracking, dose timing, and reminders handled
locally on the user device.

### 📅 Calendar

The calendar combines appointment, vaccination, and medication events into one care timeline.

### 🚨 Emergency Profile

Emergency profiles expose selected public information through a QR/app-link style route:

```text
/p/{publicId}
```

This allows critical pet information to be accessed without signing in.

### 🏥 Clinics

Clinic features include clinic records, vets, map support, nearby search, and clinic details.

### 🤝 Sharing With Doctors

Owners can share pet access with veterinarians using secure doctor codes. Doctors can review
shared patient information from the web portal.

---

## 🖥️ Web Portal Features

### 👤 Owner Portal

- Owner dashboard
- Pet list and pet details
- Owner profile management

### 🩺 Doctor Portal

- Doctor dashboard
- Shared patient list
- Patient detail view
- Doctor profile
- Pending approval flow

### 🛡️ Admin Portal

- Admin dashboard
- User management
- Doctor review and approval
- Role management
- Account enable/disable tools

---

## 🔔 Reminder System

PetCare uses a hybrid reminder strategy:

- 📱 **Local notifications** schedule reminders directly on active devices.
- ☁️ **Cloud Functions fallback** sends push notifications when no device has synced recently.
- 💊 **Medication reminders** stay local because they can be frequent and time-sensitive.
- 💉 **Vaccination and appointment reminders** can use server fallback.

The scheduled Cloud Function runs every 15 minutes:

```text
sendDueReminders
```

---

## 🚢 Build And Deploy

### Build Flutter Android APK

```bash
flutter build apk --release
```

### Build Flutter Android App Bundle

```bash
flutter build appbundle --release
```

### Build iOS

```bash
flutter build ios --release
```

### Build web portal

```bash
cd web
npm run build
```

### Build Cloud Functions

```bash
cd functions
npm run build
```

### Deploy Firebase

```bash
firebase deploy
```

Deploy only selected Firebase resources:

```bash
firebase deploy --only firestore:rules,firestore:indexes,storage
firebase deploy --only functions
firebase deploy --only hosting
```

---

## 🔐 Security Notes

- Firestore access is controlled by `firestore.rules`.
- Storage access is controlled by `storage.rules`.
- Public emergency profiles are intentionally available through public profile routes.
- Doctor access is granted through owner sharing and role checks.
- Admin actions are handled by Cloud Functions and role-based authorization.
- Local demo accounts are restricted to emulator development.

---

## 🎨 Assets

Important app assets:

| Asset | Purpose |
| --- | --- |
| `assets/images/app_logo.png` | README/logo branding |
| `assets/images/app_icon.png` | App icon |
| `assets/images/app_logo_splash.png` | Splash screen logo |
| `assets/images/splash_logo.png` | Native splash image |
| `assets/onboard/clean/` | Onboarding illustrations |
| `web/src/assets/logo.png` | Web portal logo |

Regenerate native splash assets after changing splash images:

```bash
dart run flutter_native_splash:create
```

---

## 🤝 Contributing

1. Create a focused branch.
2. Run code generation if models/entities changed.
3. Run Flutter, web, rules, and function tests relevant to your change.
4. Keep Firebase rules and indexes in sync with data model updates.
5. Open a pull request with screenshots or screen recordings for UI changes.

Recommended checks before merging:

```bash
flutter analyze
flutter test
cd web && npm test && npm run test:rules
cd ../functions && npm test
```

---

## 📄 License

This project is private by default. Add a license file if you plan to publish or open-source it.

---

<div align="center">
  Made with care for healthier, happier pets. 🐾
</div>
