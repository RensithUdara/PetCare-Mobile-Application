# Testing Checklist

Use this checklist before uploading a release to Google Play.

## Environment

- [ ] `flutter doctor` has no blocking issues.
- [ ] Firebase config files are present.
- [ ] Android package matches Firebase project configuration.
- [ ] Emulator test data works.
- [ ] Release build installs on a real Android device.

## Commands

```bash
flutter clean
flutter pub get
flutter analyze
flutter test
flutter build appbundle --release
```

Web portal:

```bash
cd web
npm ci
npm test
npm run test:rules
npm run build
```

Cloud Functions:

```bash
cd functions
npm ci
npm test
```

## Authentication

- [ ] Splash screen opens correctly.
- [ ] Onboarding works for a new install.
- [ ] Email registration works.
- [ ] Email login works.
- [ ] Google sign-in works if enabled for production.
- [ ] Password reset email sends.
- [ ] Logout works.
- [ ] Auth redirect rules work.
- [ ] Account deletion works.

## Pet Profiles

- [ ] Create pet.
- [ ] Edit pet.
- [ ] Delete pet.
- [ ] Upload pet photo.
- [ ] Remove or replace pet photo.
- [ ] Pet age displays correctly.
- [ ] Empty state displays correctly.

## Appointments

- [ ] Create appointment.
- [ ] Edit appointment.
- [ ] Delete appointment.
- [ ] Appointment status changes correctly.
- [ ] Appointment appears on dashboard.
- [ ] Appointment appears on calendar.
- [ ] Reminder settings save correctly.

## Vaccinations

- [ ] Create vaccination.
- [ ] Edit vaccination.
- [ ] Delete vaccination.
- [ ] Due status displays correctly.
- [ ] Vaccination appears on dashboard.
- [ ] Vaccination appears on calendar.
- [ ] Reminder settings save correctly.
- [ ] Attached document flow works.

## Medications

- [ ] Create medication.
- [ ] Edit medication.
- [ ] Stop medication.
- [ ] Delete medication.
- [ ] Dose times display correctly.
- [ ] Medication appears on dashboard.
- [ ] Medication appears on calendar.
- [ ] Local reminders work.

## Documents

- [ ] Upload document.
- [ ] Edit document details.
- [ ] Open document viewer.
- [ ] PDF opens correctly.
- [ ] Delete document.
- [ ] Storage rules prevent unauthorized access.

## Weight Tracking

- [ ] Add weight entry.
- [ ] View weight history.
- [ ] Trend displays correctly.
- [ ] Delete or update behavior works as designed.

## Emergency Profile

- [ ] Create emergency profile.
- [ ] Public profile route opens.
- [ ] QR/app link route works.
- [ ] Private information is not exposed unintentionally.
- [ ] Public route works without login.

## Clinics

- [ ] Create clinic.
- [ ] Edit clinic.
- [ ] Delete clinic.
- [ ] Add vet.
- [ ] Edit vet.
- [ ] Nearby clinic search works.
- [ ] Map opens and renders.
- [ ] Phone, email, and external links work.

## Sharing

- [ ] Doctor code validation works.
- [ ] Owner can share pet with doctor.
- [ ] Owner can revoke share.
- [ ] Doctor sees shared patient.
- [ ] Doctor cannot see unshared pets.
- [ ] Pending doctor state works.

## Notifications

- [ ] Notification permission prompt appears at correct time.
- [ ] Notification settings save.
- [ ] Test notification works.
- [ ] Local reminders schedule.
- [ ] Reminders restore after app restart.
- [ ] Reminders restore after device reboot if supported.
- [ ] FCM token is saved.

## Permissions

- [ ] Location permission includes clear user-facing reason.
- [ ] Notification permission includes clear user-facing reason.
- [ ] App still works when permissions are denied.
- [ ] App does not request unnecessary permissions.

## Web Portal

- [ ] Owner dashboard works.
- [ ] Owner pets page works.
- [ ] Owner profile works.
- [ ] Doctor dashboard works.
- [ ] Doctor patients page works.
- [ ] Doctor profile works.
- [ ] Admin dashboard works.
- [ ] Admin users page works.
- [ ] Admin doctor review works.
- [ ] Role redirects work.

## Release Smoke Test

- [ ] Install release build on a real Android device.
- [ ] Launch app from cold start.
- [ ] Sign in.
- [ ] Create a pet.
- [ ] Add appointment.
- [ ] Add vaccination.
- [ ] Add medication.
- [ ] Upload a document.
- [ ] Enable emergency profile.
- [ ] Share with doctor.
- [ ] Log out and log back in.
- [ ] App survives force close and reopen.
