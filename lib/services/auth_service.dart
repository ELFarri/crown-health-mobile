// =================================================================================================================
// FILE: lib/services/auth_service.dart
// PURPOSE: Handles all CLIENT-SIDE authentication logic — JWT token storage, login, register, and logout.
//          This is the SECURITY LAYER between the Flutter app and the Django backend.
//
// RESPONSIBILITIES:
//   1. saveToken()  → Persists the JWT access token in device storage after successful login
//   2. getToken()   → Retrieves the stored JWT token to attach to authenticated API requests
//   3. logout()     → Clears ALL user data from device storage (complete session wipe)
//   4. isLoggedIn() → Checks if a JWT token exists (used by main.dart to decide which screen to show)
//   5. login()      → Sends credentials to the backend, receives JWT tokens, saves the access token
//   6. register()   → Creates a new account then automatically logs in the new user
//
// STORAGE MECHANISM — SharedPreferences:
//   SharedPreferences is a key-value store that persists data between app launches.
//   On Android: stored as an XML file in the app's private data directory
//   On iOS: stored in NSUserDefaults
//   The JWT token is saved under the key 'user_token' and survives app restarts.
//
// JWT TOKEN LIFECYCLE:
//   Register/Login → server returns access token → saveToken() → stored in SharedPreferences
//   Every API call → getToken() → sends as: Authorization: Bearer <token>
//   Logout → removes all keys from SharedPreferences → user must log in again
//   Token expiry (60 min) → API returns 401 → app should redirect to LoginScreen
// =================================================================================================================

import 'dart:convert';                                      // jsonEncode/jsonDecode for request/response bodies
import 'package:http/http.dart' as http;                   // HTTP client for making network requests to Django backend
import 'package:shared_preferences/shared_preferences.dart'; // Local key-value storage for JWT token persistence
import 'package:fitness_app/utils/constants.dart';          // App-wide constants (base URL, endpoint paths)


class AuthService {

  // Private constant key used to store and retrieve the JWT token in SharedPreferences.
  // 'static const' → single value shared across all instances; never changes at runtime.
  // Private (_) → cannot be accessed outside this class (encapsulation)
  static const String _tokenKey = 'user_token';


  // ─────────────────────────────────────────────────────────────────────────
  // saveToken(String token)
  // PURPOSE: Persists the JWT access token to device storage after successful login.
  // CALLED BY: login() after a 200 response, register() after auto-login
  // ─────────────────────────────────────────────────────────────────────────
  static Future<void> saveToken(String token) async {
    // SharedPreferences.getInstance() → async factory that returns the singleton SharedPreferences instance
    final prefs = await SharedPreferences.getInstance();

    // setString(key, value) → writes the JWT string to device storage under the key 'user_token'
    // This operation is atomic and persists across app restarts and device reboots
    await prefs.setString(_tokenKey, token);
  }


  // ─────────────────────────────────────────────────────────────────────────
  // getToken()
  // PURPOSE: Retrieves the stored JWT access token from device storage.
  // RETURNS: The JWT string if found, or null if the user is not logged in.
  // CALLED BY: ApiService methods (every authenticated HTTP request attaches this token)
  // ─────────────────────────────────────────────────────────────────────────
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();

    // getString(key) → reads and returns the stored string, or null if the key doesn't exist
    return prefs.getString(_tokenKey);
  }


  // ─────────────────────────────────────────────────────────────────────────
  // logout()
  // PURPOSE: Completely wipes ALL user session data from device storage.
  //          Called when the user taps "Logout" in the Settings screen.
  // EFFECT: After this call, isLoggedIn() will return false → app redirects to LoginScreen
  // ─────────────────────────────────────────────────────────────────────────
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();

    // Remove each stored key individually (selective deletion, not a full prefs wipe)
    await prefs.remove(_tokenKey);              // JWT access token → user must log in again
    await prefs.remove('today_meals_json');     // Cached meal data for today
    await prefs.remove('user_name');            // Cached display name
    await prefs.remove('user_email');           // Cached email address
    await prefs.remove('user_weight');          // Cached body weight
    await prefs.remove('user_height');          // Cached height
    await prefs.remove('user_age');             // Cached age
    await prefs.remove('user_gender');          // Cached gender (stored as int index)
    await prefs.remove('user_activity_level'); // Cached activity level (stored as int index)
    await prefs.remove('user_goal');           // Cached fitness goal (stored as int index)
    await prefs.remove('is_onboarded');        // Onboarding completion flag
  }


  // ─────────────────────────────────────────────────────────────────────────
  // isLoggedIn()
  // PURPOSE: Checks whether the user has a valid JWT token stored locally.
  // RETURNS: true if a non-empty token exists in SharedPreferences, false otherwise.
  // CALLED BY: main.dart FutureBuilder → determines whether to show HomeScreen or LoginScreen
  // NOTE: This does NOT validate the token against the server — it only checks local storage.
  //       An expired token will return true here but fail with 401 on the first API call.
  // ─────────────────────────────────────────────────────────────────────────
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    // Returns true only if token is not null AND not an empty string
    return token != null && token.isNotEmpty;
  }


  // ─────────────────────────────────────────────────────────────────────────
  // login(String email, String password)
  // PURPOSE: Sends login credentials to the Django backend and stores the JWT token on success.
  // RETURNS: true if login succeeded, false if credentials are wrong or network fails.
  // ENDPOINT: POST /api/users/login/ (defined in Constants.loginUrl)
  // REQUEST BODY: { "username": "email@example.com", "password": "secret123" }
  // SUCCESS RESPONSE: { "access": "eyJ...", "refresh": "eyJ...", "user": { ... } }
  // ─────────────────────────────────────────────────────────────────────────
  static Future<bool> login(String email, String password) async {
    try {
      // Log the target URL to the Flutter debug console for development debugging
      print('Attempting login to: ${Constants.loginUrl}');

      // Send an HTTP POST request to the Django login endpoint
      final response = await http.post(
        Uri.parse(Constants.loginUrl),  // Parse string URL into a Uri object
        headers: {
          'Content-Type': 'application/json',  // Tell Django we're sending JSON data
          'Accept': 'application/json',         // Tell Django we expect a JSON response
        },
        // jsonEncode() converts the Dart Map to a JSON string for the request body
        body: jsonEncode({
          'username': email.trim(),  // .trim() removes accidental whitespace from user input
          'password': password,
        }),
      );

      // Log the server's HTTP status code and response body for debugging
      print('Login Response Status: ${response.statusCode}');
      print('Login Response Body: ${response.body}');

      if (response.statusCode == 200) {
        // HTTP 200 OK → credentials are correct
        // jsonDecode() parses the JSON string into a Dart Map
        final data = jsonDecode(response.body);

        // Extract and save the access token to SharedPreferences
        // data['access'] → the short-lived JWT token (valid 60 minutes per settings.py)
        await saveToken(data['access']);
        return true;  // Login successful
      }
    } catch (e) {
      // Network error, timeout, DNS failure, etc.
      print('Login Connection Error: $e');
    }
    return false;  // Login failed (bad credentials or network error)
  }


  // ─────────────────────────────────────────────────────────────────────────
  // register(name, email, password, weight, height, goal)
  // PURPOSE: Creates a new user account on the Django backend, then auto-logs in the new user.
  // RETURNS: null if registration + login succeeded, or an error message string on failure.
  // ENDPOINT: POST /api/users/register/
  // REQUEST BODY: { "username": ..., "email": ..., "name": ..., "password": ...,
  //                 "weight": ..., "height": ..., "goal": ... }
  // ─────────────────────────────────────────────────────────────────────────
  static Future<String?> register(String name, String email, String password,
      double? weight, double? height, String goal) async {
    try {
      print('Attempting register to: ${Constants.registerUrl}');

      final response = await http.post(
        Uri.parse(Constants.registerUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'username': email.trim(),   // Use email as username (Django requires unique username)
          'email': email.trim(),      // Also store as email field (used for login by email)
          'name': name,               // Display name
          'password': password,       // Plain text → Django hashes it with create_user()
          'weight': weight,           // Initial body weight in kg (optional)
          'height': height,           // Height in cm (optional)
          'goal': goal,               // 'loss', 'gain', or 'maintain'
        }),
      );

      print('Register Response Status: ${response.statusCode}');
      print('Register Response Body: ${response.body}');

      if (response.statusCode == 201) {
        // HTTP 201 Created → account successfully created
        // Immediately auto-login so the user doesn't have to type credentials again
        final loggedIn = await login(email, password);

        // null return means SUCCESS (no error message)
        return loggedIn ? null : 'Login after registration failed.';
      }

      // Registration failed → parse the Django error response to extract a readable message
      try {
        // Django returns field-level errors as: { "email": ["This field must be unique."] }
        final errors = jsonDecode(response.body) as Map<String, dynamic>;
        final firstError = errors.values.first;  // Get the first error field's value

        // If the value is a list (Django always returns lists for field errors), get the first message
        if (firstError is List && firstError.isNotEmpty) {
          return firstError.first.toString();  // e.g. "A user with that username already exists."
        }
        return firstError.toString();
      } catch (_) {
        // Fallback: return a generic error with the HTTP status code
        return 'Registration failed (${response.statusCode}).';
      }
    } catch (e) {
      print('Register Connection Error: $e');
      return 'Connection error. Please check your internet.';  // Network failure
    }
  }
}
