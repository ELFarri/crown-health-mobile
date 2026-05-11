import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum Gender { male, female }
enum ActivityLevel { sedentary, lightlyActive, moderatelyActive, veryActive, extraActive }
enum Goal { loseWeight, maintain, gainMuscle }

class UserProvider extends ChangeNotifier {
  String _name = 'User';
  String _email = 'test@gmail.com';
  double _weight = 75.0; // kg
  double _height = 175.0; // cm
  int _age = 25;
  Gender _gender = Gender.male;
  ActivityLevel _activityLevel = ActivityLevel.moderatelyActive;
  Goal _goal = Goal.maintain;
  
  bool _isOnboarded = false;
  bool _isDarkMode = false;
  
  // Getters
  bool get isOnboarded => _isOnboarded;
  bool get isDarkMode => _isDarkMode;
  String get name => _name;
  String get email => _email;
  double get weight => _weight;
  double get height => _height;
  int get age => _age;
  Gender get gender => _gender;
  ActivityLevel get activityLevel => _activityLevel;
  Goal get goal => _goal;

  UserProvider() {
    _loadFromPrefs();
  }

  // Setters with persistence
  void updateProfile({
    String? name,
    double? weight,
    double? height,
    int? age,
    Gender? gender,
    ActivityLevel? activityLevel,
    Goal? goal,
  }) {
    if (name != null) _name = name;
    if (weight != null) _weight = weight;
    if (height != null) _height = height;
    if (age != null) _age = age;
    if (gender != null) _gender = gender;
    if (activityLevel != null) _activityLevel = activityLevel;
    if (goal != null) _goal = goal;
    
    _saveToPrefs();
    notifyListeners();
  }

  void updateOnboardingStatus(bool status) {
    _isOnboarded = status;
    _saveToPrefs();
    notifyListeners();
  }

  void toggleDarkMode(bool value) {
    _isDarkMode = value;
    _saveToPrefs();
    notifyListeners();
  }

  // BMR Calculation (Mifflin-St Jeor Equation)
  double get bmr {
    if (_gender == Gender.male) {
      return (10 * _weight) + (6.25 * _height) - (5 * _age) + 5;
    } else {
      return (10 * _weight) + (6.25 * _height) - (5 * _age) - 161;
    }
  }

  // TDEE Calculation (Total Daily Energy Expenditure)
  double get tdee {
    double multiplier = 1.2;
    switch (_activityLevel) {
      case ActivityLevel.sedentary: multiplier = 1.2; break;
      case ActivityLevel.lightlyActive: multiplier = 1.375; break;
      case ActivityLevel.moderatelyActive: multiplier = 1.55; break;
      case ActivityLevel.veryActive: multiplier = 1.725; break;
      case ActivityLevel.extraActive: multiplier = 1.9; break;
    }
    return bmr * multiplier;
  }

  // Target Calories based on Goal
  int get targetCalories {
    switch (_goal) {
      case Goal.loseWeight: return (tdee - 500).round();
      case Goal.maintain: return tdee.round();
      case Goal.gainMuscle: return (tdee + 500).round();
    }
  }

  // Helper for BMI
  double get bmi => _weight / ((_height / 100) * (_height / 100));
  
  String get bmiStatus {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25) return 'Normal';
    if (bmi < 30) return 'Overweight';
    return 'Obese';
  }

  // Persistence
  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _isOnboarded = prefs.getBool('is_onboarded') ?? false;
    _isDarkMode = prefs.getBool('is_dark_mode') ?? false;
    _name = prefs.getString('user_name') ?? 'User';
    _weight = prefs.getDouble('user_weight') ?? 75.0;
    _height = prefs.getDouble('user_height') ?? 175.0;
    _age = prefs.getInt('user_age') ?? 25;
    _gender = Gender.values[prefs.getInt('user_gender') ?? 0];
    _activityLevel = ActivityLevel.values[prefs.getInt('user_activity_level') ?? 2];
    _goal = Goal.values[prefs.getInt('user_goal') ?? 1];
    notifyListeners();
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_onboarded', _isOnboarded);
    await prefs.setBool('is_dark_mode', _isDarkMode);
    await prefs.setString('user_name', _name);
    await prefs.setDouble('user_weight', _weight);
    await prefs.setDouble('user_height', _height);
    await prefs.setInt('user_age', _age);
    await prefs.setInt('user_gender', _gender.index);
    await prefs.setInt('user_activity_level', _activityLevel.index);
    await prefs.setInt('user_goal', _goal.index);
  }
}
