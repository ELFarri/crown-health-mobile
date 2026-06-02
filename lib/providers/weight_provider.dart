import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WeightEntry {
  final DateTime date;
  final double weight;

  WeightEntry({required this.date, required this.weight});

  Map<String, dynamic> toMap() => {
    'date': date.toIso8601String(),
    'weight': weight,
  };

  factory WeightEntry.fromMap(Map<String, dynamic> map) => WeightEntry(
    date: DateTime.parse(map['date']),
    weight: map['weight'].toDouble(),
  );
}

class WeightProvider extends ChangeNotifier {
  List<WeightEntry> _history = [];
  List<WeightEntry> get history => _history;
  String _userEmail = '';

  WeightProvider() {
    _loadUserEmail();
  }

  Future<void> _loadUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    _userEmail = prefs.getString('user_email') ?? '';
    await _loadHistory();
  }

  /// Call this after the user is logged in with their email to load user-specific data
  Future<void> initForUser(String email, [double? initialWeight]) async {
    _userEmail = email;
    _history = [];
    await _loadHistory();
    if (_history.isEmpty && initialWeight != null && initialWeight > 0) {
      await addEntry(initialWeight);
    }
  }

  String get _storageKey => 'weight_history_${_userEmail.isNotEmpty ? _userEmail : "local"}';

  Future<void> addEntry(double weight) async {
    final newEntry = WeightEntry(date: DateTime.now(), weight: weight);
    _history.add(newEntry);
    // Keep only last 30 entries
    if (_history.length > 30) _history.removeAt(0);
    
    await _saveHistory();
    notifyListeners();
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonStr = prefs.getString(_storageKey);
    if (jsonStr != null) {
      final List<dynamic> decoded = jsonDecode(jsonStr);
      _history = decoded.map((item) => WeightEntry.fromMap(item)).toList();
      notifyListeners();
    }
    // Don't add fake initial entry — show empty chart until user logs a weight
  }

  Future<void> _saveHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(_history.map((e) => e.toMap()).toList());
    await prefs.setString(_storageKey, encoded);
  }

  void reset() {
    _history = [];
    _userEmail = '';
    notifyListeners();
  }
}
