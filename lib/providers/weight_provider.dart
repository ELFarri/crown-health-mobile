// =================================================================================================================
// FILE: lib/providers/weight_provider.dart
// PURPOSE: GLOBAL WEIGHT HISTORY MANAGER — stores and manages the user's body weight entries over time.
//          Powers the weight progression chart displayed on the Stats and Profile screens.
//
// FEATURES:
//   - Stores up to 30 weight entries per user (rolling window — oldest entry removed when limit is reached)
//   - Each entry contains a date + weight value → used to draw the line chart
//   - Data is persisted locally in SharedPreferences (no backend endpoint for weight history)
//   - User-isolated storage key prevents data leaking between different accounts on the same device
//
// DATA STRUCTURE:
//   _history: List<WeightEntry>
//   Each WeightEntry = { date: DateTime, weight: double }
//   Stored as JSON in SharedPreferences under key: 'weight_history_sarah@email.com'
// =================================================================================================================

import 'dart:convert';                                       // jsonEncode/jsonDecode for serialization
import 'package:flutter/foundation.dart';                   // ChangeNotifier base class
import 'package:shared_preferences/shared_preferences.dart'; // Local persistent storage


// ─────────────────────────────────────────────────────────────────────────────
// WeightEntry — Data class for a single weight measurement
// ─────────────────────────────────────────────────────────────────────────────
class WeightEntry {
  final DateTime date;    // The date/time when the weight was logged
  final double weight;    // Body weight in kilograms

  WeightEntry({required this.date, required this.weight});

  // toMap(): converts to a plain Map for JSON serialization
  // date stored as ISO 8601 string (e.g. "2024-06-07T10:30:00.000") for easy parsing
  Map<String, dynamic> toMap() => {
    'date': date.toIso8601String(),
    'weight': weight,
  };

  // WeightEntry.fromMap(): rebuilds a WeightEntry from a JSON map (from SharedPreferences)
  factory WeightEntry.fromMap(Map<String, dynamic> map) => WeightEntry(
    date: DateTime.parse(map['date']),        // Parse ISO string back to DateTime
    weight: map['weight'].toDouble(),          // Ensure double type (JSON numbers can be int)
  );
}


// ─────────────────────────────────────────────────────────────────────────────
// WeightProvider — ChangeNotifier
// ─────────────────────────────────────────────────────────────────────────────
class WeightProvider extends ChangeNotifier {
  List<WeightEntry> _history = [];              // In-memory list of weight entries (chronological)
  List<WeightEntry> get history => _history;    // Public read-only getter for the chart widget
  String _userEmail = '';                       // Current user's email (for storage key isolation)

  // Constructor: loads user email then reads persisted weight history from local storage
  WeightProvider() {
    _loadUserEmail();
  }

  Future<void> _loadUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    _userEmail = prefs.getString('user_email') ?? '';
    await _loadHistory();
  }

  // initForUser(): called after login to load the correct user's weight history.
  // If history is empty AND an initialWeight is provided, adds the first entry automatically.
  Future<void> initForUser(String email, [double? initialWeight]) async {
    _userEmail = email;
    _history = [];
    await _loadHistory();
    // Add the initial weight entry if no history exists yet (first-time user)
    if (_history.isEmpty && initialWeight != null && initialWeight > 0) {
      await addEntry(initialWeight);
    }
  }

  // Unique storage key per user — prevents weight data from mixing between accounts
  String get _storageKey => 'weight_history_${_userEmail.isNotEmpty ? _userEmail : "local"}';

  // addEntry(): adds a new weight measurement to the history list.
  // Enforces a maximum of 30 entries — removes the oldest when the limit is exceeded.
  // This keeps the chart readable and SharedPreferences storage small.
  Future<void> addEntry(double weight) async {
    final newEntry = WeightEntry(date: DateTime.now(), weight: weight);
    _history.add(newEntry);

    // Rolling window: keep only the most recent 30 entries
    // If the list exceeds 30, remove the first (oldest) entry
    if (_history.length > 30) _history.removeAt(0);

    await _saveHistory();  // Persist to SharedPreferences
    notifyListeners();     // Trigger chart widget rebuild
  }

  // _loadHistory(): reads weight entries from SharedPreferences and deserializes them
  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonStr = prefs.getString(_storageKey);
    if (jsonStr != null) {
      final List<dynamic> decoded = jsonDecode(jsonStr);
      _history = decoded.map((item) => WeightEntry.fromMap(item)).toList();
      notifyListeners(); // Rebuild chart with loaded data
    }
    // If no data found → _history stays empty → chart shows empty state message
  }

  // _saveHistory(): serializes the full weight history list to JSON and saves to SharedPreferences
  Future<void> _saveHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(_history.map((e) => e.toMap()).toList());
    await prefs.setString(_storageKey, encoded);
  }

  // reset(): clears all weight history from memory (called on logout)
  // SharedPreferences data is cleared separately by AuthService.logout()
  void reset() {
    _history = [];
    _userEmail = '';
    notifyListeners();
  }
}
