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
          // Dark Gradient Background with Blobs
          _buildBackground(),
          
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 40),
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
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        "Sign in to continue your fitness journey",
                        style: GoogleFonts.outfit(
                          fontSize: 15,
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                      SizedBox(height: 50),
                      
                      _buildInput(
                        hint: "Email Address",
                        icon: Icons.email_outlined,
                        controller: _emailController,
                        validator: (v) => !v!.contains('@') ? "Invalid email" : null,
                      ),
                      SizedBox(height: 20),
                      
                      _buildInput(
                        hint: "Password",
                        icon: Icons.lock_outline,
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
                              color: Colors.white.withOpacity(0.6),
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                      
                      SizedBox(height: 20),
                      _buildLoginBtn(),
                      
                      SizedBox(height: 40),
                      _buildRegisterLink(),
                      
                      if (_errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 20),
                          child: Text(
                            _errorMessage!,
                            style: TextStyle(color: Colors.redAccent),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(child: CircularProgressIndicator(color: Colors.white)),
            ),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF1B2E6F),
            Color(0xFF0F172A),
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 100,
            right: -50,
            child: _buildBlob(250, Color(0xFF3B82F6).withOpacity(0.2)),
          ),
          Positioned(
            bottom: 200,
            left: -30,
            child: _buildBlob(200, Color(0xFF8B5CF6).withOpacity(0.15)),
          ),
          Positioned(
            top: 400,
            right: 20,
            child: _buildBlob(100, Colors.white.withOpacity(0.05)),
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
        color: color,
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
        child: Container(color: Colors.transparent),
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      height: 80,
      width: 80,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Icon(Icons.fitness_center_rounded, color: Colors.white, size: 40),
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
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(15),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: isObscured,
        validator: validator,
        style: GoogleFonts.outfit(color: Color(0xFF1B2E6F), fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.outfit(color: Colors.grey[400]),
          prefixIcon: Icon(icon, color: Color(0xFF1B2E6F)),
          suffixIcon: isPassword 
            ? IconButton(
                icon: Icon(isObscured ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
                onPressed: onSuffixTap,
              )
            : null,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildLoginBtn() {
    return GestureDetector(
      onTap: _login,
      child: Container(
        height: 60,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: Offset(0, 5),
            )
          ],
        ),
        child: Center(
          child: Text(
            "Login",
            style: GoogleFonts.outfit(
              color: Color(0xFF1B2E6F),
              fontWeight: FontWeight.bold,
              fontSize: 18,
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
          style: GoogleFonts.outfit(color: Colors.white.withOpacity(0.7)),
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
      _passwordController.text
    );

    if (success) {
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