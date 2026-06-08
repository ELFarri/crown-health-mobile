// =================================================================================================================
// FILE: lib/services/nutrition_service.dart
// PURPOSE: Handles fetching nutrition statistics from the Django backend.
//          Powers the charts and aggregated data displayed on the Stats Screen.
//
// ENDPOINT USED:
//   GET /api/nutrition/stats/?period=weekly (or monthly)
//   This endpoint returns aggregated data (sum of calories, protein, carbs, fat) grouped by date.
// =================================================================================================================

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fitness_app/utils/constants.dart';
import 'package:fitness_app/services/auth_service.dart';

// ─────────────────────────────────────────────────────────────────────────────
// NutritionStats — Data Transfer Object
// Represents a single day's aggregated nutritional totals.
// ─────────────────────────────────────────────────────────────────────────────
class NutritionStats {
  final String date;          // e.g. "2024-06-07"
  final int totalCalories;    // Sum of calories for that date
  final double totalProtein;  // Sum of protein
  final double totalCarbs;    // Sum of carbs
  final double totalFat;      // Sum of fat

  NutritionStats({
    required this.date,
    required this.totalCalories,
    required this.totalProtein,
    required this.totalCarbs,
    required this.totalFat,
  });

  // Factory constructor to build an object from the Django API JSON response
  factory NutritionStats.fromJson(Map<String, dynamic> json) {
    return NutritionStats(
      date: json['date'] ?? '',
      totalCalories: json['total_calories'] ?? 0,
      totalProtein: (json['total_protein'] ?? 0).toDouble(),
      totalCarbs: (json['total_carbs'] ?? 0).toDouble(),
      totalFat: (json['total_fat'] ?? 0).toDouble(),
    );
  }
}


class NutritionService {
  
  // ─────────────────────────────────────────────────────────────────────────
  // getNutritionStats(String period)
  // PURPOSE: Fetches aggregated stats for the specified period ('weekly' or 'monthly').
  // RETURNS: A list of NutritionStats objects, ordered by date.
  // ─────────────────────────────────────────────────────────────────────────
  static Future<List<NutritionStats>> getNutritionStats({String period = 'weekly'}) async {
    // Secure endpoint: requires JWT access token
    final token = await AuthService.getToken();
    if (token == null) return [];

    try {
      // Build the URL with the period query parameter
      final url = '${Constants.baseUrl}/api/nutrition/stats/?period=$period';
      
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        // HTTP 200 OK → parse the JSON array
        final List<dynamic> data = jsonDecode(response.body);
        
        // Map JSON dictionaries to strongly-typed NutritionStats objects
        return data.map((json) => NutritionStats.fromJson(json)).toList();
      } else {
        print('Error fetching stats: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Network error fetching stats: $e');
    }
    
    return []; // Return empty list on failure
  }
}
