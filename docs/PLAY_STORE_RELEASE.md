# Google Play Store Release Guide

This guide explains how to prepare and publish PetCare on Google Play.

## Current App Details

| Item | Value |
| --- | --- |
| App name | PetCare |
| Android package | `com.rensithudara.petcare` |
| First public version | `1.0.0+1` |
| Build artifact | Android App Bundle (`.aab`) |
| Backend | Firebase |
| App category suggestion | Lifestyle |

## Before Publishing

- Replace debug release signing with a real upload key.
- Confirm the app targets the current Google Play target SDK requirement.
- Change Android app label to `PetCare` if it still appears as lowercase `petcare`.
- Test account creation, login, password reset, profile editing, and account deletion.
- Test pet, appointment, vaccination, medication, document, emergency, clinic, and sharing flows.
- Test notification permission, reminders, and location permission on a real Android device.
- Prepare a public privacy policy URL.
- Prepare Play Store screenshots and feature graphic.

## Release Signing

Generate an upload key:

```bash
keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

Create `android/key.properties`:

```properties
storePassword=YOUR_STORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=upload
storeFile=../upload-keystore.jks
```

Do not commit keystores or passwords. Keep a secure backup of the upload key.

Recommended `.gitignore` entries:

```text
android/key.properties
android/upload-keystore.jks
*.jks
*.keystore
```

## Versioning

Current version in `pubspec.yaml`:

```yaml
version: 1.0.0+1
```

For each update, increase the build number after `+`:

```yaml
version: 1.0.1+2
```

## Build Commands

```bash
flutter clean
flutter pub get
flutter analyze
flutter test
flutter build appbundle --release
```

Upload this file in Play Console:

```text
build/app/outputs/bundle/release/app-release.aab
```

## Play Console Setup

1. Create a Google Play developer account.
2. Create a new app named `PetCare`.
3. Select app type: App.
4. Select pricing: Free.
5. Complete app setup tasks.
6. Add store listing details.
7. Upload graphics and screenshots.
8. Add privacy policy URL.
9. Complete App content forms.
10. Create an internal testing release.
11. Upload the `.aab`.
12. Fix all Play Console warnings.
13. Run closed testing if required.
14. Submit production release for review.

## Store Listing Draft

Short description:

```text
Manage pet health, appointments, vaccines, medications, and records.
```

Full description:

```text
PetCare is a complete pet health management app designed to help pet owners keep every important care detail in one place.

With PetCare, you can create pet profiles, track vaccinations, schedule veterinary appointments, manage medications, store medical documents, monitor weight history, and prepare emergency information that can be accessed through a public QR profile.

Key features:

- Create and manage pet profiles
- Track vaccination records and due dates
- Schedule veterinary appointments
- Manage medications and dose schedules
- Store medical documents and PDF records
- Monitor pet weight history
- Create emergency profiles for quick access
- Find and manage clinics and vets
- Share pet access securely with veterinarians
- Receive local reminders and important care alerts

Whether you care for one pet or many, PetCare helps you stay organized and prepared.
```

## Store Assets

Required:

- App icon: 512 x 512 PNG.
- Feature graphic: 1024 x 500 PNG or JPG.
- Phone screenshots: at least 2, recommended 6 to 8.
- Privacy policy URL.

Recommended screenshots:

1. Login or onboarding.
2. Home dashboard.
3. Pet profile.
4. Vaccination tracking.
5. Appointment tracking.
6. Medication schedule.
7. Emergency profile.
8. Documents or clinics.

## App Content Answers

Expected answers for this app:

| Play Console section | Suggested answer |
| --- | --- |
| Ads | No, unless ads are added later |
| App access | Provide demo credentials if reviewer cannot access protected content |
| Target audience | Adults or 13+, depending on business decision |
| Content rating | Complete honestly as a pet care/productivity app |
| News app | No |
| COVID-19 contact tracing/status | No |
| Government app | No |
| Financial features | No |

## Data Safety Summary

PetCare may collect:

- Name.
- Email address.
- User ID.
- Pet profile details.
- Pet photos.
- Medical records and uploaded files.
- Vaccination, appointment, medication, and weight records.
- Location when finding nearby clinics.
- Device notification token.

Purposes:

- App functionality.
- Account management.
- Notifications and reminders.
- Secure doctor sharing.
- Emergency profile access.

## Closed Testing

Some new personal developer accounts must complete closed testing before production access:

- Minimum 12 opted-in testers.
- Testers remain opted in continuously for at least 14 days.
- Apply for production access after the requirement is met.

## Final Upload Checklist

- [ ] Release signing configured.
- [ ] Version code increased.
- [ ] Target SDK meets Play requirement.
- [ ] Firebase config matches package name.
- [ ] Privacy policy published.
- [ ] Store listing completed.
- [ ] Screenshots uploaded.
- [ ] Feature graphic uploaded.
- [ ] App content forms completed.
- [ ] Internal test uploaded.
- [ ] Closed test completed if required.
- [ ] Production release submitted.
