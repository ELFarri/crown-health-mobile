import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../app_theme.dart';
import '../providers/weight_provider.dart';

class WeightChartView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final weightProvider = context.watch<WeightProvider>();
    final history = weightProvider.history;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        height: 250,
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: Offset(0, 5))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Weight Evolution", style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.darkText)),
                Icon(Icons.show_chart, color: AppTheme.nearlyDarkBlue),
              ],
            ),
            SizedBox(height: 24),
            Expanded(
              child: history.length < 2 
                ? Center(child: Text("Add more weight entries to see progress", style: GoogleFonts.outfit(color: Colors.grey)))
                : LineChart(
                    LineChartData(
                      gridData: FlGridData(show: false),
                      titlesData: FlTitlesData(show: false),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: history.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.weight)).toList(),
                          isCurved: true,
                          color: AppTheme.nearlyDarkBlue,
                          barWidth: 4,
                          isStrokeCapRound: true,
                          dotData: FlDotData(show: true),
                          belowBarData: BarAreaData(
                            show: true,
                            color: AppTheme.nearlyDarkBlue.withOpacity(0.1),
                          ),
                        ),
                      ],
                    ),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
