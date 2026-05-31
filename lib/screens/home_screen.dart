import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fitness_app/app_theme.dart';
import 'package:fitness_app/widgets/body_measurement.dart';
import 'package:fitness_app/widgets/mediterranean_diet_view.dart';
import 'package:fitness_app/widgets/water_view.dart';
import 'package:fitness_app/widgets/workout_view.dart';
import 'package:fitness_app/widgets/glass_view.dart';
import 'package:fitness_app/widgets/custom_drawer.dart';
import 'package:fitness_app/models/tabIcon_data.dart';
import 'package:fitness_app/widgets/bottom_bar_view.dart';
import 'package:fitness_app/widgets/statistics_view.dart';
import 'package:fitness_app/widgets/weight_chart_view.dart';
import 'package:provider/provider.dart';
import 'package:fitness_app/providers/user_provider.dart';
import 'package:fitness_app/providers/meal_provider.dart';

// Import target screens
import 'package:fitness_app/screens/my_diary_screen.dart';
import 'package:fitness_app/screens/training_screen.dart';
import 'package:fitness_app/screens/meals_screen.dart';
import 'package:fitness_app/screens/profile_screen.dart';
import 'package:fitness_app/screens/exercise_browser_screen.dart';
import 'package:fitness_app/screens/workout_session_screen.dart';
import 'package:fitness_app/models/exercise_model.dart';
import 'package:fitness_app/services/auth_service.dart';
import 'package:fitness_app/screens/auth/login_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final List<TabIconData> tabIconsList = TabIconData.tabIconsList;
  late AnimationController _animationController;
  late AnimationController _mainScreenAnimationController;
  late Animation<double> _mainScreenAnimation;

  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _mainScreenAnimationController = AnimationController(
      duration: Duration(milliseconds: 1400),
      vsync: this,
    );
    _animationController = AnimationController(
      duration: Duration(milliseconds: 2000),
      vsync: this,
    );
    _mainScreenAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _mainScreenAnimationController, curve: Curves.easeOut),
    );
    _mainScreenAnimationController.forward();
    _animationController.forward();
  }

  @override
  void dispose() {
    _mainScreenAnimationController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          currentIndex == 0 ? 'Calal' : currentIndex == 1 ? 'Training' : currentIndex == 2 ? 'Nutrition' : 'Profile',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(gradient: AppTheme.primaryGradient),
        ),
        elevation: 2,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      drawer: CustomDrawer(
        userName: userProvider.name,
        userEmail: 'user@test.com',
        onLogout: () async {
          await AuthService.logout();
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => LoginScreen()),
            (route) => false,
          );
        },
        onTabTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
      ),
      body: _getBody(userProvider),
      bottomNavigationBar: BottomBarView(
        tabIconsList: tabIconsList,
        changeIndex: (int index) {
          setState(() {
            currentIndex = index;
          });
        },
        addClick: () => _showQuickAddMenu(),
      ),
    );
  }

  void _showQuickAddMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(color: Colors.grey.withOpacity(0.3), borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 20),
            Text('What do you want to add?',
                style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.darkText)),
            const SizedBox(height: 24),
            // Start Workout
            _buildQuickAddOption(
              icon: Icons.fitness_center_rounded,
              title: 'Start a Workout',
              subtitle: 'Browse exercises and build your session',
              color: AppTheme.nearlyDarkBlue,
              onTap: () async {
                Navigator.pop(sheetContext);
                final selectedExercises = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ExerciseBrowserScreen(currentWorkout: [])),
                );
                if (selectedExercises != null && selectedExercises is List && selectedExercises.isNotEmpty) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => WorkoutSessionScreen(exercises: List<Exercise>.from(selectedExercises))),
                  );
                }
              },
            ),
            const SizedBox(height: 12),
            // Add Meal
            _buildQuickAddOption(
              icon: Icons.restaurant_menu_rounded,
              title: 'Log a Meal',
              subtitle: 'Add food to your nutrition diary',
              color: Colors.green,
              onTap: () {
                Navigator.pop(sheetContext);
                setState(() => currentIndex = 2);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAddOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: color.withOpacity(0.07),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(14)),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.darkText)),
                  Text(subtitle, style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _getBody(UserProvider userProvider) {
    switch (currentIndex) {
      case 0:
        return _buildDashboard(userProvider);
      case 1:
        return TrainingScreen(animationController: _mainScreenAnimationController);
      case 2:
        return MealsScreen();
      case 3:
        return ProfileScreen();
      default:
        return _buildDashboard(userProvider);
    }
  }

  Widget _buildDashboard(UserProvider userProvider) {
    final mealProvider = context.watch<MealProvider>();
    
    return SingleChildScrollView(
      padding: EdgeInsets.only(bottom: 100), // Adjusted for bottom bar
      child: Column(
        children: [
          // Body Measurement
          BodyMeasurementView(
            animationController: _animationController,
            animation: _mainScreenAnimation,
            weight: userProvider.weight,
            height: userProvider.height,
            bmi: userProvider.bmi,
            bmiStatus: userProvider.bmiStatus,
          ),
          WeightChartView(),
          StatisticsView(
            animationController: _animationController,
            animation: _mainScreenAnimation,
          ),
          // Water & Diet Cards (stacked for mobile responsiveness)
          WaterView(animationController: _animationController, animation: _mainScreenAnimation),
          MediterraneanDietView(
            animationController: _animationController, 
            animation: _mainScreenAnimation,
            targetCalories: userProvider.targetCalories,
            eatenCalories: mealProvider.totalCalories,
          ),
          
          // Workout & Glass (stacked for mobile responsiveness)
          WorkoutView(animationController: _animationController, animation: _mainScreenAnimation, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => WorkoutSessionScreen(exercises: [])))),
          GlassView(animationController: _animationController, animation: _mainScreenAnimation),
          
          SizedBox(height: 24),
        ],
      ),
    );
  }
}

