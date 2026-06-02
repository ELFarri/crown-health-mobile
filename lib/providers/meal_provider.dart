import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fitness_app/services/api_service.dart';

class FoodItem {
  final String name;
  final int calories;
  final double protein;
  final double carbs;
  final double fat;
  final String category;

  FoodItem({
    required this.name,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    this.category = 'General',
  });

  Map<String, dynamic> toMap() => {
        'name': name,
        'calories': calories,
        'protein': protein,
        'carbs': carbs,
        'fat': fat,
        'category': category,
      };

  factory FoodItem.fromMap(Map<String, dynamic> map) => FoodItem(
        name: map['name'],
        calories: map['calories'],
        protein: (map['protein'] as num).toDouble(),
        carbs: (map['carbs'] as num).toDouble(),
        fat: (map['fat'] as num).toDouble(),
        category: map['category'] ?? 'General',
      );
}

class MealProvider extends ChangeNotifier {
  List<FoodItem> _todayMeals = [];
  List<FoodItem> get todayMeals => _todayMeals;
  String _userEmail = '';

  final List<FoodItem> foodLibrary = [
    FoodItem(name: 'Chicken Breast (100g)', calories: 165, protein: 31, carbs: 0, fat: 3.6, category: 'Protein'),
    FoodItem(name: 'Rice (100g cooked)', calories: 130, protein: 2.7, carbs: 28, fat: 0.3, category: 'Carbs'),
    FoodItem(name: 'Egg (1 large)', calories: 70, protein: 6, carbs: 0.6, fat: 5, category: 'Protein'),
    FoodItem(name: 'Avocado (100g)', calories: 160, protein: 2, carbs: 8.5, fat: 14.7, category: 'Fat'),
    FoodItem(name: 'Oats (50g)', calories: 190, protein: 6, carbs: 33, fat: 3.5, category: 'Carbs'),
    FoodItem(name: 'Peanut Butter (1 tbsp)', calories: 95, protein: 3.5, carbs: 3, fat: 8, category: 'Fat'),
    FoodItem(name: 'Banana (1 medium)', calories: 105, protein: 1.3, carbs: 27, fat: 0.4, category: 'Fruit'),
    FoodItem(name: 'Greek Yogurt (100g)', calories: 59, protein: 10, carbs: 3.6, fat: 0.4, category: 'Protein'),
  ];

  MealProvider() {
    _loadUserEmail();
  }

  Future<void> _loadUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    _userEmail = prefs.getString('user_email') ?? '';
    await _loadMeals();
  }

  /// Returns a user+date specific storage key to isolate data per account
  String get _storageKey {
    final today = DateTime.now();
    final dateStr =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    return 'today_meals_${_userEmail.isNotEmpty ? _userEmail : "local"}_$dateStr';
  }

  /// Call this after login to initialise provider with user-specific data
  Future<void> initForUser(String email) async {
    _userEmail = email;
    _todayMeals = [];
    await _loadMeals();
  }

  void addMeal(FoodItem item) async {
    _todayMeals.add(item);
    _saveMeals();
    notifyListeners();
    try {
      await ApiService.addMeal(item);
    } catch (e) {
      print('Failed to sync meal to backend: $e');
    }
  }

  int get totalCalories => _todayMeals.fold(0, (sum, item) => sum + item.calories);
  double get totalProtein => _todayMeals.fold(0.0, (sum, item) => sum + item.protein);
  double get totalCarbs => _todayMeals.fold(0.0, (sum, item) => sum + item.carbs);
  double get totalFat => _todayMeals.fold(0.0, (sum, item) => sum + item.fat);

  Future<void> _loadMeals() async {
    // 1. Try backend first (always authoritative for logged-in user)
    try {
      final backendMeals = await ApiService.getUserMeals();
      if (backendMeals.isNotEmpty) {
        _todayMeals = backendMeals;
        notifyListeners();
        return;
      }
    } catch (e) {
      print('Failed to load backend meals: $e');
    }

    // 2. Fallback to local user-specific storage
    final prefs = await SharedPreferences.getInstance();
    final String? jsonStr = prefs.getString(_storageKey);
    if (jsonStr != null) {
      final List<dynamic> decoded = jsonDecode(jsonStr);
      _todayMeals = decoded.map((item) => FoodItem.fromMap(item)).toList();
      notifyListeners();
    }
  }

  Future<void> _saveMeals() async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(_todayMeals.map((m) => m.toMap()).toList());
    await prefs.setString(_storageKey, encoded);
  }

  void reset() {
    _todayMeals = [];
    _userEmail = '';
    notifyListeners();
  }

  Future<void> refreshMeals() async {
    _todayMeals = [];
    await _loadMeals();
  }
}
