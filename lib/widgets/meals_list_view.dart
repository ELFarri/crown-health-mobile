import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app_theme.dart';
import '../screens/nutrition/food_search_screen.dart';

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
  final List<Map<String, dynamic>> _meals = [
    {
      'title': 'Breakfast',
      'kcal': 525,
      'imagePath': 'images/breakfast.png',
      'foods': ['Bread', 'Egg', 'Avocado'],
      'color': '#87A0E5',
    },
    {
      'title': 'Lunch',
      'kcal': 602,
      'imagePath': 'images/lunch.png',
      'foods': ['Chicken', 'Rice', 'Salad'],
      'color': '#F56E98',
    },
    {
      'title': 'Snack',
      'kcal': 190,
      'imagePath': 'images/snack.png',
      'foods': ['Yogurt', 'Nuts'],
      'color': '#F1B440',
    },
    {
      'title': 'Dinner',
      'kcal': 450,
      'imagePath': 'images/dinner.png',
      'foods': ['Fish', 'Vegetables'],
      'color': '#4A6572',
    },
  ];

  @override
  Widget build(BuildContext context) {
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
                itemCount: _meals.length,
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  return _buildMealCard(_meals[index]);
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMealCard(Map<String, dynamic> meal) {
    Color mainColor = _hexToColor(meal['color']);
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
                  meal['title'],
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppTheme.darkText,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${meal['kcal']}\nkcal',
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: AppTheme.grey.withOpacity(0.6),
                  ),
                ),
                const Spacer(),
                Wrap(
                  spacing: 4,
                  children: (meal['foods'] as List<String>)
                      .take(2)
                      .map((food) => Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: mainColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              food,
                              style: TextStyle(fontSize: 10, color: mainColor, fontWeight: FontWeight.bold),
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
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => FoodSearchScreen(mealName: meal['title'])),
                  );
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
