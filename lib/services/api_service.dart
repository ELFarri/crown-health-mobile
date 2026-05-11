import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fitness_app/utils/constants.dart';
import '../models/meal_model.dart';
import '../models/workout_model.dart';
import '../models/user_workout_model.dart';
import '../models/food_model.dart';

class ApiService {
  static const String baseUrl = Constants.baseUrl;

  static Future<List<MealModel>> getUserMeals(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/meals/?user_id=$userId'),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => MealModel.fromJson(json)).toList();
      }
    } catch (e) {
      print('Meals Error: $e');
    }
    return [];
  }

  static Future<bool> addMeal(MealModel meal) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/meals/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(meal.toJson()),
      );
      return response.statusCode == 201;
    } catch (e) {
      print('Add Meal Error: $e');
      return false;
    }
  }

  static Future<List<UserWorkoutModel>> getUserWorkouts(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/user-workouts/?user_id=$userId'),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => UserWorkoutModel.fromJson(json)).toList();
      }
    } catch (e) {
      print('Workouts Error: $e');
    }
    return [];
  }

  static Future<List<WorkoutModel>> getAllWorkouts() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/workouts/'),
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

  static Future<bool> addUserWorkout(UserWorkoutModel workout) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/user-workouts/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(workout.toJson()),
      );
      return response.statusCode == 201;
    } catch (e) {
      print('Add Workout Error: $e');
      return false;
    }
  }

  static Future<List<FoodModel>> getFoods() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/foods/'),
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
