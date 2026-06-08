// =================================================================================================================
// FILE: lib/services/api_service.dart
// PURPOSE: CORE NETWORKING LAYER — handles all HTTP communication with the Django backend.
//          This file isolates all raw HTTP requests, JSON parsing, and error handling so the
//          rest of the app (Providers, UI) doesn't need to deal with network logic directly.
//
// HOW AUTHENTICATED REQUESTS WORK:
//   Every method here first calls AuthService.getToken() to retrieve the stored JWT access token.
//   It then injects this token into the HTTP request headers:
//     'Authorization': 'Bearer <token>'
//   If the token is missing or expired, the Django backend will reject the request with HTTP 401.
// =================================================================================================================

import 'dart:convert';                                    // For encoding/decoding JSON strings
import 'package:http/http.dart' as http;                 // The HTTP client package for making network requests
import 'package:fitness_app/utils/constants.dart';        // App-wide constants including API base URLs
import 'package:fitness_app/services/auth_service.dart';   // To retrieve the JWT access token for secure endpoints
import 'package:fitness_app/providers/meal_provider.dart'; // To instantiate FoodItem objects from JSON responses


class ApiService {
  
  // ─────────────────────────────────────────────────────────────────────────
  // getUserMeals()
  // PURPOSE: Fetches the authenticated user's logged meals for today.
  // ENDPOINT: GET /api/nutrition/meals/
  // RETURNS: A Future list of FoodItem objects. Returns empty list on failure.
  // ─────────────────────────────────────────────────────────────────────────
  static Future<List<FoodItem>> getUserMeals() async {
    // 1. Get the JWT token. If null (user logged out), return empty list immediately to avoid network errors.
    final token = await AuthService.getToken();
    if (token == null) return [];

    try {
      // 2. Make the GET request to the Django backend
      final response = await http.get(
        Uri.parse(Constants.mealsUrl),
        headers: {
          'Authorization': 'Bearer $token',  // Attach the JWT token to prove identity
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      // 3. Check if the server responded with HTTP 200 OK
      if (response.statusCode == 200) {
        // 4. Parse the JSON string into a Dart List of dynamic objects (dictionaries)
        final List<dynamic> data = jsonDecode(response.body);
        
        // 5. Map each dictionary into a strongly-typed FoodItem instance and return the list
        return data.map((json) => FoodItem.fromMap(json)).toList();
      }
    } catch (e) {
      // Catch network errors (e.g., no internet connection)
      print('Error fetching meals: $e');
    }
    
    // Return empty list as a fallback if the request fails
    return [];
  }


  // ─────────────────────────────────────────────────────────────────────────
  // addMeal(FoodItem item)
  // PURPOSE: Sends a newly logged meal to the Django backend to be saved in the database.
  // ENDPOINT: POST /api/nutrition/meals/add/
  // RETURNS: true if successfully saved (HTTP 201), false otherwise.
  // ─────────────────────────────────────────────────────────────────────────
  static Future<bool> addMeal(FoodItem item) async {
    // 1. Retrieve the JWT token
    final token = await AuthService.getToken();
    if (token == null) return false;

    try {
      // 2. Make the POST request
      final response = await http.post(
        Uri.parse(Constants.addMealUrl),
        headers: {
          'Authorization': 'Bearer $token', // Proves identity so Django knows WHICH user logged this meal
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        // 3. Serialize the FoodItem object into a JSON string body
        body: jsonEncode(item.toMap()),
      );

      // 4. HTTP 201 Created indicates successful insertion into the database
      return response.statusCode == 201;
    } catch (e) {
      print('Error adding meal: $e');
      return false;
    }
  }


  // ─────────────────────────────────────────────────────────────────────────
  // searchFoods(String query)
  // PURPOSE: Queries the global food database (catalogue) for autocomplete suggestions.
  // ENDPOINT: GET /api/foods/search/?q=<query>
  // NOTE: This endpoint is public (no Auth header required).
  // RETURNS: A list of FoodItem suggestions matching the search query.
  // ─────────────────────────────────────────────────────────────────────────
  static Future<List<FoodItem>> searchFoods(String query) async {
    // Prevent hitting the server with empty queries
    if (query.trim().isEmpty) return [];
    
    try {
      // Append the search query to the URL as a query parameter (?q=query)
      final url = '${Constants.baseUrl}/api/foods/search/?q=${Uri.encodeComponent(query)}';
      
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => FoodItem.fromMap(json)).toList();
      }
    } catch (e) {
      print('Error searching foods: $e');
    }
    
    return [];
  }
}
