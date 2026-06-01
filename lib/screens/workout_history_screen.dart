import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app_theme.dart';
import 'workout_detail_screen.dart';

class WorkoutHistoryScreen extends StatelessWidget {
  final List<Map<String, dynamic>> _history = [
    {
      'date': 'Today, 10 May',
      'muscle': 'Chest',
      'duration': '45 min',
      'exercises': 4,
      'volume': '2,400 kg',
    },
    {
      'date': 'Yesterday, 9 May',
      'muscle': 'Back',
      'duration': '50 min',
      'exercises': 5,
      'volume': '3,100 kg',
    },
    {
      'date': '7 May',
      'muscle': 'Legs',
      'duration': '65 min',
      'exercises': 6,
      'volume': '4,500 kg',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: AppTheme.darkText),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Workout History',
          style: GoogleFonts.outfit(color: AppTheme.darkText, fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(24),
        itemCount: _history.length,
        itemBuilder: (context, index) {
          final workout = _history[index];
          return _buildHistoryCard(context, workout);
        },
      ),
    );
  }

  Widget _buildHistoryCard(BuildContext context, Map<String, dynamic> workout) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(workout['date'], style: GoogleFonts.outfit(color: Colors.grey, fontWeight: FontWeight.w600)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: AppTheme.nearlyDarkBlue.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                child: Text(workout['muscle'], style: GoogleFonts.outfit(color: AppTheme.nearlyDarkBlue, fontWeight: FontWeight.bold, fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              _buildStatInfo(Icons.timer_outlined, workout['duration']),
              _buildStatInfo(Icons.fitness_center_outlined, workout['volume']),
              _buildStatInfo(Icons.list_alt_rounded, '${workout['exercises']} exercises'),
            ],
          ),
          const SizedBox(height: 20),
          Divider(color: Colors.grey.withOpacity(0.1)),
          const SizedBox(height: 8),
          Center(
            child: TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => WorkoutDetailScreen(workout: workout)),
                );
              },
              child: Text('View Details', style: GoogleFonts.outfit(color: AppTheme.nearlyDarkBlue, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatInfo(IconData icon, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 6),
        Text(value, style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.darkText)),
      ],
    );
  }
}
