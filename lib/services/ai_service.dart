import 'package:google_generative_ai/google_generative_ai.dart';
import '../providers/user_provider.dart';
import '../providers/meal_provider.dart';

class AIService {
  static const String _apiKey = 'AIzaSyBlaRgwaA7r_mfDbXaWlrx8VqdGvIHRAYg';
  
  static Future<String> getCoachResponse({
    required String message, 
    required UserProvider user,
    required List<Content> history,
    List<FoodItem> todayMeals = const [],
  }) async {
    if (_apiKey.startsWith('TA_CLE')) {
      return "Please add your API Key.";
    }

    try {
      final model = GenerativeModel(
        model: 'gemini-2.0-flash',
        apiKey: _apiKey,
        systemInstruction: Content.system(
          "You are the Crown Health Coach, a premium fitness assistant. "
          "User Profile: Name: ${user.name}, Weight: ${user.weight}kg, Height: ${user.height}cm, Age: ${user.age}, Goal: ${user.goal.toString().split('.').last}. "
          "Today's Meals: ${todayMeals.map((m) => '${m.name} (${m.calories}kcal)').join(', ')}. "
          "Target Calories: ${user.targetCalories}kcal. "
          "Provide specific advice based on the user's progress and history. Be regal, supportive, and expert."
        ),
      );

      final chat = model.startChat(history: history);
      final response = await chat.sendMessage(Content.text(message));
      
      return response.text ?? "I'm sorry, I couldn't process that. Please try again.";
    } catch (e) {
      print('AI Error: $e');
      return "Coach is currently offline. Please check your connection.";
    }
  }
}
