import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app_theme.dart';
import '../widgets/mediterranean_diet_view.dart';
import '../widgets/meals_list_view.dart';
import '../widgets/title_view.dart';
import 'nutrition/food_search_screen.dart';

class MealsScreen extends StatefulWidget {
  final AnimationController? animationController;
  const MealsScreen({Key? key, this.animationController}) : super(key: key);

  @override
  _MealsScreenState createState() => _MealsScreenState();
}

class _MealsScreenState extends State<MealsScreen> with TickerProviderStateMixin {
  late AnimationController _localAnimationController;
  List<Widget> _listViews = [];

  @override
  void initState() {
    super.initState();
    _localAnimationController = AnimationController(
        duration: const Duration(milliseconds: 1000), vsync: this);
    _addAllListData();
    _localAnimationController.forward();
  }

  @override
  void dispose() {
    _localAnimationController.dispose();
    super.dispose();
  }

  void _addAllListData() {
    _listViews.add(
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
    );

    _listViews.add(
      MediterraneanDietView(
        animationController: _localAnimationController,
        animation: Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: _localAnimationController,
            curve: Interval((1 / 5) * 1, 1.0, curve: Curves.fastOutSlowIn),
          ),
        ),
        eatenCalories: 1250,
        burnedCalories: 350,
        targetCalories: 2000,
      ),
    );

    _listViews.add(
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
    );

    _listViews.add(
      MealsListView(
        animationController: _localAnimationController,
        animation: Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: _localAnimationController,
            curve: Interval((1 / 5) * 3, 1.0, curve: Curves.fastOutSlowIn),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.background,
      child: Stack(
        children: [
          ListView.builder(
            padding: EdgeInsets.fromLTRB(0, AppBar().preferredSize.height + MediaQuery.of(context).padding.top + 8, 0, 100),
            itemCount: _listViews.length,
            itemBuilder: (context, index) => _listViews[index],
          ),
          _getAppBarUI(),
          _buildFloatingAddButton(),
        ],
      ),
    );
  }

  Widget _getAppBarUI() {
    return Column(
      children: [
        Container(
          height: AppBar().preferredSize.height + MediaQuery.of(context).padding.top,
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            boxShadow: [
              BoxShadow(
                color: AppTheme.gray.withOpacity(0.2),
                offset: Offset(0, 2),
                blurRadius: 8,
              ),
            ],
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: Builder(
              builder: (context) => IconButton(
                icon: Icon(Icons.menu, color: Colors.white),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
            ),
            title: Text(
              'Nutrition Journal',
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFloatingAddButton() {
    return Positioned(
      bottom: 110,
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
