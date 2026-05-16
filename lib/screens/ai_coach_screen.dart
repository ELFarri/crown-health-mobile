import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../app_theme.dart';
import '../providers/user_provider.dart';
import '../providers/meal_provider.dart';
import '../services/ai_service.dart';

class AICoachScreen extends StatefulWidget {
  @override
  _AICoachScreenState createState() => _AICoachScreenState();
}

class _AICoachScreenState extends State<AICoachScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<ChatMessage> _messages = [];
  bool _isTyping = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _messages.add(ChatMessage(
      text: "Welcome to your Calal consultation. How can I assist you in your journey to peak performance today?",
      isUser: false,
    ));
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  final List<Content> _history = [];

  Future<void> _handleSend() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final mealProvider = Provider.of<MealProvider>(context, listen: false);
    
    setState(() {
      _messages.add(ChatMessage(text: text, isUser: true));
      _controller.clear();
      _isTyping = true;
    });
    _scrollToBottom();

    final response = await AIService.getCoachResponse(
      message: text,
      user: userProvider,
      history: _history,
      todayMeals: mealProvider.todayMeals,
    );

    setState(() {
      _isTyping = false;
      _messages.add(ChatMessage(text: response, isUser: false));
      // On met à jour l'historique pour Gemini
      _history.add(Content.text(text));
      _history.add(Content.model([TextPart(response)]));
    });
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<UserProvider>(context).isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBackground : AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: isDark ? Colors.white : AppTheme.darkText),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: AppTheme.nearlyDarkBlue.withOpacity(0.1),
              child: Icon(Icons.auto_awesome, color: AppTheme.nearlyDarkBlue, size: 20),
            ),
            SizedBox(width: 12),
            Text(
              'Calal Coach AI',
              style: GoogleFonts.outfit(
                color: isDark ? Colors.white : AppTheme.darkText,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: EdgeInsets.all(20),
              itemCount: _messages.length,
              itemBuilder: (context, index) => _messages[index],
            ),
          ),
          if (_isTyping)
            Padding(
              padding: const EdgeInsets.only(left: 20, bottom: 10),
              child: Row(
                children: [
                  SizedBox(
                    width: 40,
                    child: LinearProgressIndicator(
                      backgroundColor: Colors.transparent,
                      color: AppTheme.nearlyDarkBlue.withOpacity(0.3),
                    ),
                  ),
                  SizedBox(width: 8),
                  Text('Coach is thinking...', style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
          _buildInputArea(isDark),
        ],
      ),
    );
  }

  Widget _buildInputArea(bool isDark) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 10, 20, 30),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: Offset(0, -5))
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              style: GoogleFonts.outfit(color: isDark ? Colors.white : AppTheme.darkText),
              decoration: InputDecoration(
                hintText: 'Ask your coach...',
                hintStyle: GoogleFonts.outfit(color: Colors.grey),
                border: InputBorder.none,
              ),
              onSubmitted: (_) => _handleSend(),
            ),
          ),
          GestureDetector(
            onTap: _handleSend,
            child: Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [AppTheme.nearlyDarkBlue, Color(0xFF6B8EFF)]),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: AppTheme.nearlyDarkBlue.withOpacity(0.3), blurRadius: 10, offset: Offset(0, 4))
                ],
              ),
              child: Icon(Icons.send_rounded, color: Colors.white, size: 24),
            ),
          ),
        ],
      ),
    );
  }
}

class ChatMessage extends StatelessWidget {
  final String text;
  final bool isUser;

  const ChatMessage({required this.text, required this.isUser});

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<UserProvider>(context).isDarkMode;

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: AppTheme.nearlyDarkBlue.withOpacity(0.1),
              child: Icon(Icons.auto_awesome, color: AppTheme.nearlyDarkBlue, size: 14),
            ),
            SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: isUser 
                  ? AppTheme.nearlyDarkBlue 
                  : (isDark ? AppTheme.darkSurface : Colors.white),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                  bottomLeft: Radius.circular(isUser ? 20 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 20),
                ),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: Offset(0, 4))
                ],
              ),
              child: Text(
                text,
                style: GoogleFonts.outfit(
                  color: isUser ? Colors.white : (isDark ? Colors.white : AppTheme.darkText),
                  fontSize: 15,
                  height: 1.4,
                ),
              ),
            ),
          ),
          if (isUser) ...[
            SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.grey.withOpacity(0.2),
              child: Icon(Icons.person, color: Colors.grey, size: 14),
            ),
          ],
        ],
      ),
    );
  }
}
