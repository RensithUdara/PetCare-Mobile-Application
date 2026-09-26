# Vercel Deployment

PetCare's React web portal can be hosted on Vercel as the project:

```text
pet-care-web
```

This portal contains the owner, doctor, and admin web dashboards. Firebase remains the backend for authentication, Firestore, Cloud Functions, Storage, and push-related services.

## Project Location

Use this folder as the Vercel project root:

```text
web/
```

## Vercel Settings

| Setting | Value |
| --- | --- |
| Project name | `pet-care-web` |
| Framework preset | Vite |
| Root directory | `web` |
| Install command | `npm ci` |
| Build command | `npm run build` |
| Output directory | `dist` |

The file `web/vercel.json` includes SPA rewrites so routes such as `/admin`, `/doctor`, `/owner`, and `/login` work after page refresh.

## Environment Variables

Add these variables in Vercel Project Settings:

```text
VITE_FIREBASE_API_KEY=
VITE_FIREBASE_AUTH_DOMAIN=
VITE_FIREBASE_PROJECT_ID=
VITE_FIREBASE_STORAGE_BUCKET=
VITE_FIREBASE_MESSAGING_SENDER_ID=
VITE_FIREBASE_APP_ID=
```

Do not set this in production:

```text
VITE_USE_EMULATORS=true
```

That variable is only for local emulator development.

## Firebase Authorized Domain

After Vercel creates the deployment domain, add it to Firebase Authentication:

```text
Firebase Console > Authentication > Settings > Authorized domains
```

Add the production domain, for example:

```text
pet-care-web.vercel.app
```

If you connect a custom domain, add that domain too.

## Deploy With Vercel CLI

Install Vercel CLI:

```bash
npm install -g vercel
```

Login:

```bash
vercel login
```

Deploy from the web folder:

```bash
cd web
vercel
```

When prompted:

```text
Set up and deploy? yes
Which scope? your account/team
Link to existing project? no
Project name? pet-care-web
Directory? ./
Override settings? no
```

Deploy to production:

```bash
vercel --prod
```

## Deploy From Git

1. Push the repository to GitHub, GitLab, or Bitbucket.
2. Import the repository in Vercel.
3. Set root directory to `web`.
4. Set project name to `pet-care-web`.
5. Add the Firebase environment variables.
6. Deploy.

## Local Check

Run locally:

```bash
cd web
npm ci
npm run build:vercel
npm run preview
```

Open the preview URL and test:

- `/login`
- `/owner`
- `/doctor`
- `/admin`
- Browser refresh on protected routes
- Firebase login
- Role redirects

## Firebase Hosting Compatibility

The Vite config supports both hosting targets:

- On Firebase Hosting, the portal builds under `/app/` into `public/app`.
- On Vercel, the portal builds at `/` into `web/dist`.

Firebase Hosting is still useful for public emergency profile pages and app links. Vercel can host the portal while Firebase continues to host backend services.
