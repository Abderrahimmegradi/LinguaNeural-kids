import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class DefaultFirebaseOptions {
  const DefaultFirebaseOptions._();

  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not configured for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAvpGY7AygxEu5RsBbez249kIwoCRu-DvI',
    appId: '1:395160022558:web:11189fd4c783a6b951880f',
    messagingSenderId: '395160022558',
    projectId: 'linguaneuralkids',
    authDomain: 'linguaneuralkids.firebaseapp.com',
    storageBucket: 'linguaneuralkids.firebasestorage.app',
    measurementId: 'G-ENB18EBDKS',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDhPq9KNcqZwdThh_dyISBvAyC9e73v2OQ',
    appId: '1:395160022558:android:56e06e88f4f24bd951880f',
    messagingSenderId: '395160022558',
    projectId: 'linguaneuralkids',
    storageBucket: 'linguaneuralkids.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyA3W0loeR2z-lOoDdcgtMFBBGWZTTauQU8',
    appId: '1:395160022558:ios:c7a3b3d8b49a884c51880f',
    messagingSenderId: '395160022558',
    projectId: 'linguaneuralkids',
    storageBucket: 'linguaneuralkids.firebasestorage.app',
    iosBundleId: 'com.linguaneural.studentapp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyA3W0loeR2z-lOoDdcgtMFBBGWZTTauQU8',
    appId: '1:395160022558:ios:c7a3b3d8b49a884c51880f',
    messagingSenderId: '395160022558',
    projectId: 'linguaneuralkids',
    storageBucket: 'linguaneuralkids.firebasestorage.app',
    iosBundleId: 'com.linguaneural.studentapp',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyAvpGY7AygxEu5RsBbez249kIwoCRu-DvI',
    appId: '1:395160022558:web:9f52c8618a29aaa951880f',
    messagingSenderId: '395160022558',
    projectId: 'linguaneuralkids',
    authDomain: 'linguaneuralkids.firebaseapp.com',
    storageBucket: 'linguaneuralkids.firebasestorage.app',
    measurementId: 'G-HD2LRX4X1L',
  );
}