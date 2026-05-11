import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    this.category = 'General'
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
    protein: map['protein'].toDouble(),
    carbs: map['carbs'].toDouble(),
    fat: map['fat'].toDouble(),
    category: map['category'] ?? 'General',
  );
}

class MealProvider extends ChangeNotifier {
  List<FoodItem> _todayMeals = [];
  List<FoodItem> get todayMeals => _todayMeals;

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
    _loadMeals();
  }

  void addMeal(FoodItem item) {
    _todayMeals.add(item);
    _saveMeals();
    notifyListeners();
  }

  int get totalCalories => _todayMeals.fold(0, (sum, item) => sum + item.calories);
  double get totalProtein => _todayMeals.fold(0, (sum, item) => sum + item.protein);
  double get totalCarbs => _todayMeals.fold(0, (sum, item) => sum + item.carbs);
  double get totalFat => _todayMeals.fold(0, (sum, item) => sum + item.fat);

  Future<void> _loadMeals() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonStr = prefs.getString('today_meals_json');
    if (jsonStr != null) {
      final List<dynamic> decoded = jsonDecode(jsonStr);
      _todayMeals = decoded.map((item) => FoodItem.fromMap(item)).toList();
      notifyListeners();
    }
  }

  Future<void> _saveMeals() async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(_todayMeals.map((m) => m.toMap()).toList());
    await prefs.setString('today_meals_json', encoded);
  }
}
