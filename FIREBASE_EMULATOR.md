Firebase Emulator Setup (local testing, no credit card)

What this does
- Run Firestore and Auth locally on your machine
- No cloud project or billing required
- Use `--dart-define=USE_FIREBASE_EMULATOR=true` when running app to connect to emulator

1) Install Firebase CLI
- Requires Node.js/npm

```bash
npm install -g firebase-tools
```

2) Initialize emulators in the project folder (one-time)

```bash
cd <project-root>
firebase login
firebase init emulators
```

When prompted, select Firestore and Authentication emulators and accept default ports or set to 8080 (firestore) and 9099 (auth).

3) Start the emulator suite

```bash
firebase emulators:start --only firestore,auth,ui
```

The emulator UI will be available at http://localhost:4000 by default.

4) Run the Flutter app connected to emulator

```bash
flutter clean
flutter pub get
flutter run -d chrome --dart-define=USE_FIREBASE_EMULATOR=true
```

5) Upload curriculum to emulator
- Use the in-app "Admin: Upload Curriculum" button on the Home screen
- Or call the provider method from a temporary script if preferred

Notes
- The app code already calls `FirebaseAuth.instance.useAuthEmulator('localhost', 9099)` and
  `FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080')` when the
  `USE_FIREBASE_EMULATOR` dart-define is true (or when running in debug).
- Emulator data is stored locally and reset when you stop it. Use the UI to inspect collections.

Troubleshooting
- If emulator connection fails, check that `firebase emulators:start` is running and ports match.
- If you get permission errors, the emulator allows open access by default for local testing.
