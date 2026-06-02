import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fitness_app/utils/constants.dart';
import '../models/workout_model.dart';
import '../models/food_model.dart';
import '../models/nutrition_stat.dart';
import '../services/auth_service.dart';
import '../providers/meal_provider.dart' show FoodItem;

class ApiService {
  static const String baseUrl = Constants.baseUrl;

  static Future<List<FoodItem>> getUserMeals() async {
    try {
      final token = await AuthService.getToken();
      final response = await http.get(
        Uri.parse(Constants.mealsUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => FoodItem(
          name: json['name'] ?? 'Unknown',
          calories: json['calories'] ?? 0,
          protein: double.tryParse(json['protein'].toString()) ?? 0.0,
          carbs: double.tryParse(json['carbs'].toString()) ?? 0.0,
          fat: double.tryParse(json['fat'].toString()) ?? 0.0,
          category: _capitalize(json['meal_type'] ?? 'General'),
        )).toList();
      }
    } catch (e) {
      print('Meals Error: $e');
    }
    return [];
  }

  static String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1).toLowerCase();
  }

  static Future<List<NutritionStat>> getNutritionStats({String period = 'weekly'}) async {
    try {
      final token = await AuthService.getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/api/nutrition/stats/?period=$period'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => NutritionStat.fromJson(json)).toList();
      }
    } catch (e) {
      print('Nutrition Stats Error: $e');
    }
    return [];
  }

  static Future<bool> addMeal(FoodItem item) async {
    try {
      final token = await AuthService.getToken();
      final response = await http.post(
        Uri.parse('${Constants.mealsUrl}add/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'name': item.name,
          'calories': item.calories,
          'protein': item.protein,
          'carbs': item.carbs,
          'fat': item.fat,
          'meal_type': item.category.toLowerCase(),
        }),
      );
      return response.statusCode == 201;
    } catch (e) {
      print('Add Meal Error: $e');
      return false;
    }
  }

  static Future<List<Map<String, dynamic>>> getUserWorkouts() async {
    try {
      final token = await AuthService.getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/api/workouts/history/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => {
          'id': json['id'],
          'date': json['date'] ?? '',
          'muscle': json['category'] ?? 'General',
          'duration': '${json['duration']} min',
          'calories_burned': json['calories_burned'] ?? 0,
          'workout_name': json['workout_name'] ?? 'Workout',
        }).toList();
      }
    } catch (e) {
      print('Workouts Error: $e');
    }
    return [];
  }

  static Future<List<WorkoutModel>> getAllWorkouts() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/workouts/workouts/'),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => WorkoutModel.fromJson(json)).toList();
      }
    } catch (e) {
      print('All Workouts Error: $e');
    }
    return [];
  }

  static Future<bool> addUserWorkout(int workoutId, int duration) async {
    try {
      final token = await AuthService.getToken();
      final response = await http.post(
        Uri.parse('$baseUrl/api/workouts/history/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'workout': workoutId,
          'duration': duration,
        }),
      );
      return response.statusCode == 201;
    } catch (e) {
      print('Add Workout Error: $e');
      return false;
    }
  }

  static Future<bool> clearWorkoutHistory() async {
    try {
      final token = await AuthService.getToken();
      final response = await http.delete(
        Uri.parse('$baseUrl/api/workouts/history/clear/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Clear Workout History Error: $e');
      return false;
    }
  }

  static Future<bool> logWorkout({
    required String workoutName,
    required String category,
    required int durationMinutes,
  }) async {
    try {
      final token = await AuthService.getToken();
      final response = await http.post(
        Uri.parse('$baseUrl/api/workouts/history/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'workout_name': workoutName,
          'category': category,
          'duration': durationMinutes,
        }),
      );
      return response.statusCode == 201;
    } catch (e) {
      print('Log Workout Error: $e');
      return false;
    }
  }

  static Future<List<FoodModel>> getFoods() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/nutrition/foods/'),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => FoodModel.fromJson(json)).toList();
      }
    } catch (e) {
      print('Foods Error: $e');
    }
    return [];
  }
}

