import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../app_theme.dart';
import '../providers/meal_provider.dart';
import '../providers/user_provider.dart';

class StatsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final mealProvider = Provider.of<MealProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(24, AppBar().preferredSize.height + MediaQuery.of(context).padding.top + 24, 24, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader('Weekly Calories'),
                const SizedBox(height: 16),
                _buildCalorieChart(mealProvider, userProvider),
                const SizedBox(height: 32),
                _buildHeader('Today\'s Macros'),
                const SizedBox(height: 16),
                _buildMacroSection(mealProvider),
              ],
            ),
          ),
          _getAppBarUI(context),
        ],
      ),
    );
  }

  Widget _buildHeader(String title) {
    return Text(
      title,
      style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.darkText),
    );
  }

  Widget _buildCalorieChart(MealProvider meal, UserProvider user) {
    return Container(
      height: 250,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20)],
      ),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: false),
          titlesData: FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: [
                FlSpot(0, 1800),
                FlSpot(1, 2100),
                FlSpot(2, 1900),
                FlSpot(3, 2400),
                FlSpot(4, 2200),
                FlSpot(5, meal.totalCalories.toDouble()),
              ],
              isCurved: true,
              color: AppTheme.nearlyDarkBlue,
              barWidth: 4,
              dotData: FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                color: AppTheme.nearlyDarkBlue.withOpacity(0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMacroSection(MealProvider meal) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildMacroIndicator('Protein', meal.totalProtein, Colors.blue),
        _buildMacroIndicator('Carbs', meal.totalCarbs, Colors.orange),
        _buildMacroIndicator('Fat', meal.totalFat, Colors.red),
      ],
    );
  }

  Widget _buildMacroIndicator(String label, double value, Color color) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '${value.toInt()}g',
              style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: color, fontSize: 18),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: GoogleFonts.outfit(color: Colors.grey)),
      ],
    );
  }

  Widget _getAppBarUI(BuildContext context) {
    return Container(
      height: AppBar().preferredSize.height + MediaQuery.of(context).padding.top,
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        boxShadow: [BoxShadow(color: AppTheme.gray.withOpacity(0.2), offset: const Offset(0, 2), blurRadius: 8)],
      ),
      child: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
        title: Text('Statistics', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22)),
      ),
    );
  }
}
