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

  WeightProvider() {
    _loadHistory();
  }

  Future<void> addEntry(double weight) async {
    final newEntry = WeightEntry(date: DateTime.now(), weight: weight);
    _history.add(newEntry);
    // Keep only last 30 days or entries
    if (_history.length > 30) _history.removeAt(0);
    
    await _saveHistory();
    notifyListeners();
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonStr = prefs.getString('weight_history_json');
    if (jsonStr != null) {
      final List<dynamic> decoded = jsonDecode(jsonStr);
      _history = decoded.map((item) => WeightEntry.fromMap(item)).toList();
      notifyListeners();
    } else {
      // Add initial entry if empty
      addEntry(75.0);
    }
  }

  Future<void> _saveHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(_history.map((e) => e.toMap()).toList());
    await prefs.setString('weight_history_json', encoded);
  }
}
