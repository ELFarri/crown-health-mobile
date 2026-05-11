import '../models/exercise_model.dart';

class ExerciseService {
  static final Map<String, List<Exercise>> exerciseData = {
    'Biceps': [
      Exercise(name: 'Barbell Curl', imagePath: 'images/barbell_curl.png', targetMuscle: 'Biceps', equipment: 'Barbell', sets: [WorkoutSet(reps: 10, weight: 30)]),
      Exercise(name: 'Hammer Curls', imagePath: 'images/hammer_curl.png', targetMuscle: 'Biceps', equipment: 'Dumbbells', sets: [WorkoutSet(reps: 12, weight: 14)]),
      Exercise(name: 'Incline Dumbbell Curl', imagePath: 'images/hammer_curl.png', targetMuscle: 'Biceps', equipment: 'Dumbbells', sets: [WorkoutSet(reps: 12, weight: 10)]),
      Exercise(name: 'Concentration Curl', imagePath: 'images/hammer_curl.png', targetMuscle: 'Biceps', equipment: 'Dumbbells', sets: [WorkoutSet(reps: 12, weight: 12)]),
      Exercise(name: 'Cable Curl', imagePath: 'images/barbell_curl.png', targetMuscle: 'Biceps', equipment: 'Cable Machine', sets: [WorkoutSet(reps: 12, weight: 20)]),
      Exercise(name: 'Cable Hammer Curl', imagePath: 'images/hammer_curl.png', targetMuscle: 'Biceps', equipment: 'Cable Machine', sets: [WorkoutSet(reps: 12, weight: 15)]),
      Exercise(name: 'Preacher Curl (Machine)', imagePath: 'images/barbell_curl.png', targetMuscle: 'Biceps', equipment: 'Machine', sets: [WorkoutSet(reps: 12, weight: 30)]),
      Exercise(name: 'Scott Curl (EZ Bar)', imagePath: 'images/barbell_curl.png', targetMuscle: 'Biceps', equipment: 'EZ Bar', sets: [WorkoutSet(reps: 10, weight: 20)]),
      Exercise(name: 'Reverse Barbell Curl', imagePath: 'images/reverse_curls.png', targetMuscle: 'Biceps', equipment: 'Barbell', sets: [WorkoutSet(reps: 12, weight: 15)]),
      Exercise(name: 'Spider Curl', imagePath: 'images/barbell_curl.png', targetMuscle: 'Biceps', equipment: 'Dumbbells', sets: [WorkoutSet(reps: 12, weight: 10)]),
      Exercise(name: 'Chin-Up', imagePath: 'images/barbell_curl.png', targetMuscle: 'Biceps', equipment: 'Pull-up Bar', sets: [WorkoutSet(reps: 8, weight: 0)]),
      Exercise(name: 'High Cable Curl', imagePath: 'images/barbell_curl.png', targetMuscle: 'Biceps', equipment: 'Cable Machine', sets: [WorkoutSet(reps: 12, weight: 12)]),
    ],
    'Triceps': [
      Exercise(name: 'Triceps Pushdown', imagePath: 'images/triceps_pushdown.png', targetMuscle: 'Triceps', equipment: 'Cable Machine', sets: [WorkoutSet(reps: 12, weight: 25)]),
      Exercise(name: 'Overhead Extension', imagePath: 'images/overhead_ext.png', targetMuscle: 'Triceps', equipment: 'Dumbbell', sets: [WorkoutSet(reps: 12, weight: 10)]),
      Exercise(name: 'Rope Pushdown', imagePath: 'images/triceps_pushdown.png', targetMuscle: 'Triceps', equipment: 'Cable Machine', sets: [WorkoutSet(reps: 12, weight: 20)]),
      Exercise(name: 'Skull Crusher', imagePath: 'images/overhead_ext.png', targetMuscle: 'Triceps', equipment: 'Barbell', sets: [WorkoutSet(reps: 10, weight: 30)]),
      Exercise(name: 'Close Grip Bench Press', imagePath: 'images/triceps_pushdown.png', targetMuscle: 'Triceps', equipment: 'Barbell', sets: [WorkoutSet(reps: 10, weight: 50)]),
      Exercise(name: 'Dips', imagePath: 'images/triceps_pushdown.png', targetMuscle: 'Triceps', equipment: 'Bodyweight', sets: [WorkoutSet(reps: 12, weight: 0)]),
      Exercise(name: 'Diamond Push-ups', imagePath: 'images/triceps_pushdown.png', targetMuscle: 'Triceps', equipment: 'Bodyweight', sets: [WorkoutSet(reps: 15, weight: 0)]),
      Exercise(name: 'Triceps Machine Press', imagePath: 'images/triceps_pushdown.png', targetMuscle: 'Triceps', equipment: 'Machine', sets: [WorkoutSet(reps: 12, weight: 35)]),
      Exercise(name: 'EZ Bar Overhead Extension', imagePath: 'images/overhead_ext.png', targetMuscle: 'Triceps', equipment: 'EZ Bar', sets: [WorkoutSet(reps: 12, weight: 20)]),
      Exercise(name: 'One-Arm Dumbbell Extension', imagePath: 'images/overhead_ext.png', targetMuscle: 'Triceps', equipment: 'Dumbbell', sets: [WorkoutSet(reps: 12, weight: 8)]),
    ],
    'Chest': [
      Exercise(name: 'Bench Press', imagePath: 'images/bench_press.png', targetMuscle: 'Chest', equipment: 'Barbell', sets: [WorkoutSet(reps: 10, weight: 60)]),
      Exercise(name: 'Incline Bench Press', imagePath: 'images/incline_press.png', targetMuscle: 'Chest', equipment: 'Barbell', sets: [WorkoutSet(reps: 10, weight: 50)]),
      Exercise(name: 'Decline Bench Press', imagePath: 'images/bench_press.png', targetMuscle: 'Chest', equipment: 'Barbell', sets: [WorkoutSet(reps: 10, weight: 55)]),
      Exercise(name: 'Dumbbell Bench Press', imagePath: 'images/bench_press.png', targetMuscle: 'Chest', equipment: 'Dumbbells', sets: [WorkoutSet(reps: 10, weight: 24)]),
      Exercise(name: 'Incline Dumbbell Press', imagePath: 'images/incline_press.png', targetMuscle: 'Chest', equipment: 'Dumbbells', sets: [WorkoutSet(reps: 12, weight: 20)]),
      Exercise(name: 'Chest Fly', imagePath: 'images/chest_fly.png', targetMuscle: 'Chest', equipment: 'Dumbbells', sets: [WorkoutSet(reps: 15, weight: 14)]),
      Exercise(name: 'Cable Chest Fly', imagePath: 'images/chest_fly.png', targetMuscle: 'Chest', equipment: 'Cable Machine', sets: [WorkoutSet(reps: 15, weight: 15)]),
      Exercise(name: 'Pec Deck Machine', imagePath: 'images/chest_fly.png', targetMuscle: 'Chest', equipment: 'Machine', sets: [WorkoutSet(reps: 15, weight: 40)]),
      Exercise(name: 'Push-ups', imagePath: 'images/pushups.png', targetMuscle: 'Chest', equipment: 'Bodyweight', sets: [WorkoutSet(reps: 20, weight: 0)]),
      Exercise(name: 'Chest Press Machine', imagePath: 'images/bench_press.png', targetMuscle: 'Chest', equipment: 'Machine', sets: [WorkoutSet(reps: 12, weight: 50)]),
      Exercise(name: 'Low Cable Fly', imagePath: 'images/chest_fly.png', targetMuscle: 'Chest', equipment: 'Cable Machine', sets: [WorkoutSet(reps: 15, weight: 12)]),
    ],
    'Back': [
      Exercise(name: 'Lat Pulldown', imagePath: 'images/lat_pulldown.png', targetMuscle: 'Back', equipment: 'Machine', sets: [WorkoutSet(reps: 10, weight: 50)]),
      Exercise(name: 'Seated Row', imagePath: 'images/seated_row.png', targetMuscle: 'Back', equipment: 'Cable Machine', sets: [WorkoutSet(reps: 12, weight: 45)]),
      Exercise(name: 'Pull-up', imagePath: 'images/lat_pulldown.png', targetMuscle: 'Back', equipment: 'Pull-up Bar', sets: [WorkoutSet(reps: 8, weight: 0)]),
      Exercise(name: 'Bent Over Barbell Row', imagePath: 'images/seated_row.png', targetMuscle: 'Back', equipment: 'Barbell', sets: [WorkoutSet(reps: 10, weight: 60)]),
      Exercise(name: 'Dumbbell Row', imagePath: 'images/seated_row.png', targetMuscle: 'Back', equipment: 'Dumbbells', sets: [WorkoutSet(reps: 10, weight: 24)]),
      Exercise(name: 'T-Bar Row', imagePath: 'images/seated_row.png', targetMuscle: 'Back', equipment: 'Barbell', sets: [WorkoutSet(reps: 10, weight: 50)]),
      Exercise(name: 'Machine Row', imagePath: 'images/seated_row.png', targetMuscle: 'Back', equipment: 'Machine', sets: [WorkoutSet(reps: 12, weight: 50)]),
      Exercise(name: 'Wide Grip Lat Pulldown', imagePath: 'images/lat_pulldown.png', targetMuscle: 'Back', equipment: 'Cable Machine', sets: [WorkoutSet(reps: 12, weight: 45)]),
      Exercise(name: 'Straight Arm Pulldown', imagePath: 'images/lat_pulldown.png', targetMuscle: 'Back', equipment: 'Cable Machine', sets: [WorkoutSet(reps: 15, weight: 20)]),
      Exercise(name: 'Deadlift', imagePath: 'images/seated_row.png', targetMuscle: 'Back', equipment: 'Barbell', sets: [WorkoutSet(reps: 5, weight: 100)]),
    ],
    'Shoulders': [
      Exercise(name: 'Overhead Press', imagePath: 'images/overhead_press.png', targetMuscle: 'Shoulders', equipment: 'Barbell', sets: [WorkoutSet(reps: 10, weight: 40)]),
      Exercise(name: 'Dumbbell Shoulder Press', imagePath: 'images/overhead_press.png', targetMuscle: 'Shoulders', equipment: 'Dumbbells', sets: [WorkoutSet(reps: 12, weight: 16)]),
      Exercise(name: 'Lateral Raises', imagePath: 'images/lateral_raises.png', targetMuscle: 'Shoulders', equipment: 'Dumbbells', sets: [WorkoutSet(reps: 15, weight: 8)]),
      Exercise(name: 'Cable Lateral Raises', imagePath: 'images/lateral_raises.png', targetMuscle: 'Shoulders', equipment: 'Cable Machine', sets: [WorkoutSet(reps: 15, weight: 8)]),
      Exercise(name: 'Machine Shoulder Press', imagePath: 'images/overhead_press.png', targetMuscle: 'Shoulders', equipment: 'Machine', sets: [WorkoutSet(reps: 12, weight: 40)]),
      Exercise(name: 'Arnold Press', imagePath: 'images/overhead_press.png', targetMuscle: 'Shoulders', equipment: 'Dumbbells', sets: [WorkoutSet(reps: 12, weight: 14)]),
      Exercise(name: 'Front Raises', imagePath: 'images/lateral_raises.png', targetMuscle: 'Shoulders', equipment: 'Dumbbells', sets: [WorkoutSet(reps: 15, weight: 8)]),
      Exercise(name: 'Rear Delt Fly', imagePath: 'images/lateral_raises.png', targetMuscle: 'Shoulders', equipment: 'Dumbbells', sets: [WorkoutSet(reps: 15, weight: 6)]),
      Exercise(name: 'Reverse Pec Deck', imagePath: 'images/lateral_raises.png', targetMuscle: 'Shoulders', equipment: 'Machine', sets: [WorkoutSet(reps: 15, weight: 30)]),
    ],
    'Quadriceps': [
      Exercise(name: 'Squats', imagePath: 'images/squats.png', targetMuscle: 'Quadriceps', equipment: 'Barbell', sets: [WorkoutSet(reps: 10, weight: 80)]),
      Exercise(name: 'Leg Press', imagePath: 'images/leg_press.png', targetMuscle: 'Quadriceps', equipment: 'Machine', sets: [WorkoutSet(reps: 10, weight: 120)]),
      Exercise(name: 'Leg Extension', imagePath: 'images/leg_extension.png', targetMuscle: 'Quadriceps', equipment: 'Machine', sets: [WorkoutSet(reps: 12, weight: 45)]),
      Exercise(name: 'Lunges', imagePath: 'images/lunges.png', targetMuscle: 'Quadriceps', equipment: 'Dumbbells', sets: [WorkoutSet(reps: 10, weight: 15)]),
      Exercise(name: 'Bulgarian Split Squat', imagePath: 'images/lunges.png', targetMuscle: 'Quadriceps', equipment: 'Dumbbells', sets: [WorkoutSet(reps: 10, weight: 20)]),
      Exercise(name: 'Hack Squat', imagePath: 'images/squats.png', targetMuscle: 'Quadriceps', equipment: 'Machine', sets: [WorkoutSet(reps: 10, weight: 80)]),
      Exercise(name: 'Goblet Squat', imagePath: 'images/squats.png', targetMuscle: 'Quadriceps', equipment: 'Dumbbell', sets: [WorkoutSet(reps: 12, weight: 24)]),
      Exercise(name: 'Front Squat', imagePath: 'images/squats.png', targetMuscle: 'Quadriceps', equipment: 'Barbell', sets: [WorkoutSet(reps: 8, weight: 60)]),
      Exercise(name: 'Wall Sit', imagePath: 'images/squats.png', targetMuscle: 'Quadriceps', equipment: 'Bodyweight', sets: [WorkoutSet(reps: 1, weight: 60)]),
    ],
    'Glutes': [
      Exercise(name: 'Hip Thrusts', imagePath: 'images/hip_thrust.png', targetMuscle: 'Glutes', equipment: 'Barbell', sets: [WorkoutSet(reps: 10, weight: 100)]),
      Exercise(name: 'Cable Kickbacks', imagePath: 'images/kickback.png', targetMuscle: 'Glutes', equipment: 'Cable Machine', sets: [WorkoutSet(reps: 15, weight: 15)]),
      Exercise(name: 'Glute Bridge', imagePath: 'images/hip_thrust.png', targetMuscle: 'Glutes', equipment: 'Bodyweight', sets: [WorkoutSet(reps: 20, weight: 0)]),
      Exercise(name: 'Sumo Squat', imagePath: 'images/squats.png', targetMuscle: 'Glutes', equipment: 'Barbell', sets: [WorkoutSet(reps: 12, weight: 60)]),
      Exercise(name: 'Donkey Kicks', imagePath: 'images/kickback.png', targetMuscle: 'Glutes', equipment: 'Bodyweight', sets: [WorkoutSet(reps: 15, weight: 0)]),
      Exercise(name: 'Abductor Machine', imagePath: 'images/kickback.png', targetMuscle: 'Glutes', equipment: 'Machine', sets: [WorkoutSet(reps: 15, weight: 50)]),
      Exercise(name: 'Romanian Deadlift', imagePath: 'images/hip_thrust.png', targetMuscle: 'Glutes', equipment: 'Barbell', sets: [WorkoutSet(reps: 10, weight: 70)]),
    ],
    'Abs': [
      Exercise(name: 'Crunches', imagePath: 'images/crunches.png', targetMuscle: 'Abs', equipment: 'Bodyweight', sets: [WorkoutSet(reps: 25, weight: 0)]),
      Exercise(name: 'Plank', imagePath: 'images/plank.png', targetMuscle: 'Abs', equipment: 'Bodyweight', sets: [WorkoutSet(reps: 1, weight: 60)]),
      Exercise(name: 'Hanging Leg Raise', imagePath: 'images/crunches.png', targetMuscle: 'Abs', equipment: 'Pull-up Bar', sets: [WorkoutSet(reps: 12, weight: 0)]),
      Exercise(name: 'Cable Crunch', imagePath: 'images/crunches.png', targetMuscle: 'Abs', equipment: 'Cable Machine', sets: [WorkoutSet(reps: 15, weight: 30)]),
      Exercise(name: 'Ab Machine', imagePath: 'images/crunches.png', targetMuscle: 'Abs', equipment: 'Machine', sets: [WorkoutSet(reps: 15, weight: 40)]),
      Exercise(name: 'Bicycle Crunch', imagePath: 'images/crunches.png', targetMuscle: 'Abs', equipment: 'Bodyweight', sets: [WorkoutSet(reps: 20, weight: 0)]),
      Exercise(name: 'Russian Twist', imagePath: 'images/crunches.png', targetMuscle: 'Abs', equipment: 'Dumbbell', sets: [WorkoutSet(reps: 20, weight: 8)]),
      Exercise(name: 'Leg Raise', imagePath: 'images/crunches.png', targetMuscle: 'Abs', equipment: 'Bodyweight', sets: [WorkoutSet(reps: 15, weight: 0)]),
    ],
    'Traps': [
      Exercise(name: 'Dumbbell Shrugs', imagePath: 'images/shrugs.png', targetMuscle: 'Traps', equipment: 'Dumbbells', sets: [WorkoutSet(reps: 12, weight: 24)]),
      Exercise(name: 'Barbell Shrugs', imagePath: 'images/shrugs.png', targetMuscle: 'Traps', equipment: 'Barbell', sets: [WorkoutSet(reps: 12, weight: 60)]),
      Exercise(name: 'Face Pulls', imagePath: 'images/face_pulls.png', targetMuscle: 'Traps', equipment: 'Cable Machine', sets: [WorkoutSet(reps: 15, weight: 15)]),
      Exercise(name: 'Cable Shrugs', imagePath: 'images/shrugs.png', targetMuscle: 'Traps', equipment: 'Cable Machine', sets: [WorkoutSet(reps: 12, weight: 30)]),
      Exercise(name: 'Machine Shrugs', imagePath: 'images/shrugs.png', targetMuscle: 'Traps', equipment: 'Machine', sets: [WorkoutSet(reps: 12, weight: 50)]),
      Exercise(name: 'Upright Row', imagePath: 'images/shrugs.png', targetMuscle: 'Traps', equipment: 'Barbell', sets: [WorkoutSet(reps: 12, weight: 30)]),
    ],
    'Lower Back': [
      Exercise(name: 'Back Extensions', imagePath: 'images/back_ext.png', targetMuscle: 'Lower Back', equipment: 'Machine', sets: [WorkoutSet(reps: 15, weight: 0)]),
      Exercise(name: 'Superman', imagePath: 'images/superman.png', targetMuscle: 'Lower Back', equipment: 'Bodyweight', sets: [WorkoutSet(reps: 12, weight: 0)]),
      Exercise(name: 'Romanian Deadlift', imagePath: 'images/back_ext.png', targetMuscle: 'Lower Back', equipment: 'Barbell', sets: [WorkoutSet(reps: 10, weight: 80)]),
      Exercise(name: 'Good Mornings', imagePath: 'images/back_ext.png', targetMuscle: 'Lower Back', equipment: 'Barbell', sets: [WorkoutSet(reps: 12, weight: 40)]),
      Exercise(name: 'Cable Pull Through', imagePath: 'images/back_ext.png', targetMuscle: 'Lower Back', equipment: 'Cable Machine', sets: [WorkoutSet(reps: 15, weight: 25)]),
    ],
    'Calves': [
      Exercise(name: 'Standing Calf Raise', imagePath: 'images/calf_raise.png', targetMuscle: 'Calves', equipment: 'Machine', sets: [WorkoutSet(reps: 15, weight: 60)]),
      Exercise(name: 'Seated Calf Raise', imagePath: 'images/seated_calf.png', targetMuscle: 'Calves', equipment: 'Machine', sets: [WorkoutSet(reps: 15, weight: 40)]),
      Exercise(name: 'Bodyweight Calf Raise', imagePath: 'images/calf_raise.png', targetMuscle: 'Calves', equipment: 'Bodyweight', sets: [WorkoutSet(reps: 20, weight: 0)]),
      Exercise(name: 'Dumbbell Calf Raise', imagePath: 'images/calf_raise.png', targetMuscle: 'Calves', equipment: 'Dumbbells', sets: [WorkoutSet(reps: 15, weight: 20)]),
      Exercise(name: 'Leg Press Calf Raise', imagePath: 'images/calf_raise.png', targetMuscle: 'Calves', equipment: 'Machine', sets: [WorkoutSet(reps: 15, weight: 80)]),
    ],
    'Forearms': [
      Exercise(name: 'Wrist Curls', imagePath: 'images/wrist_curls.png', targetMuscle: 'Forearms', equipment: 'Barbell', sets: [WorkoutSet(reps: 15, weight: 10)]),
      Exercise(name: 'Reverse Curls', imagePath: 'images/reverse_curls.png', targetMuscle: 'Forearms', equipment: 'Barbell', sets: [WorkoutSet(reps: 12, weight: 15)]),
      Exercise(name: 'Wrist Roller', imagePath: 'images/wrist_curls.png', targetMuscle: 'Forearms', equipment: 'Cable Machine', sets: [WorkoutSet(reps: 10, weight: 5)]),
      Exercise(name: 'Hammer Curl', imagePath: 'images/hammer_curl.png', targetMuscle: 'Forearms', equipment: 'Dumbbells', sets: [WorkoutSet(reps: 12, weight: 14)]),
    ],
  };

  static List<Exercise> searchExercises(String query) {
    if (query.isEmpty) return [];
    final lq = query.toLowerCase();
    List<Exercise> results = [];
    exerciseData.forEach((muscle, list) {
      results.addAll(list.where((ex) =>
        ex.name.toLowerCase().contains(lq) ||
        ex.targetMuscle.toLowerCase().contains(lq) ||
        ex.equipment.toLowerCase().contains(lq)
      ));
    });
    return results;
  }

  static void addExercise(Exercise exercise, String muscle) {
    if (exerciseData.containsKey(muscle)) {
      exerciseData[muscle]!.add(exercise);
    } else {
      exerciseData[muscle] = [exercise];
    }
  }
}
