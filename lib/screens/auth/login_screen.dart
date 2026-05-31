import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import '../../app_theme.dart';
import '../../services/auth_service.dart';
import '../../providers/user_provider.dart';
import '../home_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Deep Dark Background
          Container(color: Color(0xFF0F172A)),
          
          // Glowing Blobs (More intense like the screenshot)
          Positioned(
            top: -50,
            right: -50,
            child: _buildBlob(350, Color(0xFF4F46E5).withOpacity(0.4)),
          ),
          Positioned(
            bottom: 100,
            left: -100,
            child: _buildBlob(400, Color(0xFF7C3AED).withOpacity(0.3)),
          ),
          Positioned(
            top: 250,
            left: 50,
            child: _buildBlob(150, Color(0xFF0EA5E9).withOpacity(0.2)),
          ),
          
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                child: Container(
                  constraints: BoxConstraints(maxWidth: 400),
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildLogo(),
                        SizedBox(height: 32),
                        Text(
                          "Welcome Back",
                          style: GoogleFonts.outfit(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          "Sign in to continue your fitness journey",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                        SizedBox(height: 60),
                        
                        _buildInput(
                          hint: "Email Address",
                          icon: Icons.email_rounded,
                          controller: _emailController,
                          validator: (v) => !v!.contains('@') ? "Invalid email" : null,
                        ),
                        SizedBox(height: 20),
                        
                        _buildInput(
                          hint: "Password",
                          icon: Icons.lock_rounded,
                          controller: _passwordController,
                          isPassword: true,
                          isObscured: _obscurePassword,
                          onSuffixTap: () => setState(() => _obscurePassword = !_obscurePassword),
                          validator: (v) => v!.isEmpty ? "Required" : null,
                        ),
                        
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {},
                            child: Text(
                              "Forgot Password?",
                              style: GoogleFonts.outfit(
                                color: Colors.white.withOpacity(0.5),
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                        
                        SizedBox(height: 30),
                        _buildLoginBtn(),
                        
                        SizedBox(height: 40),
                        _buildRegisterLink(),
                        
                        if (_errorMessage != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 20),
                            child: Text(
                              _errorMessage!,
                              style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
                            ),
                          ),
                        SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.6),
              child: Center(child: CircularProgressIndicator(color: Colors.white)),
            ),
        ],
      ),
    );
  }

  Widget _buildBlob(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color, color.withOpacity(0)],
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Hero(
      tag: 'logo',
      child: Container(
        height: 100,
        width: 100,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Color(0xFF4F46E5).withOpacity(0.4),
              blurRadius: 20,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: ClipOval(
          child: Transform.scale(
            scale: 1.8,
            child: Image.asset(
              'images/app_logo.jpg',
              width: 100,
              height: 100,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInput({
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    bool isPassword = false,
    bool isObscured = false,
    VoidCallback? onSuffixTap,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: Offset(0, 4))
        ],
      ),
      child: TextFormField(
        controller: controller,
        obscureText: isObscured,
        validator: validator,
        style: GoogleFonts.outfit(color: Color(0xFF1E293B), fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.outfit(color: Colors.grey[500]),
          prefixIcon: Icon(icon, color: Color(0xFF4F46E5), size: 22),
          suffixIcon: isPassword 
            ? IconButton(
                icon: Icon(isObscured ? Icons.visibility_off : Icons.visibility, color: Colors.grey[400]),
                onPressed: onSuffixTap,
              )
            : null,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        ),
      ),
    );
  }

  Widget _buildLoginBtn() {
    return GestureDetector(
      onTap: _login,
      child: Container(
        height: 65,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 15,
              offset: Offset(0, 8),
            )
          ],
        ),
        child: Center(
          child: Text(
            "Login",
            style: GoogleFonts.outfit(
              color: Color(0xFF1E293B),
              fontWeight: FontWeight.w900,
              fontSize: 20,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRegisterLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Don't have an account? ",
          style: GoogleFonts.outfit(color: Colors.white.withOpacity(0.7), fontSize: 14),
        ),
        GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => RegisterScreen()),
          ),
          child: Text(
            "Sign Up",
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final success = await AuthService.login(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (success) {
      // Sync user profile from backend before navigating
      if (mounted) {
        await context.read<UserProvider>().fetchProfile();
      }
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    } else {
      setState(() {
        _isLoading = false;
        _errorMessage = "Invalid email or password";
      });
    }
  }
}