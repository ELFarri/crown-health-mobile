import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../app_theme.dart';
import '../../services/api_service.dart';
import '../../models/nutrition_stat.dart';

class NutritionStatsScreen extends StatefulWidget {
  const NutritionStatsScreen({Key? key}) : super(key: key);

  @override
  _NutritionStatsScreenState createState() => _NutritionStatsScreenState();
}

class _NutritionStatsScreenState extends State<NutritionStatsScreen> {
  String _selectedPeriod = 'weekly';
  List<NutritionStat> _stats = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchStats();
  }

  Future<void> _fetchStats() async {
    setState(() => _isLoading = true);
    try {
      final data = await ApiService.getNutritionStats(period: _selectedPeriod);
      setState(() {
        _stats = data.reversed.toList(); // Order chronologically for the chart
        _isLoading = false;
      });
    } catch (e) {
      print('Failed to fetch stats: $e');
      setState(() => _isLoading = false);
    }
  }

  double get _avgCalories {
    if (_stats.isEmpty) return 0;
    return _stats.fold(0.0, (sum, item) => sum + item.totalCalories) / _stats.length;
  }

  double get _totalProtein => _stats.fold(0.0, (sum, item) => sum + item.totalProtein);
  double get _totalCarbs => _stats.fold(0.0, (sum, item) => sum + item.totalCarbs);
  double get _totalFat => _stats.fold(0.0, (sum, item) => sum + item.totalFat);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : AppTheme.darkText;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBackground : AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Nutrition Analytics',
          style: GoogleFonts.outfit(color: textColor, fontWeight: FontWeight.bold),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: PopupMenuButton<String>(
              onSelected: (period) {
                setState(() {
                  _selectedPeriod = period;
                });
                _fetchStats();
              },
              icon: Icon(Icons.more_vert, color: textColor),
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'weekly', child: Text('Weekly Recap')),
                const PopupMenuItem(value: 'monthly', child: Text('Monthly Recap')),
              ],
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.nearlyDarkBlue))
          : _stats.isEmpty
              ? _buildEmptyState(textColor)
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildOverviewCard(isDark),
                      const SizedBox(height: 24),
                      Text(
                        'Calorie Consumption',
                        style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
                      ),
                      const SizedBox(height: 16),
                      _buildCalorieBarChart(isDark),
                      const SizedBox(height: 24),
                      Text(
                        'Macronutrient Distribution',
                        style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
                      ),
                      const SizedBox(height: 16),
                      _buildMacrosDistributionCard(isDark),
                    ],
                  ),
                ),
    );
  }

  Widget _buildEmptyState(Color textColor) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.query_stats_rounded, size: 80, color: Colors.grey.withOpacity(0.4)),
          const SizedBox(height: 16),
          Text(
            'No stats recorded for this period yet',
            style: GoogleFonts.outfit(fontSize: 16, color: textColor, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Add some meals in your journal to see statistics!',
            style: GoogleFonts.outfit(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppTheme.nearlyDarkBlue.withOpacity(0.3),
            offset: const Offset(0, 10),
            blurRadius: 20,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Daily Average',
                style: GoogleFonts.outfit(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 4),
              Text(
                '${_avgCalories.toStringAsFixed(0)} kcal',
                style: GoogleFonts.outfit(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.flash_on_rounded, color: Colors.white, size: 28),
          ),
        ],
      ),
    );
  }

  Widget _buildCalorieBarChart(bool isDark) {
    final textColor = isDark ? Colors.white70 : AppTheme.darkText;

    return Container(
      height: 220,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 10),
            blurRadius: 20,
          ),
        ],
      ),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: _stats.map((s) => s.totalCalories.toDouble()).reduce((a, b) => a > b ? a : b) * 1.2,
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              tooltipBgColor: AppTheme.nearlyDarkBlue,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                return BarTooltipItem(
                  '${rod.toY.round()} kcal',
                  GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (double value, TitleMeta meta) {
                  int idx = value.toInt();
                  if (idx >= 0 && idx < _stats.length) {
                    final date = DateTime.parse(_stats[idx].date);
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        DateFormat('E').format(date),
                        style: GoogleFonts.outfit(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.w600),
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
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          barGroups: List.generate(_stats.length, (index) {
            final stat = _stats[index];
            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: stat.totalCalories.toDouble(),
                  gradient: AppTheme.primaryGradient,
                  width: 12,
                  borderRadius: BorderRadius.circular(6),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _buildMacrosDistributionCard(bool isDark) {
    final textColor = isDark ? Colors.white : AppTheme.darkText;
    final totalMacros = _totalProtein + _totalCarbs + _totalFat;
    
    if (totalMacros == 0) return const SizedBox();

    final proteinPerc = (_totalProtein / totalMacros) * 100;
    final carbsPerc = (_totalCarbs / totalMacros) * 100;
    final fatPerc = (_totalFat / totalMacros) * 100;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 10),
            blurRadius: 20,
          ),
        ],
      ),
      child: Column(
        children: [
          SizedBox(
            height: 160,
            child: PieChart(
              PieChartData(
                sectionsSpace: 4,
                centerSpaceRadius: 40,
                sections: [
                  PieChartSectionData(
                    color: const Color(0xFFFA7D82),
                    value: _totalProtein,
                    title: '${proteinPerc.toStringAsFixed(0)}%',
                    radius: 40,
                    titleStyle: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  PieChartSectionData(
                    color: const Color(0xFF738AE6),
                    value: _totalCarbs,
                    title: '${carbsPerc.toStringAsFixed(0)}%',
                    radius: 40,
                    titleStyle: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  PieChartSectionData(
                    color: const Color(0xFFFE95B2),
                    value: _totalFat,
                    title: '${fatPerc.toStringAsFixed(0)}%',
                    radius: 40,
                    titleStyle: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildMacroLegend('Protein', '${_totalProtein.toStringAsFixed(0)}g', const Color(0xFFFA7D82), textColor),
              _buildMacroLegend('Carbs', '${_totalCarbs.toStringAsFixed(0)}g', const Color(0xFF738AE6), textColor),
              _buildMacroLegend('Fat', '${_totalFat.toStringAsFixed(0)}g', const Color(0xFFFE95B2), textColor),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMacroLegend(String label, String value, Color color, Color textColor) {
    return Column(
      children: [
        Row(
          children: [
            Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
            const SizedBox(width: 6),
            Text(label, style: GoogleFonts.outfit(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.w600)),
          ],
        ),
        const SizedBox(height: 4),
        Text(value, style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.bold, color: textColor)),
      ],
    );
  }
}
