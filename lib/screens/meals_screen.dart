import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../app_theme.dart';
import '../widgets/mediterranean_diet_view.dart';
import '../widgets/meals_list_view.dart';
import '../widgets/title_view.dart';
import 'nutrition/food_search_screen.dart';
import '../providers/meal_provider.dart';
import '../providers/user_provider.dart';

class MealsScreen extends StatefulWidget {
  final AnimationController? animationController;
  const MealsScreen({Key? key, this.animationController}) : super(key: key);

  @override
  _MealsScreenState createState() => _MealsScreenState();
}

class _MealsScreenState extends State<MealsScreen> with TickerProviderStateMixin {
  late AnimationController _localAnimationController;

  @override
  void initState() {
    super.initState();
    _localAnimationController = AnimationController(
        duration: const Duration(milliseconds: 1000), vsync: this);
    _localAnimationController.forward();
  }

  @override
  void dispose() {
    _localAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mealProvider = context.watch<MealProvider>();
    final userProvider = context.watch<UserProvider>();

    return Container(
      color: AppTheme.background,
      child: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 100),
            children: [
              const SizedBox(height: 10),
              TitleView(
                titleText: 'Nutrition Summary',
                subText: 'Details',
                animationController: _localAnimationController,
                animation: Tween<double>(begin: 0.0, end: 1.0).animate(
                  CurvedAnimation(
                    parent: _localAnimationController,
                    curve: Interval((1 / 5) * 0, 1.0, curve: Curves.fastOutSlowIn),
                  ),
                ),
              ),
              MediterraneanDietView(
                animationController: _localAnimationController,
                animation: Tween<double>(begin: 0.0, end: 1.0).animate(
                  CurvedAnimation(
                    parent: _localAnimationController,
                    curve: Interval((1 / 5) * 1, 1.0, curve: Curves.fastOutSlowIn),
                  ),
                ),
                eatenCalories: mealProvider.totalCalories,
                burnedCalories: 0,
                targetCalories: userProvider.targetCalories,
              ),
              TitleView(
                titleText: 'Daily Meals',
                subText: 'Add Food',
                animationController: _localAnimationController,
                animation: Tween<double>(begin: 0.0, end: 1.0).animate(
                  CurvedAnimation(
                    parent: _localAnimationController,
                    curve: Interval((1 / 5) * 2, 1.0, curve: Curves.fastOutSlowIn),
                  ),
                ),
              ),
              MealsListView(
                animationController: _localAnimationController,
                animation: Tween<double>(begin: 0.0, end: 1.0).animate(
                  CurvedAnimation(
                    parent: _localAnimationController,
                    curve: Interval((1 / 5) * 3, 1.0, curve: Curves.fastOutSlowIn),
                  ),
                ),
              ),
            ],
          ),
          _buildFloatingAddButton(),
        ],
      ),
    );
  }

  Widget _buildFloatingAddButton() {
    return Positioned(
      bottom: 20,
      right: 20,
      child: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: AppTheme.nearlyDarkBlue.withOpacity(0.3),
              offset: Offset(0, 10),
              blurRadius: 20,
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const FoodSearchScreen(mealName: 'Journal')),
            );
          },
          label: Text('Quick Add', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white)),
          icon: Icon(Icons.add, color: Colors.white),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
      ),
    );
  }
}