import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fitness_app/app_theme.dart';
import '../services/exercise_service.dart';
import '../models/exercise_model.dart';
import '../screens/workout_session_screen.dart';

class WorkoutView extends StatelessWidget {
  final AnimationController animationController;
  final Animation<double> animation;
  final VoidCallback? onTap;

  const WorkoutView({
    Key? key,
    required this.animationController,
    required this.animation,
    this.onTap,
  }) : super(key: key);

  Color hexToColor(String hex) {
    hex = hex.replaceAll('#', '');
    if (hex.length == 6) hex = 'FF$hex';
    return Color(int.parse(hex, radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    final int weekday = DateTime.now().weekday;
    String recommendedMuscle = "Glutes";
    String workoutTitle = "Intense Glutes Workout";
    String duration = "50 min";
    
    switch (weekday) {
      case 1:
        recommendedMuscle = "Biceps";
        workoutTitle = "Biceps & Arms Workout";
        duration = "35 min";
        break;
      case 2:
        recommendedMuscle = "Glutes";
        workoutTitle = "Intense Glutes Workout";
        duration = "50 min";
        break;
      case 3:
        recommendedMuscle = "Abs";
        workoutTitle = "Iron Abs & Core Workout";
        duration = "25 min";
        break;
      case 4:
        recommendedMuscle = "Chest";
        workoutTitle = "Chest & Triceps Workout";
        duration = "45 min";
        break;
      case 5:
        recommendedMuscle = "Back";
        workoutTitle = "V-Back & Strengthening";
        duration = "40 min";
        break;
      case 6:
        recommendedMuscle = "Quadriceps";
        workoutTitle = "Quads & Thighs Workout";
        duration = "55 min";
        break;
      case 7:
        recommendedMuscle = "Glutes";
        workoutTitle = "Glutes Sculpt & Tone";
        duration = "50 min";
        break;
    }

    return AnimatedBuilder(
      animation: animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: animation,
          child: Transform.translate(
            offset: Offset(0, 30 * (1.0 - animation.value)),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 18),
              child: GestureDetector(
                onTap: () {
                  final exercises = ExerciseService.exerciseData[recommendedMuscle] ?? [];
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => WorkoutSessionScreen(
                        exercises: exercises.map((e) => Exercise(
                          name: e.name,
                          imagePath: e.imagePath,
                          targetMuscle: e.targetMuscle,
                          equipment: e.equipment,
                          sets: e.sets.map((s) => WorkoutSet(
                            reps: s.reps,
                            weight: s.weight,
                            isCompleted: false,
                          )).toList(),
                        )).toList(),
                      ),
                    ),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF2E5BFF),
                        Color(0xFF6F56E8),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(8),
                      bottomLeft: Radius.circular(8),
                      bottomRight: Radius.circular(8),
                      topRight: Radius.circular(68),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.gray.withOpacity(0.6),
                        offset: const Offset(1, 1),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Recommended for today',
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.normal,
                            fontSize: 14,
                            color: AppTheme.white,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            workoutTitle,
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.w600,
                              fontSize: 20,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 4),
                              child: Icon(Icons.timer, 
                                  color: AppTheme.white, size: 16),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 4),
                              child: Text(
                                duration,
                                style: GoogleFonts.outfit(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                  color: AppTheme.white,
                                ),
                              ),
                            ),
                            const Spacer(),
                            Container(
                              decoration: BoxDecoration(
                                color: AppTheme.nearlyWhite,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.nearlyBlack.withOpacity(0.4),
                                    offset: const Offset(8, 8),
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.arrow_forward_ios,
                                color: hexToColor("#6F56E8"),
                                size: 20,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
