import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app_theme.dart';
import '../screens/nutrition/food_search_screen.dart';
import 'package:provider/provider.dart';
import '../providers/meal_provider.dart';

class MealsListView extends StatefulWidget {
  final AnimationController animationController;
  final Animation<double> animation;

  const MealsListView({
    Key? key,
    required this.animationController,
    required this.animation,
  }) : super(key: key);

  @override
  _MealsListViewState createState() => _MealsListViewState();
}

class _MealsListViewState extends State<MealsListView> {
  final List<Map<String, dynamic>> _mealCategories = [
    {'title': 'Breakfast', 'imagePath': 'images/breakfast.png', 'color': '#87A0E5'},
    {'title': 'Lunch', 'imagePath': 'images/lunch.png', 'color': '#F56E98'},
    {'title': 'Snack', 'imagePath': 'images/snack.png', 'color': '#F1B440'},
    {'title': 'Dinner', 'imagePath': 'images/dinner.png', 'color': '#4A6572'},
  ];

  @override
  Widget build(BuildContext context) {
    final mealProvider = context.watch<MealProvider>();
    
    return AnimatedBuilder(
      animation: widget.animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: widget.animation,
          child: Transform.translate(
            offset: Offset(0, 30 * (1.0 - widget.animation.value)),
            child: Container(
              height: 240,
              width: double.infinity,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _mealCategories.length,
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  final category = _mealCategories[index];
                  final categoryMeals = mealProvider.todayMeals.where((m) => m.category == category['title']).toList();
                  final int kcal = categoryMeals.fold(0, (sum, item) => sum + item.calories);
                  
                  return _buildMealCard(category, categoryMeals, kcal);
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMealCard(Map<String, dynamic> category, List<FoodItem> meals, int kcal) {
    Color mainColor = _hexToColor(category['color']);
    return Container(
      width: 150,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(8),
          bottomLeft: Radius.circular(8),
          bottomRight: Radius.circular(8),
          topRight: Radius.circular(40),
        ),
        boxShadow: [
          BoxShadow(
            color: mainColor.withOpacity(0.2),
            offset: const Offset(4, 10),
            blurRadius: 15,
          ),
        ],
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category['title'],
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppTheme.darkText,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$kcal\nkcal',
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: AppTheme.grey.withOpacity(0.6),
                  ),
                ),
                const Spacer(),
                meals.isEmpty 
                  ? Text('No items', style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey[400]))
                  : Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: meals
                        .take(2)
                        .map((food) => Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: mainColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                food.name.split('(').first.trim(),
                                style: TextStyle(fontSize: 10, color: mainColor, fontWeight: FontWeight.bold),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ))
                        .toList(),
                  ),
              ],
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: mainColor.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(40),
                  bottomLeft: Radius.circular(20),
                ),
              ),
              child: IconButton(
                icon: Icon(Icons.add, color: mainColor, size: 20),
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => FoodSearchScreen(mealName: category['title'])),
                  );
                  if (result != null && result is Map<String, dynamic>) {
                    final mealProvider = Provider.of<MealProvider>(context, listen: false);
                    mealProvider.addMeal(FoodItem(
                      name: result['name'],
                      calories: (result['kcal'] as num).toInt(),
                      protein: (result['protein'] as num).toDouble(),
                      carbs: (result['carbs'] as num).toDouble(),
                      fat: (result['fat'] as num).toDouble(),
                      category: category['title'],
                    ));
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _hexToColor(String hex) {
    hex = hex.replaceAll('#', '');
    if (hex.length == 6) hex = 'FF$hex';
    return Color(int.parse(hex, radix: 16));
  }
}
