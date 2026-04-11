// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:backend_core/backend_core.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/test.dart';
import 'package:flutter_test/flutter_test.dart';

import '../apps/student_app/lib/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('student app loads', (WidgetTester tester) async {
    setupFirebaseCoreMocks();
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } on FirebaseException catch (error) {
      if (error.code != 'duplicate-app') {
        rethrow;
      }
    }

    // Build our app and trigger a frame.
    await tester.pumpWidget(const StudentApp());

    // Verify the student login screen renders.
    expect(find.text('Student sign in'), findsOneWidget);

    // Verify the initial frame settles without hitting legacy app code.
    await tester.pumpAndSettle();

    expect(find.text('Start today\'s lesson'), findsOneWidget);
  });
}
