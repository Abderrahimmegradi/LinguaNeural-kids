# Firebase Setup - Step by Step for LinguaNeural Kids App

## ⚡ Quick Summary
Your app is ready for Firebase! Follow these steps to:
1. Create a Firebase project
2. Download config files
3. Populate Firestore with lessons
4. Run and test the app

---

## Step 1: Create Firebase Project (5 minutes)

1. Go to **[Firebase Console](https://console.firebase.google.com/)**
2. Click **"Add project"** or **"Create a project"**
3. Enter project name: `lingua-neural-kids-app`
4. Accept terms and click **"Create project"**
5. Wait for setup to complete (usually 1-2 minutes)

---

## Step 2: Enable Firestore Database (3 minutes)

1. In Firebase Console, go to **Build** → **Firestore Database**
2. Click **"Create Database"**
3. Select **"Start in Test Mode"** (for development)
   - ⚠️ **Important**: Switch to Production Mode before publishing!
4. Choose region closest to you (e.g., `europe-west1` for Europe)
5. Click **"Create"**
6. Wait for database initialization

---

## Step 3: Enable Authentication (2 minutes)

1. Go to **Build** → **Authentication**
2. Click **"Get Started"**
3. Click **"Email/Password"** provider
4. Toggle **Enable** and click **"Save"**

---

## Step 4: Download Firebase Config Files

### For Android:
1. Go to **Project Settings** (gear icon, top-left)
2. Under "Your apps", click the Android icon (or **"Add app"** if needed)
3. Register app with package name: `com.example.lingua_neural_kids_app`
4. Click **"Download google-services.json"**
5. Place the file in: `android/app/`

### For iOS:
1. Same **Project Settings** page
2. Click the iOS icon (or **"Add app"**)
3. Enter Bundle ID: `com.example.linguaNeuralKidsApp`
4. Click **"Download GoogleService-Info.plist"**
5. Open `ios/Runner.xcworkspace` in Xcode
6. Right-click `Runner` → **Add Files to "Runner"**
7. Select the `.plist` file and check **"Copy items if needed"**

### For Web (optional, for testing in Chrome):
Config is already in `web/index.html` - no action needed.

---

## Step 5: Update Firestore Security Rules (1 minute)

1. Go to **Firestore Database** → **Rules** tab
2. Replace existing rules with:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Public read for lessons
    match /english_lessons/{document=**} {
      allow read: if true;
      allow write: if false;
    }

    // Users can read/write their own progress
    match /user_progress/{document=**} {
      allow read: if true;
      allow write: if true;
    }
  }
}
```

3. Click **"Publish"**

---

## Step 6: Upload Curriculum to Firestore

### Option A: Using the App (Recommended for testing)

1. Build and run the app:
   ```bash
   flutter clean
   flutter pub get
   flutter run -d chrome
   ```

2. Navigate to **Main Home** screen
3. Look for **"Admin: Upload Curriculum"** button
4. Click it to upload 40+ lessons (A1-C2 levels)
5. Wait for status message

### Option B: Manual Upload via Firebase Console

1. Go to **Firestore Database** → **Data** tab
2. Click **"+ Start Collection"** → `english_lessons`
3. Add documents manually using JSON structure (tedious but good for learning)

### Option C: Firebase CLI (Advanced)

```bash
npm install -g firebase-tools
firebase login
firebase firestore:import exported-lessons.json
```

---

## Step 7: Create Firestore Collections

After uploading curriculum, verify:

1. Go to **Firestore Database** → **Data**
2. You should see two collections:
   - ✅ `english_lessons` (40+ documents with A1-C2 lessons)
   - ✅ `user_progress` (empty initially, populated as users complete lessons)

---

## Step 8: Run and Test the App

### Clean build:
```bash
flutter clean
flutter pub get
flutter run -d chrome
```

### Test flow:
1. **Home Screen** → Click "Start Learning English"
2. **Level Selection** → Choose "A1" level
3. **Lessons List** → See 10+ A1 lessons bilingual (English + Arabic)
4. **Click Lesson** → See bilingual exercise
5. **Answer** → Get feedback and explanation
6. **Complete** → Progress saved to Firestore ✅

### Check Firestore:
1. After completing 1 lesson, go to **Firestore Database** → **Data**
2. Click `user_progress` collection
3. See new document: `user1_a1_01_greetings` with completion data

---

## Troubleshooting

### "MissingPluginException"
```bash
flutter clean
flutter pub get
flutter run -d chrome
```

### "PermissionDenied" errors
- Ensure Security Rules are published ✅
- Check Firestore is in **Test Mode** (not Locked)

### Lessons not loading
- Check `english_lessons` collection has documents
- Verify documents have `level` field (A1, A2, etc.)
- Open browser DevTools (F12) → Console for Firebase errors

### App crashes on startup
- Ensure config files are in correct locations
- Verify `Firebase.initializeApp()` completes before `runApp()`

---

## Architecture Overview

```
Mobile App (Flutter)
     ↓
EnglishLessonProvider (State)
     ↓
FirebaseEnglishLessonService (API)
     ↓
Cloud Firestore (Database)

Collections:
- english_lessons: contains all A1-C2 lessons
- user_progress: tracks user completion & XP
```

---

## Data Flow (Duolingo-style)

1. **User clicks Level** → `LevelSelectionScreen`
2. **Provider loads lessons** → `getLessonsByLevel(level)`
3. **Lessons display** → `EnglishLessonsListScreen`
4. **User clicks lesson** → `EnglishLessonScreen`
5. **Exercise shows** → Question in English + Arabic
6. **User answers** → Gets immediate feedback + explanation
7. **Lesson complete** → Progress saved to Firestore
8. **XP awarded** → Stats update in real-time

---

## Next Steps

- ✅ Firebase setup complete
- ⏳ Run app on Chrome and test full flow
- 🎯 Add Firebase Authentication (email/password login)
- 📊 Implement spaced repetition algorithm
- 🎵 Add audio lessons (optional)
- 🏆 Create achievements/streaks system

---

## Files Modified

| File | Purpose |
|------|---------|
| `lib/models/english_lesson_model.dart` | Lesson data structure |
| `lib/services/firebase_lesson_service.dart` | Firestore operations |
| `lib/providers/english_lesson_provider.dart` | State management |
| `lib/screens/level_selection_screen.dart` | Level picker UI |
| `lib/screens/english_lessons_list_screen.dart` | Lessons list UI |
| `lib/screens/english_lesson_screen.dart` | Lesson player UI |
| `lib/data/firebase_lessons_curriculum.dart` | 40+ sample lessons |
| `main.dart` | Firebase initialization |

---

## Support

- [Firebase Flutter Guide](https://firebase.flutter.dev/)
- [Firestore Documentation](https://firebase.google.com/docs/firestore)
- [Free Tier: 1M reads/month](https://firebase.google.com/pricing/calculator)

**Status**: 🟢 Ready to deploy
