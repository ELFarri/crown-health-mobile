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
          _buildBackground(),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: MediaQuery.of(context).size.height * 0.15),
                    _buildLogo(),
                    SizedBox(height: 40),
                    Text("Welcome Back", style: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.bold, color: AppTheme.darkText)),
                    Text("Sign in to continue to Calal", style: GoogleFonts.outfit(fontSize: 16, color: Colors.grey)),
                    SizedBox(height: 50),
                    _buildGlassInput(hint: "Email Address", icon: Icons.email_rounded, controller: _emailController, type: TextInputType.emailAddress, validator: (v) => !v!.contains('@') ? "Invalid email" : null),
                    SizedBox(height: 16),
                    _buildGlassInput(
                      hint: "Password", icon: Icons.lock_rounded, controller: _passwordController, isObscured: _obscurePassword,
                      suffix: IconButton(icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: AppTheme.nearlyDarkBlue.withOpacity(0.5)), onPressed: () => setState(() => _obscurePassword = !_obscurePassword)),
                      validator: (v) => v!.isEmpty ? "Required" : null
                    ),
                    if (_errorMessage != null) Padding(padding: const EdgeInsets.only(top: 16), child: Text(_errorMessage!, style: TextStyle(color: Colors.red))),
                    SizedBox(height: 40),
                    _buildLoginBtn(),
                    SizedBox(height: 24),
                    _buildRegisterLink(),
                    SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
          if (_isLoading) _buildLoadingOverlay(),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF8F9FD), Color(0xFFE0E5EC), AppTheme.nearlyDarkBlue.withOpacity(0.05)],
        ),
      ),
      child: Stack(
        children: [
          Positioned(top: -100, right: -100, child: _buildBlurCircle(300, AppTheme.nearlyDarkBlue.withOpacity(0.1))),
          Positioned(bottom: -50, left: -50, child: _buildBlurCircle(250, Colors.purple.withOpacity(0.05))),
        ],
      ),
    );
  }

  Widget _buildBlurCircle(double size, Color color) {
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50), child: Container(color: Colors.transparent)),
    );
  }

  Widget _buildLogo() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: Offset(0, 10))]),
      child: Icon(Icons.fitness_center_rounded, size: 50, color: AppTheme.nearlyDarkBlue),
    );
  }

  Widget _buildGlassInput({required String hint, required IconData icon, required TextEditingController controller, bool isObscured = false, Widget? suffix, TextInputType type = TextInputType.text, String? Function(String?)? validator}) {
    return Container(
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.7), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white.withOpacity(0.5)), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: Offset(0, 8))]),
      child: TextFormField(
        controller: controller, obscureText: isObscured, keyboardType: type, validator: validator,
        style: GoogleFonts.outfit(fontWeight: FontWeight.w600),
        decoration: InputDecoration(hintText: hint, hintStyle: GoogleFonts.outfit(color: Colors.grey[400], fontWeight: FontWeight.w400), prefixIcon: Icon(icon, color: AppTheme.nearlyDarkBlue), suffixIcon: suffix, border: InputBorder.none, contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 18)),
      ),
    );
  }

  Widget _buildLoginBtn() {
    return GestureDetector(
      onTap: _login,
      child: Container(
        height: 60, width: double.infinity,
        decoration: BoxDecoration(gradient: LinearGradient(colors: [AppTheme.nearlyDarkBlue, Color(0xFF6B8EFF)]), borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: AppTheme.nearlyDarkBlue.withOpacity(0.3), blurRadius: 15, offset: Offset(0, 8))]),
        child: Center(child: Text("SIGN IN", style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 1.2))),
      ),
    );
  }

  Widget _buildRegisterLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("Don't have an account? ", style: GoogleFonts.outfit(color: Colors.grey)),
        GestureDetector(onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => RegisterScreen())), child: Text("Sign Up", style: GoogleFonts.outfit(color: AppTheme.nearlyDarkBlue, fontWeight: FontWeight.bold))),
      ],
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(color: Colors.black.withOpacity(0.5), child: Center(child: CircularProgressIndicator(color: Colors.white)));
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    
    final error = await AuthService.login(_emailController.text.trim(), _passwordController.text);

    if (error == null) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen()));
    } else {
      setState(() {
        _isLoading = false;
        _errorMessage = error;
      });
    }
  }
}