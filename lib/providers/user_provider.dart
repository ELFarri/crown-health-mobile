// =================================================================================================================
// FILE: lib/providers/user_provider.dart
// PURPOSE: GLOBAL USER STATE MANAGER — the central state container for the logged-in user's profile,
//          biometric data, and computed fitness metrics (BMR, TDEE, target calories, BMI).
//
// DESIGN PATTERN: Provider (ChangeNotifier)
//   UserProvider extends ChangeNotifier, meaning it can notify all listening widgets when data changes.
//   Widgets subscribe via context.watch<UserProvider>() or Consumer<UserProvider>.
//   When notifyListeners() is called, all subscribed widgets rebuild with the updated values.
//
// DATA SOURCES (two-layer architecture):
//   1. SharedPreferences (local cache) → loads immediately on app start for instant UI display
//   2. Django REST API (backend)       → syncs with the server for authoritative, up-to-date data
//   This strategy ensures the app feels fast (local cache) while staying accurate (server sync).
//
// KEY COMPUTED PROPERTIES:
//   bmr            → Basal Metabolic Rate using Mifflin-St Jeor equation
//                    Male:   BMR = (10 × weight) + (6.25 × height) − (5 × age) + 5
//                    Female: BMR = (10 × weight) + (6.25 × height) − (5 × age) − 161
//   tdee           → Total Daily Energy Expenditure = BMR × activity_multiplier
//   targetCalories → Adjusted calorie goal based on fitness goal:
//                    lose weight: TDEE − 500 kcal
//                    maintain:    TDEE
//                    gain muscle: TDEE + 500 kcal
//   bmi            → Body Mass Index = weight(kg) / height(m)²
// =================================================================================================================

import 'dart:convert';                                       // jsonDecode for parsing API response body
import 'package:flutter/foundation.dart';                   // ChangeNotifier base class + debugPrint
import 'package:http/http.dart' as http;                    // HTTP client for Django API calls
import 'package:shared_preferences/shared_preferences.dart'; // Local key-value persistence
import '../services/auth_service.dart';                     // For reading the JWT token
import '../utils/constants.dart';                           // API endpoint URLs


// ─────────────────────────────────────────────────────────────────────────────
// ENUMS — Type-safe representations of user attribute options
// Using enums instead of raw strings prevents typos and enables exhaustive switch statements.
// ─────────────────────────────────────────────────────────────────────────────

// Gender enum: used in the Mifflin-St Jeor BMR formula (different constant for male vs female)
enum Gender { male, female }

// ActivityLevel enum: maps to PAL (Physical Activity Level) multipliers used in TDEE calculation
enum ActivityLevel { sedentary, lightlyActive, moderatelyActive, veryActive, extraActive }

// Goal enum: determines the calorie offset applied to TDEE to get the daily calorie target
enum Goal { loseWeight, maintain, gainMuscle }


// ─────────────────────────────────────────────────────────────────────────────
// UserProvider CLASS
// ─────────────────────────────────────────────────────────────────────────────
class UserProvider extends ChangeNotifier {

  // ── PRIVATE STATE FIELDS ──
  // All fields are private (prefixed with _). External access only via getters.
  // This enforces controlled mutations through methods that also call notifyListeners().
  String _name = 'User';                                    // User's display name
  String _email = '';                                       // User's email address
  double _weight = 75.0;                                    // Body weight in kg
  double _height = 175.0;                                   // Height in cm
  int _age = 25;                                            // Age in years
  Gender _gender = Gender.male;                             // Biological sex (affects BMR formula)
  ActivityLevel _activityLevel = ActivityLevel.moderatelyActive; // Daily activity level (affects TDEE)
  Goal _goal = Goal.maintain;                               // Fitness goal (affects calorie target)
  bool _isOnboarded = false;                                // Has the user completed the onboarding flow?
  bool _isDarkMode = false;                                 // Is dark theme currently active?
  bool _isLoadingProfile = false;                           // True while fetching profile from the API

  // ── PUBLIC GETTERS ──
  // Read-only access to private fields. Widgets use these via context.watch<UserProvider>().field
  bool get isOnboarded => _isOnboarded;
  bool get isDarkMode => _isDarkMode;
  bool get isLoadingProfile => _isLoadingProfile;
  String get name => _name;
  String get email => _email;
  double get weight => _weight;
  double get height => _height;
  int get age => _age;
  Gender get gender => _gender;
  ActivityLevel get activityLevel => _activityLevel;
  Goal get goal => _goal;


  // ── CONSTRUCTOR ──
  // Called once when ChangeNotifierProvider instantiates UserProvider in main.dart.
  // Triggers the initialization chain: load local cache → sync with backend.
  UserProvider() {
    _initialize();
  }


  // ─────────────────────────────────────────────────────────────────────────
  // _initialize()
  // PURPOSE: Two-phase startup sequence:
  //   Phase 1: Load data from SharedPreferences (fast, local, instant UI)
  //   Phase 2: If JWT token exists, fetch fresh data from Django backend (authoritative)
  // ─────────────────────────────────────────────────────────────────────────
  Future<void> _initialize() async {
    // Phase 1: Load from local cache → triggers notifyListeners() → UI renders immediately
    await _loadFromPrefs();

    // Phase 2: Check for JWT token → if found, sync profile from the Django backend
    final token = await AuthService.getToken();
    if (token != null && token.isNotEmpty) {
      await fetchProfile(); // Network call to GET /api/users/profile/
    }
  }


  // ─────────────────────────────────────────────────────────────────────────
  // fetchProfile()
  // PURPOSE: Fetches the full user profile from the Django REST API and updates local state.
  //          Also maps the backend's string values to the corresponding enum values.
  // ENDPOINT: GET /api/users/profile/ (requires JWT token)
  // CALLED BY: _initialize() on app start, ProfileScreen after profile update
  // ─────────────────────────────────────────────────────────────────────────
  Future<void> fetchProfile() async {
    final token = await AuthService.getToken();
    if (token == null || token.isEmpty) return; // No token → user not logged in → abort

    // Signal to the UI that a network request is in progress (shows loading spinner)
    _isLoadingProfile = true;
    notifyListeners(); // Triggers rebuild of all listening widgets

    try {
      final response = await http.get(
        Uri.parse(Constants.profileUrl), // e.g. https://domain.com/api/users/profile/
        headers: {
          'Authorization': 'Bearer $token',  // JWT token for authentication
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        // Parse the JSON response body into a Dart Map
        final data = jsonDecode(response.body) as Map<String, dynamic>;

        // Update name: prefer 'name' field, fall back to 'username' if name is empty
        _name = (data['name'] as String?)?.isNotEmpty == true
            ? data['name']
            : (data['username'] ?? 'User');
        _email = data['email'] ?? '';

        // Only update numeric fields if they are not null in the response
        // (data['weight'] as num).toDouble() → safely converts int or double to double
        if (data['weight'] != null) _weight = (data['weight'] as num).toDouble();
        if (data['height'] != null) _height = (data['height'] as num).toDouble();
        if (data['age'] != null) _age = data['age'] as int;

        // Map gender string from backend ('male'/'female') → Gender enum
        switch (data['gender']) {
          case 'male':   _gender = Gender.male; break;
          case 'female': _gender = Gender.female; break;
        }

        // Map goal string from backend ('loss'/'gain'/'maintain') → Goal enum
        switch (data['goal']) {
          case 'loss':     _goal = Goal.loseWeight; break;
          case 'gain':     _goal = Goal.gainMuscle; break;
          case 'maintain': _goal = Goal.maintain; break;
        }

        // Map activity_level string → ActivityLevel enum (with PAL multiplier implications)
        switch (data['activity_level']) {
          case 'sedentary':   _activityLevel = ActivityLevel.sedentary; break;
          case 'light':       _activityLevel = ActivityLevel.lightlyActive; break;
          case 'moderate':    _activityLevel = ActivityLevel.moderatelyActive; break;
          case 'active':      _activityLevel = ActivityLevel.veryActive; break;
          case 'very_active': _activityLevel = ActivityLevel.extraActive; break;
        }

        // Persist updated data to local cache so it survives app restarts
        await _saveToPrefs();
        debugPrint('Profile synced: name=$_name, weight=$_weight, height=$_height');

      } else {
        debugPrint('Profile fetch failed: ${response.statusCode} ${response.body}');

        // HTTP 401 Unauthorized → token is expired or invalid → force logout
        if (response.statusCode == 401) {
          await AuthService.logout();
          reset(); // Clear all in-memory state
        }
      }
    } catch (e) {
      debugPrint('Profile fetch error: $e'); // Network error — keep local cache as-is
    } finally {
      // Always hide the loading indicator when done (success or failure)
      _isLoadingProfile = false;
      notifyListeners(); // Trigger final UI rebuild with updated data
    }
  }


  // ─────────────────────────────────────────────────────────────────────────
  // updateProfile()
  // PURPOSE: Updates one or more profile fields locally and persists the changes.
  //          Does NOT send data to the backend — that's done separately in ProfileScreen.
  // PARAMETERS: All optional (named parameters) → only provided fields are updated
  // ─────────────────────────────────────────────────────────────────────────
  void updateProfile({
    String? name,
    double? weight,
    double? height,
    int? age,
    Gender? gender,
    ActivityLevel? activityLevel,
    Goal? goal,
  }) {
    // Only update fields that were explicitly provided (non-null check)
    if (name != null) _name = name;
    if (weight != null) _weight = weight;
    if (height != null) _height = height;
    if (age != null) _age = age;
    if (gender != null) _gender = gender;
    if (activityLevel != null) _activityLevel = activityLevel;
    if (goal != null) _goal = goal;

    _saveToPrefs();     // Persist changes to SharedPreferences
    notifyListeners();  // Notify all listening widgets to rebuild
  }

  // Updates the onboarding completion flag and persists it
  void updateOnboardingStatus(bool status) {
    _isOnboarded = status;
    _saveToPrefs();
    notifyListeners();
  }

  // Toggles between dark and light theme and persists the preference
  void toggleDarkMode(bool value) {
    _isDarkMode = value;
    _saveToPrefs();
    notifyListeners();
  }


  // ─────────────────────────────────────────────────────────────────────────
  // COMPUTED HEALTH METRICS (read-only getters)
  // These are calculated on-the-fly from the stored biometric fields.
  // No separate storage needed — they automatically update when base fields change.
  // ─────────────────────────────────────────────────────────────────────────

  // BMR: Basal Metabolic Rate using the Mifflin-St Jeor Equation (1990).
  // Represents the number of calories the body needs AT REST (no activity).
  // Male formula:   BMR = (10 × weight) + (6.25 × height) − (5 × age) + 5
  // Female formula: BMR = (10 × weight) + (6.25 × height) − (5 × age) − 161
  double get bmr {
    if (_gender == Gender.male) {
      return (10 * _weight) + (6.25 * _height) - (5 * _age) + 5;
    } else {
      return (10 * _weight) + (6.25 * _height) - (5 * _age) - 161;
    }
  }

  // TDEE: Total Daily Energy Expenditure = BMR × Physical Activity Level (PAL) multiplier.
  // Represents total calories burned per day including activity.
  // PAL multipliers from the Harris-Benedict activity factors:
  double get tdee {
    double multiplier = 1.55; // Default: moderately active
    switch (_activityLevel) {
      case ActivityLevel.sedentary:        multiplier = 1.2;   break; // Little/no exercise
      case ActivityLevel.lightlyActive:    multiplier = 1.375; break; // Light exercise 1-3 days/week
      case ActivityLevel.moderatelyActive: multiplier = 1.55;  break; // Moderate exercise 3-5 days/week
      case ActivityLevel.veryActive:       multiplier = 1.725; break; // Hard exercise 6-7 days/week
      case ActivityLevel.extraActive:      multiplier = 1.9;   break; // Very hard exercise + physical job
    }
    return bmr * multiplier; // TDEE = BMR × PAL multiplier
  }

  // TARGET CALORIES: daily calorie goal adjusted for the user's fitness objective.
  // Caloric deficit/surplus of 500 kcal/day → ~0.5kg weight change per week (clinical standard)
  int get targetCalories {
    switch (_goal) {
      case Goal.loseWeight:  return (tdee - 500).round(); // 500 kcal deficit → weight loss
      case Goal.maintain:    return tdee.round();          // No adjustment → weight maintenance
      case Goal.gainMuscle:  return (tdee + 500).round(); // 500 kcal surplus → muscle gain
    }
  }

  // BMI: Body Mass Index = weight (kg) / height (m)²
  // Note: height stored in cm → divide by 100 to convert to meters
  // Example: 75kg / (1.75m)² = 75 / 3.0625 = 24.49
  double get bmi => _weight / ((_height / 100) * (_height / 100));

  // BMI classification based on WHO standard thresholds
  String get bmiStatus {
    if (bmi < 18.5) return 'Underweight'; // BMI < 18.5
    if (bmi < 25)   return 'Normal';       // 18.5 ≤ BMI < 25
    if (bmi < 30)   return 'Overweight';   // 25 ≤ BMI < 30
    return 'Obese';                        // BMI ≥ 30
  }


  // ─────────────────────────────────────────────────────────────────────────
  // LOCAL PERSISTENCE (SharedPreferences)
  // ─────────────────────────────────────────────────────────────────────────

  // _loadFromPrefs(): reads all user data from device storage into memory
  // Called on startup BEFORE the backend sync to ensure immediate UI rendering
  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _isOnboarded   = prefs.getBool('is_onboarded')     ?? false;
    _isDarkMode    = prefs.getBool('is_dark_mode')      ?? false;
    _name          = prefs.getString('user_name')       ?? 'User';
    _email         = prefs.getString('user_email')      ?? '';
    _weight        = prefs.getDouble('user_weight')     ?? 75.0;
    _height        = prefs.getDouble('user_height')     ?? 175.0;
    _age           = prefs.getInt('user_age')           ?? 25;
    // Enums stored as integer index (Gender.male.index = 0, Gender.female.index = 1)
    _gender        = Gender.values[prefs.getInt('user_gender')         ?? 0];
    _activityLevel = ActivityLevel.values[prefs.getInt('user_activity_level') ?? 2]; // Default: moderatelyActive
    _goal          = Goal.values[prefs.getInt('user_goal')             ?? 1]; // Default: maintain
    notifyListeners(); // Trigger UI rebuild with loaded data
  }

  // _saveToPrefs(): writes all current user data to device storage
  // Called after any state update to ensure data persists across app restarts
  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_onboarded',      _isOnboarded);
    await prefs.setBool('is_dark_mode',       _isDarkMode);
    await prefs.setString('user_name',        _name);
    await prefs.setString('user_email',       _email);
    await prefs.setDouble('user_weight',      _weight);
    await prefs.setDouble('user_height',      _height);
    await prefs.setInt('user_age',            _age);
    await prefs.setInt('user_gender',         _gender.index);         // Store as int index
    await prefs.setInt('user_activity_level', _activityLevel.index);  // Store as int index
    await prefs.setInt('user_goal',           _goal.index);           // Store as int index
  }

  // reset(): clears all in-memory state back to defaults (called on logout)
  // Does NOT clear SharedPreferences — that is done by AuthService.logout()
  void reset() {
    _name = 'User';
    _email = '';
    _weight = 75.0;
    _height = 175.0;
    _age = 25;
    _gender = Gender.male;
    _activityLevel = ActivityLevel.moderatelyActive;
    _goal = Goal.maintain;
    _isOnboarded = false;
    _isDarkMode = false;
    _isLoadingProfile = false;
    notifyListeners(); // Trigger rebuild → UI shows default/empty state
  }
}
