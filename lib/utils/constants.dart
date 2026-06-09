import 'package:flutter/foundation.dart';

class Constants {
  static const String baseUrl = "https://mouatazfarri.pythonanywhere.com";
  
  // Préfixes par catégorie
  static const String authPrefix = "/api/auth";
  static const String nutritionPrefix = "/api/nutrition";
  static const String workoutPrefix = "/api/workouts";
  
  // URLs complètes
  static const String loginUrl = "$baseUrl$authPrefix/login/";
  static const String registerUrl = "$baseUrl$authPrefix/register/";
  static const String profileUrl = "$baseUrl$authPrefix/profile/";
  static const String foodsUrl = "$baseUrl$nutritionPrefix/foods/";
  static const String workoutsUrl = "$baseUrl$workoutPrefix/";
  static const String mealsUrl = "$baseUrl$nutritionPrefix/meals/";
}
