import 'package:google_generative_ai/google_generative_ai.dart';
import '../providers/user_provider.dart';
import '../providers/meal_provider.dart';

class AIService {
  static const String _apiKey = 'AIzaSyC5UPSXxdDiwnFloBbQDi_VOhKkbfq5Bd4';
  
  static Future<String> getCoachResponse({
    required String message, 
    required UserProvider user,
    required List<Content> history,
    List<FoodItem> todayMeals = const [],
  }) async {
    try {
      final model = GenerativeModel(
        model: 'gemini-2.5-flash',
        apiKey: _apiKey,
      );

      final instruction = "You are the Calal Coach, a premium fitness assistant. "
          "User Profile: Name: ${user.name}, Weight: ${user.weight}kg, Height: ${user.height}cm, Age: ${user.age}. "
          "Today's Meals: ${todayMeals.map((m) => '${m.name} (${m.calories}kcal)').join(', ')}. "
          "Target Calories: ${user.targetCalories}kcal. "
          "Provide specific advice based on the user's progress. Be supportive, expert, and professional.";

      List<Content> chatHistory = [];
      if (history.isEmpty) {
        chatHistory.add(Content.text(instruction));
        chatHistory.add(Content.model([TextPart("Understood. I am your Calal Coach. How can I assist you today?")]));
      } else {
        chatHistory.addAll(history);
      }

      final chat = model.startChat(history: chatHistory);
      final response = await chat.sendMessage(Content.text(message));
      
      return response.text ?? "I'm sorry, I couldn't process that. Please try again.";
    } catch (e) {
      print('AI Error: $e');
      return "Coach Error: $e";
    }
  }
}
