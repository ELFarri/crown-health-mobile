import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fitness_app/app_theme.dart';
import 'package:fitness_app/services/auth_service.dart';
import 'auth/login_screen.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    // إعداد الـ Animations
    _animationController = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    ));
    
    _animationController.forward();
    
    // التحقق من حالة تسجيل الدخول والانتقال
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    await Future.delayed(Duration(seconds: 3));
    
    final bool loggedIn = await AuthService.isLoggedIn();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) {
            if (loggedIn) {
              return FadeTransition(opacity: animation, child: HomeScreen());
            } else {
              return FadeTransition(opacity: animation, child: LoginScreen());
            }
          },
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.nearlyDarkBlue,
      body: Center(
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Logo/Icon
                Hero(
                  tag: 'logo',
                  child: Container(
                    height: 130,
                    width: 130,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.nearlyDarkBlue.withOpacity(0.5),
                          offset: Offset(0, 12),
                          blurRadius: 24,
                        ),
                        BoxShadow(
                          color: Colors.white.withOpacity(0.15),
                          offset: Offset(0, -4),
                          blurRadius: 12,
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Transform.scale(
                        scale: 1.8,
                        child: Image.asset(
                          'images/app_logo.jpg',
                          width: 130,
                          height: 130,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                ),
                
                SizedBox(height: 40),
                
                // App Name
                Text(
                  'Calal Coach',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 2,
                  ),
                ),
                
                SizedBox(height: 8),
                
                // Tagline
                Text(
                  'Your AI-powered fitness companion',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.9),
                    letterSpacing: 0.5,
                  ),
                ),
                
                SizedBox(height: 50),
                
                // Loading Indicator
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  strokeWidth: 3,
                ),
                
                SizedBox(height: 20),
                
                // Version
                Text(
                  'Version 1.0.0',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
