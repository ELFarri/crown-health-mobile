import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';
import '../models/workout_model.dart';
import '../models/user_workout_model.dart';
import '../app_theme.dart';

class WorkoutsScreen extends StatefulWidget {
  @override
  _WorkoutsScreenState createState() => _WorkoutsScreenState();
}

class _WorkoutsScreenState extends State<WorkoutsScreen> {
  List<WorkoutModel> workouts = [];
  List<UserWorkoutModel> userWorkouts = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadWorkouts();
  }

  Future<void> _loadWorkouts() async {
    setState(() => loading = true);
    workouts = await ApiService.getAllWorkouts();
    setState(() => loading = false);
  }

  Future<void> _addWorkout(WorkoutModel workout) async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Starting workout: ${workout.name}'),
        backgroundColor: AppTheme.nearlyDarkBlue,
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(label: 'STOP', textColor: Colors.white, onPressed: () {}),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text('Explore Workouts', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        backgroundColor: AppTheme.nearlyDarkBlue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: loading
          ? Center(child: CircularProgressIndicator(color: AppTheme.nearlyDarkBlue))
          : ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              itemCount: workouts.length,
              itemBuilder: (context, index) {
                final workout = workouts[index];
                return Container(
                  margin: EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ListTile(
                    contentPadding: EdgeInsets.all(12),
                    leading: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${workout.duration}',
                              style: GoogleFonts.outfit(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Colors.orange[800],
                              ),
                            ),
                            Text(
                              'min',
                              style: GoogleFonts.outfit(
                                fontSize: 10,
                                color: Colors.orange[800],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    title: Text(
                      workout.name,
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppTheme.darkText,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        '${workout.category} • ${workout.caloriesBurned.toInt()} cal/min',
                        style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey),
                      ),
                    ),
                    trailing: ElevatedButton(
                      onPressed: () => _addWorkout(workout),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.nearlyDarkBlue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                      child: Text(
                        'Start',
                        style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
