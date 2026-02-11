# Firebase Setup Guide - LinguaNeural Kids App

## Overview
This app uses Firebase for scalable lesson content management and user progress tracking. Firebase allows you to:
- Store unlimited lessons (100s or 1000s)
- Sync progress across devices
- Update lessons without app updates
- Scale to thousands of users

## Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click **"Create a new project"** or **"Add project"**
3. Enter project name: `lingua-neural-kids-app`
4. **Disable Google Analytics** (optional for now)
5. Click **"Create project"** and wait for setup

## Step 2: Set Up Firebase Services

### Enable Firestore Database
1. In Firebase Console, go to **Build** > **Firestore Database**
2. Click **"Create Database"**
3. Start in **Test Mode** (for development)
4. Choose region closest to your users (e.g., `europe-west1`)
5. Click **"Create"**

### Enable Firebase Authentication
1. Go to **Build** > **Authentication**
2. Click **"Get Started"**
3. Enable **Email/Password** provider
4. This will be used for user login

## Step 3: Create Firestore Collections & Document Structure

### Collection: `english_lessons`

Each document should have this structure:

```json
{
  "id": "a1_01_greetings",
  "title": "Greetings & Introductions",
  "titleArabic": "التحيات والتعريف بالنفس",
  "description": "Learn to say hello and introduce yourself",
  "descriptionArabic": "تعلم كيفية قول مرحبا والتعريف بنفسك",
  "level": "A1",
  "order": 1,
  "category": "Greetings",
  "categoryArabic": "التحيات",
  "units": [
    {
      "id": "a1_01_vocab",
      "type": "vocabulary",
      "exercises": [
        {
          "id": "ex_1",
          "question": "What does 'Hello' mean?",
          "questionArabic": "ماذا تعني كلمة 'Hello'؟",
          "type": "multipleChoice",
          "options": [
            {
              "id": "opt_1",
              "text": "مرحبا",
              "textArabic": "مرحبا",
              "isCorrect": true,
              "audio": null
            },
            {
              "id": "opt_2",
              "text": "وداعا",
              "textArabic": "وداعا",
              "isCorrect": false,
              "audio": null
            }
          ],
          "correctAnswer": "مرحبا",
          "explanation": "Hello is used as a greeting to say hi",
          "explanationArabic": "Hello تُستخدم كتحية للقول مرحبا",
          "xpReward": 10
        }
      ]
    }
  ]
}
```

### Collection: `user_progress`

Document ID: `{userId}_{lessonId}` (e.g., `user1_a1_01_greetings`)

Structure:
```json
{
  "userId": "user1",
  "lessonId": "a1_01_greetings",
  "isCompleted": true,
  "xpEarned": 100,
  "attemptCount": 1,
  "lastAttempted": "2024-02-09T10:30:00Z",
  "exerciseCompletion": {
    "ex_1": true,
    "ex_2": true
  }
}
```

## Step 4: Firebase Rules (Security)

Replace Firestore rules with these (for development):

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Allow anyone to read lessons
    match /english_lessons/{document=**} {
      allow read: if true;
      allow write: if request.auth.uid != null && isAdmin(request.auth.uid);
    }

    // Users can only write their own progress
    match /user_progress/{document=**} {
      allow read: if request.auth.uid != null;
      allow write: if request.auth.uid != null && 
                      request.resource.data.userId == request.auth.uid;
    }
  }
}

function isAdmin(uid) {
  return get(/databases/$(database)/documents/admins/$(uid)).data.isAdmin == true;
}
```

## Step 5: Add Firebase to Your Flutter App

### Android Setup
1. Download `google-services.json` from Firebase Console
2. Place in `android/app/`
3. Already configured in `android/build.gradle` and `android/app/build.gradle`

### iOS Setup
1. Download `GoogleService-Info.plist` from Firebase Console
2. Open `ios/Runner.xcworkspace` in Xcode
3. Right-click `Runner` > **Add Files**
4. Select `GoogleService-Info.plist` and check **Copy if needed**

### Web Setup (for testing)
1. Go to Firebase Console > **Project Settings**
2. Under "Your apps", click **</> Web**
3. Copy the Firebase config
4. Update `web/index.html` with the config (already included)

## Step 6: Initialize Firebase in Your App

Firebase is already initialized in `main.dart`:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const LinguaNeuralApp());
}
```

## Step 7: Upload Lessons to Firebase

### Option A: Firebase Console (Manual)
1. Go to **Firestore Database**
2. Click **"+ Start Collection"** > `english_lessons`
3. Add documents manually (tedious for many lessons)

### Option B: Programmatic Upload (Recommended)
Create a simple script/method to bulk upload:

```dart
Future<void> uploadLessons() async {
  final service = FirebaseEnglishLessonService();
  const lessons = [
    // Your lesson objects
  ];
  await service.bulkAddLessons(lessons);
}
```

### Option C: Use Firebase Import Tool
1. Export lessons as JSON
2. Use Firebase CLI: `firebase firestore:import lessons.json`

## Step 8: Update main.dart

Make sure Firebase is initialized before app starts:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const LinguaNeuralApp());
}
```

## Environment-Specific Configuration

### Development (Test Mode)
- Firestore in Test Mode ✅
- Anyone can read/write

### Production (Live)
1. Create dedicated user for admins
2. Update Firestore security rules
3. Switch to Production Mode
4. Add billing info

## Troubleshooting

### "MissingPluginException"
- Run: `flutter pub get`
- Rebuild app: `flutter clean && flutter pub get && flutter run`

### App crashes on startup
- Check Firebase initialization order
- Ensure `WidgetsFlutterBinding.ensureInitialized()` is called first

### Lessons not loading
- Check Firestore Collection structure matches `english_lesson_model.dart`
- Verify security rules allow read access
- Check console for Firestore errors

### iOS builds fail
- Rebuild Pods: `cd ios && pod repo update && pod install && cd ..`

## Next Steps

1. **Add more lessons** to Firestore
2. **Create admin dashboard** to manage lessons
3. **Set up authentication** properly
4. **Enable offline sync** for better UX
5. **Add analytics** for tracking progress

## Useful Resources
- [Firebase Documentation](https://firebase.flutter.dev/)
- [Firestore Data Model](https://firebase.google.com/docs/firestore/data-model)
- [Firebase Security Rules](https://firebase.google.com/docs/firestore/security/start)
