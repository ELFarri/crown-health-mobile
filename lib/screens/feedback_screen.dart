import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app_theme.dart';

class FeedbackScreen extends StatefulWidget {
  @override
  _FeedbackScreenState createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final TextEditingController _controller = TextEditingController();
  bool _isSent = false;

  void _sendFeedback() {
    if (_controller.text.isEmpty) return;
    
    setState(() {
      _isSent = true;
    });
    
    // Simulate API call
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Feedback sent! Thank you.', style: GoogleFonts.outfit()),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: AppTheme.darkText),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Send Feedback',
          style: GoogleFonts.outfit(color: AppTheme.darkText, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: AppTheme.nearlyDarkBlue.withOpacity(0.1), blurRadius: 20, offset: Offset(0, 10)),
                ],
              ),
              child: Icon(Icons.feedback_outlined, size: 60, color: AppTheme.nearlyDarkBlue),
            ),
            const SizedBox(height: 40),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: Offset(0, 5)),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    'We value your opinion!',
                    style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.darkText),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tell us what you like or what we can improve.',
                    style: GoogleFonts.outfit(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _controller,
                    maxLines: 5,
                    decoration: InputDecoration(
                      hintText: 'Enter your feedback here...',
                      hintStyle: GoogleFonts.outfit(color: Colors.grey[400]),
                      filled: true,
                      fillColor: AppTheme.background,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.all(16),
                    ),
                    style: GoogleFonts.outfit(),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _isSent ? null : _sendFeedback,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.nearlyDarkBlue,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 5,
                    ),
                    child: _isSent
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text('Submit Feedback', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
