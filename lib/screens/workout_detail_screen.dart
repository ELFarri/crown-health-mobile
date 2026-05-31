import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app_theme.dart';

class WorkoutDetailScreen extends StatelessWidget {
  final Map<String, dynamic> workout;

  const WorkoutDetailScreen({Key? key, required this.workout}) : super(key: key);

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
          'Workout Details',
          style: GoogleFonts.outfit(color: AppTheme.darkText, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.nearlyDarkBlue.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        workout['muscle'],
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          workout['date'],
                          style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildHeaderStat(Icons.timer_outlined, workout['duration'], 'Duration'),
                      Container(width: 1, height: 40, color: Colors.white.withOpacity(0.3)),
                      _buildHeaderStat(Icons.fitness_center_outlined, workout['volume'], 'Volume'),
                      Container(width: 1, height: 40, color: Colors.white.withOpacity(0.3)),
                      _buildHeaderStat(Icons.list_alt_rounded, '${workout['exercises']}', 'Exercises'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            
            Text(
              'Exercises Performed',
              style: GoogleFonts.outfit(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppTheme.darkText,
              ),
            ),
            const SizedBox(height: 16),
            
            // Dummy list of exercises to show what was done
            _buildExerciseRow('Bench Press', '4 sets x 10 reps', '80 kg'),
            _buildExerciseRow('Incline Dumbbell Press', '3 sets x 12 reps', '30 kg'),
            _buildExerciseRow('Cable Crossovers', '3 sets x 15 reps', '25 kg'),
            _buildExerciseRow('Push-ups', '3 sets x max reps', 'Bodyweight'),
            
            const SizedBox(height: 30),
            Center(
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.share),
                label: Text('Share Workout', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.nearlyDarkBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderStat(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 28),
        const SizedBox(height: 8),
        Text(value, style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
        Text(label, style: GoogleFonts.outfit(color: Colors.white.withOpacity(0.7), fontSize: 12)),
      ],
    );
  }

  Widget _buildExerciseRow(String name, String setsReps, String weight) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.nearlyDarkBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.fitness_center, color: AppTheme.nearlyDarkBlue),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.darkText)),
                const SizedBox(height: 4),
                Text(setsReps, style: GoogleFonts.outfit(color: Colors.grey, fontSize: 14)),
              ],
            ),
          ),
          Text(weight, style: GoogleFonts.outfit(fontWeight: FontWeight.w900, color: AppTheme.nearlyDarkBlue, fontSize: 16)),
        ],
      ),
    );
  }
}
