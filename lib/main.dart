// =================================================================================================================
// FILE: lib/main.dart
// PURPOSE: APPLICATION ENTRY POINT — the first Dart file executed when the app launches.
//          This file is responsible for 3 critical tasks:
//            1. Initializing global services (notifications) before the UI starts
//            2. Setting up the global state management tree (Provider pattern)
//            3. Building the root MaterialApp widget that bootstraps the entire Flutter UI
//
// ARCHITECTURE OVERVIEW:
//   main() → MultiProvider (state) → MyApp (MaterialApp) → FutureBuilder (auth check)
//              ↓                                                    ↓
//         [UserProvider]                                    token exists? HomeScreen : LoginScreen
//         [ProgressProvider]
//         [WeightProvider]
//         [MealProvider]
//
// STATE MANAGEMENT: Provider Pattern
//   Provider is a dependency injection + reactive state management solution.
//   Each "Provider" holds a piece of global app state (user data, meals, etc.).
//   When state changes, all widgets listening via context.watch<T>() automatically rebuild.
//   This avoids passing data down the widget tree manually (prop drilling).
//
// AUTHENTICATION FLOW ON STARTUP:
//   1. App launches → main() runs
//   2. NotificationService.init() initializes push notifications
//   3. MultiProvider wraps the app with all state managers
//   4. MyApp builds MaterialApp → home: Consumer<UserProvider>
//   5. FutureBuilder calls AuthService.isLoggedIn() → checks SharedPreferences for a JWT token
//   6. If token found → navigate to HomeScreen (user already logged in)
//   7. If no token  → navigate to LoginScreen (user must authenticate)
// =================================================================================================================

// Flutter's core material design library — provides MaterialApp, Scaffold, colors, widgets, etc.
import 'package:flutter/material.dart';

// Google Fonts package — provides access to 1000+ web fonts (used for typography throughout the app)
import 'package:google_fonts/google_fonts.dart';

// Provider package — the state management library used throughout the app
import 'package:provider/provider.dart';

// App-wide theme configuration (colors, typography, dark/light theme definitions)
import 'package:fitness_app/app_theme.dart';

// State management providers — each holds a slice of global application state
import 'package:fitness_app/providers/user_provider.dart';      // Manages user biometrics, JWT-synced profile, BMR/TDEE
import 'package:fitness_app/providers/progress_provider.dart';  // Manages body progress photos (local storage)
import 'package:fitness_app/providers/weight_provider.dart';    // Manages weight history entries (local + chart data)
import 'package:fitness_app/providers/meal_provider.dart';      // Manages today's meals (backend sync + local cache)

// Screen imports — the two possible starting screens based on auth state
import 'package:fitness_app/screens/auth/login_screen.dart';    // Login/Register screen (shown when not authenticated)
import 'package:fitness_app/screens/home_screen.dart';          // Main dashboard (shown when authenticated)

// Service imports
import 'package:fitness_app/services/auth_service.dart';         // Handles JWT token storage/retrieval (SharedPreferences)
import 'package:fitness_app/services/notification_service.dart'; // Handles local push notification initialization


// ─────────────────────────────────────────────────────────────────────────────
// ENTRY POINT FUNCTION
// main() is the first function Flutter calls when the app starts.
// 'async' allows using 'await' for asynchronous initialization before the UI renders.
// ─────────────────────────────────────────────────────────────────────────────
void main() async {
  // REQUIRED: Must be called before any Flutter plugin or async operation in main().
  // Ensures the Flutter engine's binding to the Dart VM is fully initialized.
  // Without this, calling platform channels (plugins) before runApp() would crash the app.
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the notification service (local push notifications for meal reminders, etc.)
  // Wrapped in try-catch: if notifications fail to initialize (e.g. permission denied),
  // the app continues running normally — notifications are non-critical.
  try {
    await NotificationService.init();
  } catch (e) {
    // Log the error to the Flutter debug console but do NOT crash the app
    debugPrint("Notification init failed: $e");
  }

  // Launch the Flutter application.
  // runApp() takes a Widget and makes it the root of the widget tree.
  // MultiProvider wraps the entire app so ALL child widgets can access any provider.
  runApp(
    MultiProvider(
      // providers: list of all ChangeNotifierProviders that will be available app-wide.
      // Each create: (_) => XProvider() instantiates the provider lazily when first accessed.
      // The underscore (_) is the BuildContext — unused here, so abbreviated.
      providers: [
        // UserProvider: stores the logged-in user's profile (name, weight, height, goal, etc.)
        // Also computes BMR, TDEE, target calories using the Mifflin-St Jeor formula.
        // Auto-syncs with the Django backend on startup if a JWT token is found.
        ChangeNotifierProvider(create: (_) => UserProvider()),

        // ProgressProvider: manages the list of body progress photos.
        // Stores photo paths and associated weight snapshots in SharedPreferences (local only).
        ChangeNotifierProvider(create: (_) => ProgressProvider()),

        // WeightProvider: manages the history of body weight entries for the chart.
        // Persists entries in SharedPreferences. Max 30 entries stored.
        ChangeNotifierProvider(create: (_) => WeightProvider()),

        // MealProvider: manages today's logged meals.
        // Uses an optimistic UI strategy: shows local cache immediately, then syncs with backend.
        ChangeNotifierProvider(create: (_) => MealProvider()),
      ],
      child: MyApp(),  // The root application widget — receives access to all providers above
    ),
  );
}


// ─────────────────────────────────────────────────────────────────────────────
// ROOT APPLICATION WIDGET
// MyApp is a StatelessWidget — it has no local mutable state of its own.
// It builds the MaterialApp and decides the initial screen based on auth state.
// ─────────────────────────────────────────────────────────────────────────────
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // context.watch<UserProvider>() subscribes this widget to UserProvider changes.
    // When UserProvider calls notifyListeners() (e.g. dark mode toggled), MyApp rebuilds.
    // This is how the app dynamically switches between light and dark themes.
    final userProvider = context.watch<UserProvider>();

    return MaterialApp(
      title: 'Calal',                          // App name shown in the Android task switcher
      debugShowCheckedModeBanner: false,        // Hides the red "DEBUG" banner in the top-right corner

      // Light theme: used when isDarkMode is false (default)
      theme: AppTheme.lightTheme,

      // Dark theme: used when isDarkMode is true (toggled from Settings screen)
      darkTheme: AppTheme.darkTheme,

      // themeMode: dynamically switches between light and dark based on UserProvider state.
      // ThemeMode.dark  → forces dark theme
      // ThemeMode.light → forces light theme
      themeMode: userProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,

      // home: the first screen shown when the app starts.
      // Consumer<UserProvider> rebuilds this section when UserProvider state changes.
      home: Consumer<UserProvider>(
        builder: (context, userProvider, _) {

          // FutureBuilder: handles async operations inside the build method.
          // future: AuthService.isLoggedIn() → async method that reads the JWT token from SharedPreferences
          // builder: called with the result once the future completes
          return FutureBuilder<bool>(
            future: AuthService.isLoggedIn(),  // Returns true if a JWT token exists in local storage

            builder: (context, snapshot) {
              // While waiting for the SharedPreferences read to complete:
              // Show a centered loading spinner (prevents showing the wrong screen briefly)
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              // Token found → user is authenticated → go directly to the main dashboard
              if (snapshot.data == true) {
                return HomeScreen();
              } else {
                // No token found → user needs to log in → show the login/register screen
                return LoginScreen();
              }
            },
          );
        },
      ),
    );
  }
}


// ─────────────────────────────────────────────────────────────────────────────
// UTILITY CLASS: HexColor
// Converts a CSS hex color string (e.g. "#FF5733" or "FF5733") to a Flutter Color object.
// Used throughout the app to define custom colors from hex codes.
// ─────────────────────────────────────────────────────────────────────────────
class HexColor extends Color {
  // Constructor: takes a hex string, converts it to an integer ARGB color, and passes to Color superclass
  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));

  // Static helper method: converts hex string → int ARGB value
  static int _getColorFromHex(String hexColor) {
    // Remove the '#' symbol if present and convert to uppercase for consistency
    hexColor = hexColor.toUpperCase().replaceAll('#', '');

    // If only 6 hex digits provided (RGB without alpha), prepend 'FF' for full opacity
    // Example: "FF5733" → "FFFF5733" (alpha=FF means 100% opaque)
    if (hexColor.length == 6) {
      hexColor = 'FF$hexColor';
    }

    // Parse the 8-character hex string as a base-16 integer
    // Example: "FFFF5733" → 4294922035 (the integer ARGB color value Flutter uses)
    return int.parse(hexColor, radix: 16);
  }
}
