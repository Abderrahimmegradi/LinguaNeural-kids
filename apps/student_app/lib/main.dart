import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'core/providers/user_provider.dart';
import 'firebase_options.dart';

Future<void> _initializeFirebase() async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (error, stackTrace) {
    FlutterError.reportError(
      FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'firebase_core',
        context: ErrorDescription('while initializing Firebase in main.dart'),
      ),
    );
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final firebaseInitialization = _initializeFirebase();

  runApp(
    ChangeNotifierProvider(
      create: (_) => UserProvider(),
      child: MyApp(firebaseInitialization: firebaseInitialization),
    ),
  );
}