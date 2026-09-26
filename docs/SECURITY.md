# Security

This document explains how PetCare protects user data and what to check before a release.

## Sensitive Data

PetCare may store sensitive user-provided data:

- Account profile information.
- Pet health records.
- Vaccination, appointment, medication, and weight records.
- Uploaded documents.
- Pet and profile photos.
- Emergency public profile data.
- Location data when the user chooses nearby clinic features.

## Access Control

Access control is enforced by:

- Firebase Authentication.
- Firestore security rules.
- Storage security rules.
- Role checks for owner, doctor, and admin portals.
- Cloud Functions for admin actions.

## Public Emergency Profiles

Emergency profile links are intentionally public. Only information intended for emergency access should be exposed through public routes.

Before release:

- [ ] Verify public profile data is minimal.
- [ ] Verify private owner data is not exposed.
- [ ] Verify deleted or disabled profiles are not accessible.

## Secrets

Never commit:

- Keystore files.
- Keystore passwords.
- API secrets.
- Service account private keys.
- `.env` files with production secrets.

Recommended ignored files:

```text
android/key.properties
android/upload-keystore.jks
*.jks
*.keystore
*.env
```

## Firebase Rules

Run rules tests before deployment:

```bash
cd web
npm run test:rules
```

Deploy rules:

```bash
firebase deploy --only firestore:rules,storage
```

## Reporting Security Issues

Report security issues privately to:

```text
support@petcare.app
```

Replace this address with the real security contact before publishing.
