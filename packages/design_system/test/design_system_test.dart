import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('primary button renders its label', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: const Scaffold(
          body: AppPrimaryButton(
            label: 'Continue',
            onPressed: null,
          ),
        ),
      ),
    );

    expect(find.text('Continue'), findsOneWidget);
  });
}
