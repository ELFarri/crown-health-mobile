// =================================================================================================================
// FILE: lib/providers/meal_provider.dart
// PURPOSE: GLOBAL MEAL STATE MANAGER — manages today's logged meals with a dual-layer strategy:
//          local cache for instant UI + backend sync for data accuracy.
//
// ARCHITECTURE — Optimistic UI Pattern:
//   1. On app start: load local cache immediately → UI renders without waiting for network
//   2. In background: fetch from Django backend → replace local data with authoritative server data
//   3. On add meal: add to local list immediately (feels instant) → sync to backend in background
//   If backend is unavailable, local data is used as fallback (offline-friendly)
//
// CONTAINS TWO CLASSES:
//   1. FoodItem        → Pure data class (no state) representing a single food/meal entry
//   2. MealProvider    → ChangeNotifier managing the list of today's meals + totals
//
// DATA STORAGE KEY STRATEGY:
//   Each user+date combination gets a unique SharedPreferences key:
//   'today_meals_sarah@email.com_2024-06-07'
//   This prevents meal data from leaking between users or between days.
// =================================================================================================================

import 'dart:convert';                                       // jsonEncode/jsonDecode for local cache serialization
import 'package:flutter/foundation.dart';                   // ChangeNotifier + debugPrint
import 'package:shared_preferences/shared_preferences.dart'; // Local key-value storage for meal cache
import 'package:fitness_app/services/api_service.dart';     // API calls to Django backend


// ─────────────────────────────────────────────────────────────────────────────
// FoodItem — Data Transfer Object (DTO)
// Represents a single food/meal entry (either from the library or logged by the user).
// Immutable: all fields are final. To "update" an item, create a new FoodItem instance.
// ─────────────────────────────────────────────────────────────────────────────
class FoodItem {
  final String name;      // Food name (e.g. "Grilled Chicken", "Banana")
  final int calories;     // Total calories in kcal (whole number)
  final double protein;   // Protein content in grams
  final double carbs;     // Carbohydrate content in grams
  final double fat;       // Fat content in grams
  final String category;  // Meal type or food group (e.g. "Protein", "Carbs", "Breakfast")

  FoodItem({
    required this.name,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    this.category = 'General',  // Default category if not specified
  });

  // toMap(): converts FoodItem to a plain Dart Map for JSON serialization (local cache storage)
  Map<String, dynamic> toMap() => {
    'name': name,
    'calories': calories,
    'protein': protein,
    'carbs': carbs,
    'fat': fat,
    'category': category,
  };

  // FoodItem.fromMap(): factory constructor to rebuild a FoodItem from a stored JSON map
  // Used when loading meals from SharedPreferences (local cache) or from backend API response
  factory FoodItem.fromMap(Map<String, dynamic> map) => FoodItem(
    name: map['name'],
    calories: map['calories'],
    protein: (map['protein'] as num).toDouble(),  // Cast to num first (could be int or double)
    carbs: (map['carbs'] as num).toDouble(),
    fat: (map['fat'] as num).toDouble(),
    category: map['category'] ?? 'General',
  );
}


// ─────────────────────────────────────────────────────────────────────────────
// MealProvider — ChangeNotifier
// Manages the list of today's meals and exposes computed nutritional totals.
// ─────────────────────────────────────────────────────────────────────────────
class MealProvider extends ChangeNotifier {
  List<FoodItem> _todayMeals = [];        // In-memory list of today's logged meals
  List<FoodItem> get todayMeals => _todayMeals; // Public read-only getter
  String _userEmail = '';                 // Tracks which user's meals are loaded (for storage key isolation)
  bool _isBackendAvailable = true;        // Tracks backend connectivity status

  // Built-in food library: pre-defined common foods with accurate nutritional data.
  // Used in the quick-add meal dialog so users don't have to type from scratch.
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

  // Constructor: immediately loads the user's email then triggers meal loading
  MealProvider() {
    _loadUserEmail();
  }

  // Reads the cached email from SharedPreferences to construct the unique storage key
  Future<void> _loadUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    _userEmail = prefs.getString('user_email') ?? '';
    await _loadMeals();
  }

  // Generates a unique storage key combining the user's email and today's date.
  // Format: 'today_meals_sarah@email.com_2024-06-07'
  // This ensures meal data is isolated per user AND per day.
  String get _storageKey {
    final today = DateTime.now();
    final dateStr = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    return 'today_meals_${_userEmail.isNotEmpty ? _userEmail : "local"}_$dateStr';
  }

  // Called after login to reinitialize the provider with the correct user's meal data
  Future<void> initForUser(String email) async {
    _userEmail = email;
    _todayMeals = [];
    await _loadMeals();
  }

  // addMeal(): adds a meal to today's list using the optimistic UI pattern.
  // Step 1: Add to local list immediately → UI updates instantly (no waiting for network)
  // Step 2: Attempt backend sync in background → keeps server data in sync
  void addMeal(FoodItem item) async {
    _todayMeals.add(item);  // Immediate local addition
    _saveMeals();            // Save to local cache
    notifyListeners();       // Trigger immediate UI rebuild

    // Background backend sync — does NOT block the UI
    try {
      final success = await ApiService.addMeal(item);
      if (!success) {
        debugPrint('[MealProvider] Backend sync failed for "${item.name}" — kept in local cache.');
        _isBackendAvailable = false;
      } else {
        _isBackendAvailable = true;
      }
    } catch (e) {
      _isBackendAvailable = false;
      debugPrint('[MealProvider] Backend sync error: $e');
    }
  }

  // COMPUTED TOTALS — fold() accumulates values across all meals (like SQL SUM)
  int get totalCalories => _todayMeals.fold(0, (sum, item) => sum + item.calories);
  double get totalProtein => _todayMeals.fold(0.0, (sum, item) => sum + item.protein);
  double get totalCarbs => _todayMeals.fold(0.0, (sum, item) => sum + item.carbs);
  double get totalFat => _todayMeals.fold(0.0, (sum, item) => sum + item.fat);

  bool get isBackendAvailable => _isBackendAvailable;

  // _loadMeals(): two-phase loading strategy
  // Phase 1: Load local cache immediately (fast, offline-ready)
  // Phase 2: Fetch from backend in background (authoritative, replaces cache)
  Future<void> _loadMeals() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? jsonStr = prefs.getString(_storageKey);
      if (jsonStr != null) {
        final List<dynamic> decoded = jsonDecode(jsonStr);
        _todayMeals = decoded.map((item) => FoodItem.fromMap(item)).toList();
        notifyListeners(); // Render cached data immediately
      }
    } catch (e) {
      debugPrint('[MealProvider] Local cache load error: $e');
    }
    _fetchMealsFromBackend(); // Start background sync (non-blocking)
  }

  // _fetchMealsFromBackend(): replaces local data with the authoritative backend data
  Future<void> _fetchMealsFromBackend() async {
    try {
      final backendMeals = await ApiService.getUserMeals();
      _todayMeals = backendMeals;  // Backend is the source of truth
      _isBackendAvailable = true;
      notifyListeners();   // Update UI with fresh server data
      _saveMeals();        // Update local cache with fresh data
    } catch (e) {
      _isBackendAvailable = false;
      debugPrint('[MealProvider] Backend unavailable during background sync: $e');
    }
  }

  // _saveMeals(): serializes today's meal list to JSON and saves to SharedPreferences
  Future<void> _saveMeals() async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(_todayMeals.map((m) => m.toMap()).toList());
    await prefs.setString(_storageKey, encoded);
  }

  // reset(): clears all meal state (called on logout)
  void reset() {
    _todayMeals = [];
    _userEmail = '';
    _isBackendAvailable = true;
    notifyListeners();
  }

  // refreshMeals(): forces a fresh reload from both cache and backend (pull-to-refresh)
  Future<void> refreshMeals() async {
    _todayMeals = [];
    await _loadMeals();
  }
}
