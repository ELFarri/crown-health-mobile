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
    final int todayIndex = DateTime.now().weekday - 1;
    final List<double> weeklyBase = [1850, 2100, 1950, 2200, 2050, 1900, 2150];
    final List<FlSpot> spots = [];
    for (int i = 0; i <= todayIndex; i++) {
      if (i == todayIndex) {
        spots.add(FlSpot(i.toDouble(), meal.totalCalories.toDouble()));
      } else {
        spots.add(FlSpot(i.toDouble(), weeklyBase[i]));
      }
    }

    return Container(
      height: 250,
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20)],
      ),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: false),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 1.0,
                getTitlesWidget: (value, meta) {
                  const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                  final int idx = value.toInt();
                  if (idx >= 0 && idx < days.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        days[idx],
                        style: GoogleFonts.outfit(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    );
                  }
                  return const SizedBox();
                },
              ),
            ),
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
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
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildMacroIndicator('Protein', meal.totalProtein, const Color(0xFFFA7D82)),
        _buildMacroIndicator('Carbs', meal.totalCarbs, const Color(0xFF738AE6)),
        _buildMacroIndicator('Fat', meal.totalFat, const Color(0xFFFE95B2)),
      ],
    );
  }

  Widget _buildMacroIndicator(String label, double value, Color color) {
    return Container(
      width: 95,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: color.withOpacity(0.15)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(
              label == 'Protein' 
                ? Icons.fitness_center_rounded 
                : label == 'Carbs' 
                  ? Icons.restaurant_menu_rounded 
                  : Icons.local_fire_department_rounded, 
              color: color, 
              size: 20,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '${value.toInt()}g',
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppTheme.darkText, fontSize: 18),
          ),
          const SizedBox(height: 4),
          Text(
            label, 
            style: GoogleFonts.outfit(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
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
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Statistics', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22)),
      ),
    );
  }
}
