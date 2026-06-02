import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import '../../app_theme.dart';
import '../../services/auth_service.dart';
import '../../providers/user_provider.dart';
import '../../providers/meal_provider.dart';
import '../../providers/weight_provider.dart';
import '../../providers/progress_provider.dart';
import '../home_screen.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final PageController _pageController = PageController();
  final _formKey = GlobalKey<FormState>();
  int _currentPage = 0;
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  // Controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Onboarding State
  int _age = 25;
  double _weight = 70.0;
  double _height = 170.0;
  Gender _gender = Gender.male;
  ActivityLevel _activity = ActivityLevel.moderatelyActive;
  Goal _goal = Goal.maintain;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _buildBackground(),
          SafeArea(
            child: Column(
              children: [
                _buildProgressIndicator(),
                Expanded(
                  child: Form(
                    key: _formKey,
                    child: PageView(
                      controller: _pageController,
                      physics: NeverScrollableScrollPhysics(),
                      onPageChanged: (idx) => setState(() => _currentPage = idx),
                      children: [
                        _buildStepIdentity(),
                        _buildStepBio(),
                        _buildStepStats(),
                        _buildStepGoalActivity(),
                        _buildStepAccount(),
                      ],
                    ),
                  ),
                ),
                _buildBottomNav(),
              ],
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

  Widget _buildProgressIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
      child: Row(
        children: List.generate(5, (index) {
          bool isActive = index <= _currentPage;
          return Expanded(
            child: AnimatedContainer(
              duration: Duration(milliseconds: 300),
              height: 6,
              margin: EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                gradient: isActive ? LinearGradient(colors: [AppTheme.nearlyDarkBlue, Color(0xFF6B8EFF)]) : null,
                color: isActive ? null : Colors.grey.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
                boxShadow: isActive ? [BoxShadow(color: AppTheme.nearlyDarkBlue.withOpacity(0.3), blurRadius: 8, offset: Offset(0, 2))] : [],
              ),
            ),
          );
        }),
      ),
    );
  }

  // --- STEPS ---

  Widget _buildStepIdentity() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: Offset(0, 10))]),
            child: Icon(Icons.auto_awesome_rounded, size: 60, color: AppTheme.nearlyDarkBlue),
          ),
          SizedBox(height: 40),
          Text("Welcome to\nCalal", textAlign: TextAlign.center, style: GoogleFonts.outfit(fontSize: 36, fontWeight: FontWeight.w900, color: AppTheme.darkText, height: 1.1)),
          SizedBox(height: 16),
          Text("Let's build your health profile. First, how should we call you?", textAlign: TextAlign.center, style: GoogleFonts.outfit(fontSize: 16, color: Colors.grey[600], height: 1.5)),
          SizedBox(height: 60),
          _buildGlassInput(hint: "Your Full Name", icon: Icons.person_rounded, controller: _nameController, validator: (v) => v!.isEmpty ? "Name is required" : null),
        ],
      ),
    );
  }

  Widget _buildStepBio() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("A bit about you", style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.bold, color: AppTheme.darkText)),
          SizedBox(height: 40),
          Row(
            children: [
              Expanded(child: _buildSelectCard(icon: Icons.male_rounded, label: "Male", isSelected: _gender == Gender.male, onTap: () => setState(() => _gender = Gender.male))),
              SizedBox(width: 20),
              Expanded(child: _buildSelectCard(icon: Icons.female_rounded, label: "Female", isSelected: _gender == Gender.female, onTap: () => setState(() => _gender = Gender.female))),
            ],
          ),
          SizedBox(height: 50),
          Text("Age: $_age years old", style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.nearlyDarkBlue)),
          Slider(value: _age.toDouble(), min: 10, max: 100, divisions: 90, activeColor: AppTheme.nearlyDarkBlue, onChanged: (val) => setState(() => _age = val.round())),
        ],
      ),
    );
  }

  Widget _buildStepStats() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Physical Stats", style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.bold, color: AppTheme.darkText)),
          SizedBox(height: 50),
          _buildStatCard(label: "Height", value: "${_height.round()}", unit: "cm", onMinus: () => setState(() => _height--), onPlus: () => setState(() => _height++)),
          SizedBox(height: 24),
          _buildStatCard(label: "Weight", value: "${_weight.toStringAsFixed(1)}", unit: "kg", onMinus: () => setState(() => _weight -= 0.5), onPlus: () => setState(() => _weight += 0.5)),
        ],
      ),
    );
  }

  Widget _buildStepGoalActivity() {
    return SingleChildScrollView(
      physics: BouncingScrollPhysics(),
      padding: const EdgeInsets.all(40.0),
      child: Column(
        children: [
          Text("Personal Goals", style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.bold, color: AppTheme.darkText)),
          SizedBox(height: 20),
          _buildModernSelector<Goal>(items: Goal.values, groupValue: _goal, onChanged: (val) => setState(() => _goal = val), labelBuilder: (g) => g == Goal.loseWeight ? "Lose Weight" : g == Goal.maintain ? "Maintain" : "Gain Muscle"),
          SizedBox(height: 30),
          Text("Activity Level", style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.bold, color: AppTheme.darkText)),
          SizedBox(height: 20),
          _buildModernSelector<ActivityLevel>(items: ActivityLevel.values, groupValue: _activity, onChanged: (val) => setState(() => _activity = val), labelBuilder: (l) => l.toString().split('.').last.replaceAllMapped(RegExp(r'([A-Z])'), (match) => ' ${match.group(0)}').capitalize()),
        ],
      ),
    );
  }

  Widget _buildStepAccount() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Secure Account", style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.bold, color: AppTheme.darkText)),
          SizedBox(height: 16),
          Text("Last step! Create your login details to save your profile.", textAlign: TextAlign.center, style: GoogleFonts.outfit(color: Colors.grey)),
          SizedBox(height: 40),
          _buildGlassInput(hint: "Email Address", icon: Icons.email_rounded, controller: _emailController, type: TextInputType.emailAddress, validator: (v) => !v!.contains('@') ? "Invalid email" : null),
          SizedBox(height: 16),
          _buildGlassInput(
            hint: "Password", icon: Icons.lock_rounded, controller: _passwordController, isObscured: _obscurePassword,
            suffix: IconButton(icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: AppTheme.nearlyDarkBlue.withOpacity(0.5)), onPressed: () => setState(() => _obscurePassword = !_obscurePassword)),
            validator: (v) => v!.length < 6 ? "Min 6 characters" : null
          ),
          if (_errorMessage != null) Padding(padding: const EdgeInsets.only(top: 16), child: Text(_errorMessage!, style: TextStyle(color: Colors.red))),
        ],
      ),
    );
  }

  // --- UI COMPONENTS ---

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

  Widget _buildStatCard({required String label, required String value, required String unit, required VoidCallback onMinus, required VoidCallback onPlus}) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(25), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: Offset(0, 10))]),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: GoogleFonts.outfit(color: Colors.grey, fontSize: 14)),
            Row(crossAxisAlignment: CrossAxisAlignment.baseline, textBaseline: TextBaseline.alphabetic, children: [
              Text(value, style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.w900, color: AppTheme.darkText)),
              SizedBox(width: 4), Text(unit, style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.nearlyDarkBlue)),
            ]),
          ]),
          Row(children: [_buildModernBtn(Icons.remove, onMinus), SizedBox(width: 12), _buildModernBtn(Icons.add, onPlus)]),
        ],
      ),
    );
  }

  Widget _buildModernBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(onTap: onTap, child: Container(padding: EdgeInsets.all(10), decoration: BoxDecoration(color: AppTheme.nearlyDarkBlue.withOpacity(0.1), shape: BoxShape.circle), child: Icon(icon, color: AppTheme.nearlyDarkBlue, size: 20)));
  }

  Widget _buildModernSelector<T>({required List<T> items, required T groupValue, required Function(T) onChanged, required String Function(T) labelBuilder}) {
    return Column(children: items.map((item) {
      bool isSelected = item == groupValue;
      return GestureDetector(
        onTap: () => onChanged(item),
        child: AnimatedContainer(
          duration: Duration(milliseconds: 200), margin: EdgeInsets.only(bottom: 10), padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(color: isSelected ? AppTheme.nearlyDarkBlue : Colors.white, borderRadius: BorderRadius.circular(18), boxShadow: [BoxShadow(color: Colors.black.withOpacity(isSelected ? 0.2 : 0.03), blurRadius: 10, offset: Offset(0, 4))]),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(labelBuilder(item), style: GoogleFonts.outfit(color: isSelected ? Colors.white : AppTheme.darkText, fontWeight: FontWeight.bold)),
            Icon(isSelected ? Icons.check_circle_rounded : Icons.circle_outlined, color: isSelected ? Colors.white : Colors.grey[300]),
          ]),
        ),
      );
    }).toList());
  }

  Widget _buildSelectCard({required IconData icon, required String label, required bool isSelected, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300), padding: EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(color: isSelected ? AppTheme.nearlyDarkBlue : Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(isSelected ? 0.2 : 0.05), blurRadius: 15, offset: Offset(0, 10))]),
        child: Column(children: [Icon(icon, color: isSelected ? Colors.white : AppTheme.nearlyDarkBlue, size: 40), SizedBox(height: 8), Text(label, style: GoogleFonts.outfit(color: isSelected ? Colors.white : AppTheme.darkText, fontWeight: FontWeight.w900))]),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(40, 0, 40, 40),
      child: Row(
        children: [
          if (_currentPage > 0)
            GestureDetector(
              onTap: () => _pageController.previousPage(duration: Duration(milliseconds: 500), curve: Curves.easeOutCubic),
              child: Container(padding: EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]), child: Icon(Icons.arrow_back_rounded, color: AppTheme.nearlyDarkBlue)),
            ),
          if (_currentPage > 0) SizedBox(width: 20),
          Expanded(
            child: GestureDetector(
              onTap: () {
                if (_currentPage < 4) {
                  if (_currentPage == 0 && !_formKey.currentState!.validate()) return;
                  _pageController.nextPage(duration: Duration(milliseconds: 500), curve: Curves.easeOutCubic);
                } else {
                  _register();
                }
              },
              child: Container(
                height: 60,
                decoration: BoxDecoration(gradient: LinearGradient(colors: [AppTheme.nearlyDarkBlue, Color(0xFF6B8EFF)]), borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: AppTheme.nearlyDarkBlue.withOpacity(0.3), blurRadius: 15, offset: Offset(0, 8))]),
                child: Center(child: Text(_currentPage == 4 ? "CREATE MY ACCOUNT" : "CONTINUE", style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 1.2))),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(color: Colors.black.withOpacity(0.5), child: Center(child: CircularProgressIndicator(color: Colors.white)));
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    
    String goalStr = 'maintain';
    if (_goal == Goal.loseWeight) {
      goalStr = 'loss';
    } else if (_goal == Goal.gainMuscle) {
      goalStr = 'gain';
    }

    final error = await AuthService.register(
      _nameController.text.trim(),
      _emailController.text.trim(),
      _passwordController.text,
      _weight,
      _height,
      goalStr,
    );

    if (error == null) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      userProvider.updateProfile(name: _nameController.text, weight: _weight, height: _height, age: _age, gender: _gender, activityLevel: _activity, goal: _goal);
      userProvider.updateOnboardingStatus(true);
      final email = _emailController.text.trim();
      // Initialize providers with the new user's email
      await Provider.of<MealProvider>(context, listen: false).initForUser(email);
      await Provider.of<WeightProvider>(context, listen: false).initForUser(email, _weight);
      await Provider.of<ProgressProvider>(context, listen: false).initForUser(email);
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen()));
    } else {
      setState(() {
        _isLoading = false;
        _errorMessage = error;
      });
    }
  }
}

extension StringExtension on String {
  String capitalize() => "${this[0].toUpperCase()}${this.substring(1).toLowerCase()}";
}