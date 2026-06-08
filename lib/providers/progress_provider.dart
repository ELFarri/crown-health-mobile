// =================================================================================================================
// FILE: lib/providers/progress_provider.dart
// PURPOSE: GLOBAL PROGRESS MANAGER — manages the user's progress photos (before/after).
//          Stores local file paths of photos taken by the user along with their weight and date.
//          Data is persisted locally in SharedPreferences.
//
// FEATURES:
//   - Add a new progress photo entry with weight and date.
//   - Load history of progress photos.
//   - Clear history.
//   - Storage is user-isolated using the user's email.
// =================================================================================================================

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ProgressEntry — Data class for a single progress photo measurement
// ─────────────────────────────────────────────────────────────────────────────
class ProgressEntry {
  final DateTime date;
  final double weight;
  final String imagePath; // Local path to the image file on the device

  ProgressEntry({
    required this.date,
    required this.weight,
    required this.imagePath,
  });

  Map<String, dynamic> toMap() => {
    'date': date.toIso8601String(),
    'weight': weight,
    'imagePath': imagePath,
  };

  factory ProgressEntry.fromMap(Map<String, dynamic> map) => ProgressEntry(
    date: DateTime.parse(map['date']),
    weight: (map['weight'] as num).toDouble(),
    imagePath: map['imagePath'],
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// ProgressProvider — ChangeNotifier
// ─────────────────────────────────────────────────────────────────────────────
class ProgressProvider extends ChangeNotifier {
  List<ProgressEntry> _entries = [];
  List<ProgressEntry> get entries => _entries;
  String _userEmail = '';

  ProgressProvider() {
    _loadUserEmail();
  }

  Future<void> _loadUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    _userEmail = prefs.getString('user_email') ?? '';
    await _loadEntries();
  }

  Future<void> initForUser(String email) async {
    _userEmail = email;
    _entries = [];
    await _loadEntries();
  }

  // Unique storage key per user
  String get _storageKey => 'progress_entries_${_userEmail.isNotEmpty ? _userEmail : "local"}';

  Future<void> addEntry(String imagePath, double weight) async {
    final newEntry = ProgressEntry(
      date: DateTime.now(),
      weight: weight,
      imagePath: imagePath,
    );
    
    // Insert at the beginning so the newest is first
    _entries.insert(0, newEntry);
    
    await _saveEntries();
    notifyListeners();
  }
  
  Future<void> deleteEntry(int index) async {
    if (index >= 0 && index < _entries.length) {
      _entries.removeAt(index);
      await _saveEntries();
      notifyListeners();
    }
  }

  Future<void> _loadEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonStr = prefs.getString(_storageKey);
    if (jsonStr != null) {
      final List<dynamic> decoded = jsonDecode(jsonStr);
      _entries = decoded.map((item) => ProgressEntry.fromMap(item)).toList();
      notifyListeners();
    }
  }

  Future<void> _saveEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(_entries.map((e) => e.toMap()).toList());
    await prefs.setString(_storageKey, encoded);
  }

  void reset() {
    _entries = [];
    _userEmail = '';
    notifyListeners();
  }
}
