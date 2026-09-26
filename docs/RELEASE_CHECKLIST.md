# Release Checklist

Use this checklist for every PetCare release.

## Version

- [ ] Update `pubspec.yaml` version.
- [ ] Increase Android version code.
- [ ] Update `docs/CHANGELOG.md`.
- [ ] Confirm app name and package name.

## Quality

- [ ] Run `flutter analyze`.
- [ ] Run `flutter test`.
- [ ] Run web tests if web changed.
- [ ] Run Firebase rules tests if rules changed.
- [ ] Run functions tests if functions changed.
- [ ] Test release build on a real Android device.

## Firebase

- [ ] Firestore rules are deployed.
- [ ] Firestore indexes are deployed.
- [ ] Storage rules are deployed.
- [ ] Functions are deployed.
- [ ] Hosting is deployed.
- [ ] Firebase Android app config matches package name.
- [ ] Push notifications work.

## Android

- [ ] Release signing is configured.
- [ ] Build uses upload key, not debug key.
- [ ] Target SDK meets Play requirement.
- [ ] Min SDK is acceptable.
- [ ] App Bundle builds successfully.
- [ ] App icon is correct.
- [ ] Splash screen is correct.
- [ ] App label is `PetCare`.

## Privacy And Policy

- [ ] Privacy policy is published.
- [ ] Privacy policy is linked inside the app.
- [ ] Account deletion works.
- [ ] Data Safety form is updated.
- [ ] App content forms are updated.
- [ ] Permission usage is accurate and minimal.
- [ ] Store listing does not make unsupported claims.

## Play Console

- [ ] `.aab` uploaded.
- [ ] Release notes added.
- [ ] Screenshots uploaded.
- [ ] Feature graphic uploaded.
- [ ] Store listing completed.
- [ ] Content rating completed.
- [ ] Test track release reviewed.
- [ ] Production rollout submitted.

## Build Command

```bash
flutter clean
flutter pub get
flutter analyze
flutter test
flutter build appbundle --release
```
