import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:fitness_app/app_theme.dart';
import 'package:fitness_app/providers/user_provider.dart';
import 'package:fitness_app/providers/progress_provider.dart';
import 'package:fitness_app/providers/weight_provider.dart';
import 'package:fitness_app/providers/meal_provider.dart';
import 'package:fitness_app/screens/auth/login_screen.dart';
import 'package:fitness_app/screens/home_screen.dart';
import 'package:fitness_app/services/auth_service.dart';
import 'package:fitness_app/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await NotificationService.init();
  } catch (e) {
    debugPrint("Notification init failed: $e");
  }
  runApp(
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
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    
    return MaterialApp(
      title: 'Calal',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: userProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: Consumer<UserProvider>(
        builder: (context, userProvider, _) {
          return FutureBuilder<bool>(
            future: AuthService.isLoggedIn(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(body: Center(child: CircularProgressIndicator()));
              }
              if (snapshot.data == true) {
                return HomeScreen();
              } else {
                return LoginScreen();
              }
            },
          );
        },
      ),
    );
  }
}

class HexColor extends Color {
  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));

  static int _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll('#', '');
    if (hexColor.length == 6) {
      hexColor = 'FF$hexColor';
    }
    return int.parse(hexColor, radix: 16);
  }
}
