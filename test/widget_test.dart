import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:fitness_app/main.dart';
import 'package:fitness_app/providers/user_provider.dart';
import 'package:fitness_app/providers/progress_provider.dart';
import 'package:fitness_app/providers/weight_provider.dart';
import 'package:fitness_app/providers/meal_provider.dart';

void main() {
  testWidgets('App launches smoke test', (WidgetTester tester) async {
    // Build the app and trigger a frame.
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => UserProvider()),
          ChangeNotifierProvider(create: (_) => ProgressProvider()),
          ChangeNotifierProvider(create: (_) => WeightProvider()),
          ChangeNotifierProvider(create: (_) => MealProvider()),
        ],
        child: MyApp(),
      ),
    );
    // Verify the app renders without crashing.
    expect(find.byType(MyApp), findsOneWidget);
  });
}
