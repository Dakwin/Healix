// This is a Flutter widget test for the Healix app.
//
// This test verifies the presence of key UI elements in the app and their interactions.
// For example, it verifies that the "Start ABC Assessment" button is present, and interactions
// like clicking buttons change the UI as expected.

import 'package:flutter_test/flutter_test.dart';

import 'package:healix/main.dart';

void main() {
  testWidgets('Healix app main screen and ABC Assessment navigation test', (WidgetTester tester) async {
    // Build the Healix app and trigger a frame.
    await tester.pumpWidget(const HealixApp());

    // // Verify that the main screen has the title "Healix - Combat Medic Assistant".
    // expect(find.text('Healix - Combat Medic Assistant'), findsOneWidget);

    // Verify that the "Start ABC Assessment" button is present.
    expect(find.text('Start ABC Assessment'), findsOneWidget);

    // Tap the "Start ABC Assessment" button and trigger a frame.
    await tester.tap(find.text('Start ABC Assessment'));
    await tester.pumpAndSettle();

    // Verify that we are on the ABC Assessment screen by finding one of the assessment steps.
    expect(find.text('Airway: Ensure the airway is clear and open.'), findsOneWidget);

    // Verify that the "Next" button is present.
    expect(find.text('Next'), findsOneWidget);

    // Tap the "Next" button and trigger a frame.
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    // Verify that the current step has moved to "Breathing" after tapping "Next".
    expect(find.text('Breathing: Check if the patient is breathing adequately.'), findsOneWidget);

    // Verify that the "Previous" button is present.
    expect(find.text('Previous'), findsOneWidget);

    // Tap the "Previous" button and trigger a frame.
    await tester.tap(find.text('Previous'));
    await tester.pumpAndSettle();

    // Verify that the current step has moved back to "Airway" after tapping "Previous".
    expect(find.text('Airway: Ensure the airway is clear and open.'), findsOneWidget);
  });
}
