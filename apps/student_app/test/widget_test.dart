import 'package:provider/provider.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:student_app/app.dart';
import 'package:student_app/core/providers/user_provider.dart';

void main() {
  testWidgets('navigation shell shows mock-data home screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => UserProvider(),
        child: MyApp(firebaseInitialization: Future<void>.value()),
      ),
    );

    await tester.pump(const Duration(milliseconds: 800));

    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Daily'), findsOneWidget);
    expect(find.text('Wins'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);
  });
}
