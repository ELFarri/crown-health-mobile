// =================================================================================================================
// FILE: lib/services/ai_service.dart
// PURPOSE: Connects the Flutter app directly to the Google Gemini AI API to power the AI Coach chatbot.
//          This service sends user fitness data as context to Gemini and returns personalized advice.
//
// HOW IT WORKS (step by step):
//   1. User types a message in the AI Coach screen (e.g. "What should I eat today?")
//   2. ai_coach_screen.dart calls AIService.getCoachResponse(message, user, history, todayMeals)
//   3. AIService creates a GenerativeModel instance using the Gemini 2.5 Flash model
//   4. A system instruction is built with the user's real biometric data and today's meals
//   5. If it's the first message, the instruction is added as the first turn of the conversation
//   6. model.startChat(history) creates a stateful chat session with the full conversation history
//   7. chat.sendMessage(userMessage) sends the user's question with all context
//   8. The AI response text is returned to the screen and displayed as a chat bubble
//
// ARCHITECTURE NOTE — Direct API Call (no backend proxy):
//   The Gemini API is called directly from Flutter using the google_generative_ai Dart SDK.
//   The API key is embedded in the client code. In a production app, the key should be
//   kept server-side (Django backend) to prevent exposure in decompiled APKs.
//
// CONTEXT INJECTION:
//   The system instruction includes the user's live profile data:
//   - Name, weight, height, age → for personalized physical calculations
//   - Today's meals and their calorie counts → so the AI knows what was already eaten
//   - Target calorie goal → so the AI can compute remaining budget
//   This makes the AI Coach context-aware and able to give specific, actionable advice.
// =================================================================================================================

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_generative_ai/google_generative_ai.dart'; // Google's official Dart SDK for Gemini AI API
import '../providers/user_provider.dart';                         // UserProvider for biometric data access
import '../providers/meal_provider.dart';                         // MealProvider/FoodItem for today's meal context
import 'auth_service.dart';
import '../utils/constants.dart';


class AIService {

  // Cached Gemini API authentication key retrieved dynamically from Django backend.
  static String? _cachedApiKey;

  // Helper method to fetch the Gemini API key from the Django backend configuration.
  static Future<String> _getOrFetchApiKey() async {
    if (_cachedApiKey != null) return _cachedApiKey!;
    try {
      final token = await AuthService.getToken();
      if (token == null) throw Exception("User is not authenticated");
      
      final response = await http.get(
        Uri.parse("${Constants.baseUrl}${Constants.authPrefix}/config/"),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _cachedApiKey = data['gemini_api_key'];
        return _cachedApiKey!;
      } else {
        throw Exception("Failed to load Gemini config: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching Gemini API key: $e");
      rethrow;
    }
  }


  // ─────────────────────────────────────────────────────────────────────────
  // getCoachResponse()
  // PURPOSE: Sends a user message to Gemini AI with full fitness context and returns the AI's response.
  // PARAMETERS:
  //   message    → the user's latest text message (question or statement)
  //   user       → the UserProvider instance containing all biometric data and computed goals
  //   history    → the full chat conversation history (list of Content objects for context continuity)
  //   todayMeals → list of FoodItem objects logged today (passed as context for dietary advice)
  // RETURNS: the AI's text response as a String
  // ─────────────────────────────────────────────────────────────────────────
  static Future<String> getCoachResponse({
    required String message,                    // User's input message text
    required UserProvider user,                 // Full user biometric profile + computed TDEE/target calories
    required List<Content> history,             // Chat history for multi-turn conversation continuity
    List<FoodItem> todayMeals = const [],       // Optional list of today's logged meals (defaults to empty)
  }) async {
    try {
      // Retrieve the API key dynamically from the backend
      final apiKey = await _getOrFetchApiKey();

      // Instantiate the Gemini generative model.
      // model: 'gemini-2.5-flash' → fast, cost-efficient model optimized for chat and instruction following
      // apiKey: authenticates the request with Google's AI services
      final model = GenerativeModel(
        model: 'gemini-2.5-flash',
        apiKey: apiKey,
      );

      // Build the SYSTEM INSTRUCTION string — this tells the AI who it is and provides user context.
      // The instruction is injected as the FIRST message in the conversation history (role: "user").
      // This approach is used because Gemini's API does not have a dedicated system prompt field
      // in the same way as OpenAI — we simulate it using the first conversation turn.
      //
      // The instruction includes:
      //   - AI persona definition ("You are the Calal Coach, a premium fitness assistant")
      //   - User profile: name, weight, height, age (for BMR-aware personalization)
      //   - Today's meals: each meal with its calorie count (dietary context)
      //   - Target calorie goal: so the AI can compute the remaining calorie budget
      final instruction =
          "You are the Calal Coach, a premium fitness assistant. "
          "User Profile: Name: ${user.name}, Weight: ${user.weight}kg, Height: ${user.height}cm, Age: ${user.age}. "
          // Map each FoodItem to "Chicken (165kcal)" format, joined by commas
          "Today's Meals: ${todayMeals.map((m) => '${m.name} (${m.calories}kcal)').join(', ')}. "
          "Target Calories: ${user.targetCalories}kcal. "
          "Provide specific advice based on the user's progress. Be supportive, expert, and professional.";

      // chatHistory: the full conversation history passed to the AI as context.
      // This enables MULTI-TURN conversation — the AI remembers previous messages.
      List<Content> chatHistory = [];

      if (history.isEmpty) {
        // FIRST MESSAGE in a new conversation:
        // Add the system instruction as the opening "user" turn.
        // Content.text() creates a Content object with role="user" and the instruction as text.
        chatHistory.add(Content.text(instruction));

        // Add a pre-canned AI "model" response acknowledging the instruction.
        // This establishes the AI's persona before the real conversation begins.
        // Content.model() creates a Content object with role="model" (the AI's side).
        chatHistory.add(Content.model([TextPart("Understood. I am your Calal Coach. How can I assist you today?")]));
      } else {
        // CONTINUING an existing conversation: use the full accumulated history.
        // addAll() appends all previous Content objects into the chatHistory list.
        // The AI will have full memory of all previous messages in this session.
        chatHistory.addAll(history);
      }

      // Create a stateful chat session with the pre-loaded conversation history.
      // startChat(history) → the AI receives all previous messages for context awareness.
      final chat = model.startChat(history: chatHistory);

      // Send the user's current message and await the AI's response.
      // Content.text(message) wraps the user's text in a Content object with role="user"
      final response = await chat.sendMessage(Content.text(message));

      // response.text → extracts the plain text string from the AI's response
      // If the response is null or empty (API issue), return a fallback message
      return response.text ?? "I'm sorry, I couldn't process that. Please try again.";

    } catch (e) {
      // Handle API errors: network failure, invalid key, rate limit exceeded, etc.
      print('AI Error: $e');
      return "Coach Error: $e";  // Return error details as a message (visible to user for debugging)
    }
  }
}
