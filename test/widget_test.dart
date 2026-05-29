// Widget tests for Calal Coach (fitness_app)
// Basic smoke test to verify the app launches correctly.

import 'package:flutter_test/flutter_test.dart';
import 'package:fitness_app/main.dart';

void main() {
  testWidgets('App launches smoke test', (WidgetTester tester) async {
    // Build the app and trigger a frame.
    await tester.pumpWidget(const MyApp());
    // Verify the app renders without crashing.
    expect(find.byType(MyApp), findsOneWidget);
  });
}
