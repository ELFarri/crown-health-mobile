import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fitness_app/utils/constants.dart';

class AuthService {
  static const String _tokenKey = 'user_token';

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  static Future<bool> login(String email, String password) async {
    try {
      print('Attempting login to: ${Constants.loginUrl}');
      final response = await http.post(
        Uri.parse(Constants.loginUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'username': email.trim(),
          'password': password,
        }),
      );

      print('Login Response Status: ${response.statusCode}');
      print('Login Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await saveToken(data['access']);
        return true;
      }
    } catch (e) {
      print('Login Connection Error: $e');
    }
    return false;
  }

  static Future<String?> register(String name, String email, String password, double? weight, double? height, String goal) async {
    try {
      print('Attempting register to: ${Constants.registerUrl}');
      final response = await http.post(
        Uri.parse(Constants.registerUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'username': email.trim(),
          'email': email.trim(),
          'name': name,
          'password': password,
          'weight': weight,
          'height': height,
          'goal': goal,
        }),
      );

      print('Register Response Status: ${response.statusCode}');
      print('Register Response Body: ${response.body}');

      if (response.statusCode == 201) {
        final loggedIn = await login(email, password);
        return loggedIn ? null : 'Login after registration failed.';
      }

      // Parse real server error message
      try {
        final errors = jsonDecode(response.body) as Map<String, dynamic>;
        final firstError = errors.values.first;
        if (firstError is List && firstError.isNotEmpty) {
          return firstError.first.toString();
        }
        return firstError.toString();
      } catch (_) {
        return 'Registration failed (${response.statusCode}).';
      }
    } catch (e) {
      print('Register Connection Error: $e');
      return 'Connection error. Please check your internet.';
    }
  }
}
